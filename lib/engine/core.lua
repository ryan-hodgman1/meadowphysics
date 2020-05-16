--

local function Meadowphysics ()
  local mp = {}

  local create_voice = include("meadowphysics/lib/engine/voice")
  local setup_params = include("meadowphysics/lib/engine/parameters")
  local ui = include("meadowphysics/lib/engine/ui")
  local mp_grid = include("meadowphysics/lib/engine/grid")
  local scale = include("meadowphysics/lib/engine/scale")
  local MusicUtil = require "musicutil"
  m = midi.connect()
  
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
        local note_num = scale.notes[9-i]
        local hz = MusicUtil.note_num_to_freq(note_num)
        if params:get(i .. "_type") == 1 then
          if (params:get('output') == 1 or params:get('output') == 3) then
            trigger(note_num, hz, i)
          end
          if (params:get('output') == 2 or params:get('output') == 3) then
            make_midi_note(i)
          end
        end
        if params:get(i .. "_type") == 2 then
          if(voice.gate == 1) then
            if (params:get('output') == 1 or params:get('output') == 3) then
              gate_high(note_num, hz, i)
            end
            if (params:get('output') == 2 or params:get('output') == 3) then
              open_midi_gate(i)
            end
          else
            if (params:get('output') == 1 or params:get('output') == 3) then
              gate_low(note_num, hz, i)
            end
            if (params:get('output') == 2 or params:get('output') == 3) then
              close_midi_gate(i)
            end
          end
        end
      end
    end

    -- grid and screen metro
    mp.redrawtimer = metro.init(function() mp:gridredraw(); redraw() end, 0.02, -1)
    mp.redrawtimer:start()
    -- global clock
    function clock.transport.start() mp.clock_id = clock.run(mp.clock_loop) end
    function clock.transport.stop() clock.cancel(mp.clock_id) end
    clock.transport.start()
  end

  function make_midi_note(track) 
    m:note_on(scale.notes[track], 100, params:get("midi_out_channel"))
  end

  function open_midi_gate(track) 
    print('note on')
    m:note_on(scale.notes[track], 100, params:get("midi_out_channel"))
  end

  function close_midi_gate(track)
    print("note off")
    m:note_off(scale.notes[track], 100, params:get("midi_out_channel"))
  end


  notes = {}

  function midi_notes_off()
    for i = 1, mp.voice_count do
      m:note_off(scale.notes[i], 100, params:get("midi_out_channel"))
    end
  end

  mp.clock_loop = function()
    while true do
      clock.sync(1/4)
    -- midi_notes_off()
      mp.handle_tick()
    end
  end

  function mp:handle_tick()
    for i=1,mp.voice_count do
      voices[i].tick()
    end
  end

  function mp:handle_key (n, z)

  end

  mp.grid_voice_key = false -- is the first column key pressed?
  mp.grid_rule_key = false -- is the second columns pressed?
  mp.grid_voice_bounds_key = false -- are one of the position columns pressed?
  mp.grid_range_start = false

  mp.grid_key_state = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  }

  function mp:handle_grid_input(x, y, z)
    mp.grid_key_state[y][x] = z

    mp.grid_mode = "pattern"

    for i = 1, 8 do -- each voices row

      if (mp.grid_key_state[i][1] == 1 and mp.grid_key_state[i][2] == 0) then
        print("VOICE MODE")
        mp.grid_mode = "voice"
        mp.grid_target_focus = i
      end

      if (mp.grid_key_state[i][1] == 1 and mp.grid_key_state[i][2] == 1) then
        print("RULE MODE")
        mp.grid_mode = "rule"
        mp.grid_target_focus = i
      end

    end


    if (mp.grid_mode == "voice" and z == 1) then

      if (x == 3) then
        print("toggle playback of ", y)
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
        print("set clock division for ", y, "to be ", x - 8)
        mp.voices[y].set_clock_division(x - 8)
      end


    end


    if (mp.grid_mode == "rule" and z == 1) then
      if x > 8 and y > 1 and y < 8 then
        local rules = {"increment", "decrement", "min", "max", "random", "pole", "stop"}
        print("set rule", rules[y-1], " for voice", mp.grid_target_focus)
        params:set(mp.grid_target_focus .. "_rule", y-1)
        print(mp.grid_target_focus, "_rule", y-1)
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
