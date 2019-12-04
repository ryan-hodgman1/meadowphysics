--

local function Meadowphysics ()
  local mp = {}

  local create_voice = include("meadowphysics/lib/engine/voice")
  local setup_params = include("meadowphysics/lib/engine/parameters")
  local ui = include("meadowphysics/lib/engine/ui")
  local mp_grid = include("meadowphysics/lib/engine/grid")
  local bc = require "beatclock"
  local g = grid.connect()
  local gridbuf = require "gridbuf"
  local gbuf = gridbuf.new(16, 8)

  mp.grid_mode = "pattern"
  local mp_ui = ui.new(mp)
  mp.should_redraw = true

  local voices = {}
  mp.voices = voices

  mp.init = function (voice_count)
    mp.voice_count = voice_count
    setup_params(mp)
    for i=1,voice_count do
      voices[i] = create_voice(i)
      local voice = voices[i]
      voice.target_voices = {voice} -- initial state is looping
      -- voice.current_cycle_length = 7+i
      -- voice.current_step = 7+i
      voice.on_bang = function (bang)
        mp.on_bang(bang)
      end
    end
  end

  -- Overwritten by meadow.lua
  mp.on_bang = function (f)
    print("bang")
  end

  local ti = 0
  function mp:handle_tick()
    -- print(ti, "-----------------------------")
    ti = ti + 1
    if ti>16 then ti = 1 end
    -- Pass a tick to each voice
    for i=1,mp.voice_count do
      voices[i].tick()
    end
    mp.should_redraw = true
  end


  function mp:handle_key (n, z)

  end


  function mp:handle_enc()

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
    -- Loop through grid key state and find some actions to make!
    if (z == 1) then
      for i = 1, 8 do
        local pressed_keys = {}
        for _x = 2, 16 do
          if (mp.grid_key_state[i][_x] == 1) then
            table.insert(pressed_keys, _x)
          end
        end

        if mp.grid_key_state[i][1] == 1 and mp.grid_key_state[i][2] == 1 then
          -- Rule adjustment
          mp.grid_target_focus = i
          mp.grid_mode = "rule"
          break
        end

        if mp.grid_key_state[i][1] == 1 then
          -- Voice and triggers adjustment
          mp.grid_target_focus = i
          mp.grid_mode = "voice"
          if (x == 3) then
            print("toggle playback of ", y)
            mp.voices[y].toggle_playback()
          end
          if (x == 4) then
            print("Toggle voice ", i, " triggering", y)
            mp.voices[i].toggle_target(mp.voices[y])
          end
          if (x == 6) then
            mp.voices[y].set_bang_type("gate")
          end
          if (x == 7) then
            mp.voices[y].set_bang_type("trigger")
          end
          if (x > 8) then
            print("set clock division for ", y, "to be ", x - 8)
            mp.voices[y].set_clock_division(x - 8)
          end
          break
        end

        mp.grid_mode = "pattern"
        if y == i then
          -- Pattern Adjustment
          if (#pressed_keys > 1) then -- Range press in pattern mode
            mp.voices[i].min_cycle_length = pressed_keys[1]
            mp.voices[i].max_cycle_length = pressed_keys[#pressed_keys]
          end
          if (#pressed_keys == 1) then -- Single press in pattern mode
            voices[i].bang()
            voices[i].just_triggered = true
            voices[i].current_step = x
            voices[i].current_tick = 0
            voices[i].current_cycle_length = x
            voices[i].min_cycle_length = x
            voices[i].max_cycle_length = x
            voices[i].is_playing = true
          end
        end
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
    -- screen.move(4, 8)
    -- screen.text(ti)
    mp_ui:draw(mp)
    mp_grid:draw(mp)
  end




  mp.get_state = function (i)
    return "Voice " .. i .. ": " .. voices[i].current_step .. "/" .. voices[i].current_tick
  end

  return mp

end

return Meadowphysics
