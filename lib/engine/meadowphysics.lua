-- 

local function Meadowphysics ()

  local create_voice = include("meadowphysics/lib/engine/voice")
  local ui = include("meadowphysics/lib/engine/mp_ui")
  print(ui[1])
  local mp_grid = include("meadowphysics/lib/engine/mp_grid")
  local bc = require "beatclock"
  local g = grid.connect()
  local gridbuf = require "gridbuf"
  local gbuf = gridbuf.new(16, 8)

  local mp = {}
  mp_ui = ui.new(mp)
  mp.should_redraw = true

  local voices = {}
  mp.voices = voices

  mp.init = function (voice_count)
    mp.voice_count = voice_count
    for i=1,voice_count do
      voices[i] = create_voice(i)
      local voice = voices[i]
      voice.target_voices = {voice} -- initial state is looping
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

  function mp:handle_grid_input(x, y, z)
    if (z == 1) then
      voices[y].bang()
      voices[y].just_triggered = true
      voices[y].current_step = x
      voices[y].current_tick = 0
      voices[y].current_cycle_length = x
      voices[y].is_playing = true
    end
  end


  function mp:draw()
    screen.move(4, 8)
    screen.text(ti)
    mp_ui:draw(mp)
    mp_grid:draw(mp)
  end




  mp.get_state = function (i)
    return "Voice " .. i .. ": " .. voices[i].current_step .. "/" .. voices[i].current_tick
  end

  return mp

end

return Meadowphysics
