-- 
local create_voice = include("meadowphysics/lib/engine/voice")
local mp_ui = include("meadowphysics/lib/engine/mp_ui")
local bc = require "beatclock"
local clk = bc.new()
local g = grid.connect()
local gridbuf = require "gridbuf"
local gbuf = gridbuf.new(16, 8)

local mp = {}
mp.emit_bang = function () end
mp.emit_clock_tick = function () end
mp.should_redraw = true

local voices = {}
mp.voices = voices

function mp:init(voice_count)
  mp.voice_count = voice_count
  for i=1,voice_count do
    voices[i] = create_voice(i)
    local voice = voices[i]
    voice.on_bang = function (bang)
      mp.emit_bang(bang)
    end
  end
  clk.on_step = handle_tick
  clk:bpm_change(40)
  clk:start()
end

-- Event handler
function mp:on_bang(f)
  mp.emit_bang = f
end

function mp:on_clock_tick(f)
  mp.emit_clock_tick = f
end


local ti = 0
function handle_tick()
  print("-----------------------------")

  
  ti = ti + 1
  if ti>4 then ti = 1 end
  -- Pass a tick to each voice
  for i=1,mp.voice_count do
    voices[i]:tick()
  end
  mp.should_redraw = true
  mp.emit_clock_tick()
  print(voices[1].current_tick, voices[2].current_tick, voices[3].current_tick)
  -- print(voices[1].current_step, voices[1].current_tick)
end


function mp:handle_key(n, z)
  if(z == 1 and n == 2 ) then
    voices[1].bang()
    voices[1].is_playing = true
    voices[1].reset()
    mp.should_redraw = true
  end
  if (z ==1 and n == 3) then
    handle_tick()
  end
end


function mp:handle_enc()
  handle_tick()
end


function mp:screen_redraw()
  screen.move(4, 16)
  screen.text(ti)
  -- screen.move(4, 24)
  -- screen.text(mp:get_state(2))
  -- mp_ui:draw(mp)
  mp_ui:draw(mp)
end


function mp:grid_redraw()

end


function mp:get_state(i)
  return "Voice " .. i .. ": " .. voices[i].current_step .. "/" .. voices[i].current_tick
end

return mp

