--

local function Meadowphysics ()
  local mp = {}

  local create_voice = include("meadowphysics/lib/mp/voice")
  local setup_params = include("meadowphysics/lib/mp/parameters")
  local ui = include("meadowphysics/lib/mp/ui")
  local mp_grid = include("meadowphysics/lib/mp/grid")
  local scale = include("meadowphysics/lib/mp/scale")
  local MusicUtil = require "musicutil"

  mp.midi_out_device = midi.connect(1)
  
  mp.grid_mode = "pattern"
  local mp_ui = ui.new(mp)
  mp.should_redraw = true

  local voices = {}
  mp.voices = voices

  mp.init = function ()
    scale:make_params()
    mp.voice_count = 8
    setup_params(mp)

    for i=1,mp.voice_count do
      voices[i] = create_voice(i, mp)
      local voice = voices[i]

      voice.on_bang = function ()
        
        -- Generate note/hz
        local note_num = scale.notes[mp.voice_count + 1 - i]
        local hz = MusicUtil.note_num_to_freq(note_num)
        
        -- If the voice type is a trigger
        if params:get(i .. "_type") == 1 then
          if (params:get('output') == 1 or params:get('output') == 3) then
            trigger(note_num, hz, i) -- global defined by main script
          end
          if (params:get('output') == 2 or params:get('output') == 3) then
            midi_note_on(i)
          end
        end
        
        -- If the voice type is a gate
        if params:get(i .. "_type") == 2 then
          if(voice.gate == 1) then
            if (params:get('output') == 1 or params:get('output') == 3) then
              gate_high(note_num, hz, i) -- global defined by main script
            end
            if (params:get('output') == 2 or params:get('output') == 3) then
              midi_note_on(i)
            end
          else
            if (params:get('output') == 1 or params:get('output') == 3) then
              gate_low(note_num, hz, i) -- global defined by main script
            end
            if (params:get('output') == 2 or params:get('output') == 3) then
              midi_note_off(i)
            end
          end
        end
      end
    end

    -- grid and screen metro
    mp.redrawtimer = metro.init(function() redraw() end, (1/15), -1)
    mp.redrawtimer:start()
    -- global clock
    function clock.transport.start() mp.clock_id = clock.run(mp.clock_loop) end
    function clock.transport.stop() clock.cancel(mp.clock_id) end
    clock.transport.start()
  end

  function midi_note_on(track)
    mp.midi_out_device:note_on(scale.notes[track], 100, params:get("midi_out_channel"))
  end


  function midi_note_off(track)
    mp.midi_out_device:note_off(scale.notes[track], 100, params:get("midi_out_channel"))
  end


  notes = {}

  function midi_notes_off()
    for i = 1, mp.voice_count do
      if (params:get(i.."_type") == 1) then midi_note_off(i) end
    end
  end

  mp.clock_loop = function()
    while true do
      clock.sync(1/(params:get("clock_division")*4))
      if (params:get('output') == 2 or params:get('output') == 3 and false) then
        midi_notes_off()
      end
      mp.handle_tick()
    end
  end

  function mp:handle_tick()
    for i=1,mp.voice_count do
      voices[i].tick()
    end
    mp:gridredraw()
  end

  function mp:handle_key (n, z)

  end

  mp.grid_voice_key = false -- is the first column key pressed?
  mp.grid_rule_key = false -- is the second columns pressed?
  mp.grid_voice_bounds_key = false -- are one of the position columns pressed?
  mp.grid_range_start = false

  -- Generate an empty table of grid state
  mp.grid_key_state = {}
  for i = 1, 8 do
    mp.grid_key_state[i] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  end

  function mp:handle_grid_input(x, y, z)

    mp.grid_key_state[y][x] = z

    mp.grid_mode = "pattern"

    for i = 1, mp.voice_count do -- each voices row

      if (mp.grid_key_state[i][1] == 1 and mp.grid_key_state[i][2] == 0) then
        mp.grid_mode = "voice"
        mp.grid_target_focus = i
      end

      if (mp.grid_key_state[i][1] == 1 and mp.grid_key_state[i][2] == 1) then
        mp.grid_mode = "rule"
        mp.grid_target_focus = i
      end

    end


    if (mp.grid_mode == "voice" and z == 1) then

      if (x == 3) then
        mp.voices[y].toggle_playback()
      end

      if (x == 4) then -- this is buggy!
        mp.voices[mp.grid_target_focus].toggle_target(y)
      end

      if (x == 6) then
        mp.voices[y].set_bang_type(1)
      end

      if (x == 7) then
        mp.voices[y].set_bang_type(2)
      end

      if (x > 8) then
        -- Get the highest and lowest division keys pressed
        local pushed_division_keys = {}
        for di=1,8 do
          if (mp.grid_key_state[y][di+8]) == 1 then
            table.insert(pushed_division_keys, di)
          end
        end
        params:set(y .. "_clock_division_low", pushed_division_keys[1])
        params:set(y .. "_clock_division_high", pushed_division_keys[#pushed_division_keys])
        mp.voices[y].current_clock_division = pushed_division_keys[1]
        mp.voices[y].current_tick = 1
      end


    end


    if (mp.grid_mode == "rule" and z == 1) then
      if x > 8 and y > 1 and y < 8 then
        local rules = {"increment", "decrement", "min", "max", "random", "pole", "stop"}
        params:set(mp.grid_target_focus .. "_rule", y-1)
      end
    end


    if (mp.grid_mode == "pattern" and z == 1) then
      local pressed_keys = {}
      -- put all the pressed keys into a table
      for _x = 2, 16 do
        if (mp.grid_key_state[y][_x] == 1) then
          table.insert(pressed_keys, _x)
        end
      end

      -- Pattern Adjustment
      if (#pressed_keys > 1) then
        params:set(y .. "_range_low", pressed_keys[1])
        params:set(y .. "_range_high", pressed_keys[#pressed_keys])
      end
      if (#pressed_keys == 1) then -- Single press in pattern mode
        voices[y].bang()
        voices[y].just_triggered = true
        voices[y].current_step = x
        voices[y].current_tick = 0
        voices[y].current_cycle_length = x
        params:set(y .. "_range_high", x)
        params:set(y .. "_range_low", x)
        params:set(y .. "_running", 2)
      end
    end


     -- this is a bit of a kludgy way of returning focus back to pattern mode
    if (z == 0) then
      if (x == 1) then
        mp.grid_target_focus = false
        mp.grid_mode = "pattern"
      end
    end


  end


  function mp:draw()
    mp_ui:draw(mp)
  end

  function mp:gridredraw()
    mp_grid:draw(mp)
  end



  mp.get_state = function (i)
    return "Voice " .. i .. ": " .. voices[i].current_step .. "/" .. voices[i].current_tick
  end

  return mp

end

return Meadowphysics
