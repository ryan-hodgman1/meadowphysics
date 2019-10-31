-- 

local bc = require "beatclock"
local clk = bc.new()
local g = grid.connect()
local gridbuf = require "gridbuf"
local gbuf = gridbuf.new(16, 8)

local mp = {}
mp.dirty = true
local voices = {}
local create_voice = include("meadowphysics/lib/engine/voice")


function mp:init()
  print('init meadow')
  for i=1,8 do
    voices[i] = create_voice(i)
  end
  clk.on_step = handle_tick
  clk:bpm_change(40)
  clk:start()
end

mp.handle_trigger = function () end
mp.emit_tick = function () end

function mp:on_trigger(f)
  mp.handle_trigger = f
end

function mp:on_tick(f)
  mp.emit_tick = f
  mp.dirty = true
end


function handle_tick()
  -- Pass a tick to each voice
  for i=1,8 do
    voices[i]:tick()
  end
  mp.emit_tick()
end


function mp:handle_key()

end


function mp:handle_enc()

end


function mp:screen_redraw(scr)
  scr.move(4, 8)
  scr.text(ti)
  scr.move(4, 16)
  scr.text(meadowphysics:get_state(1))
  scr.move(4, 24)
  scr.text(meadowphysics:get_state(2))
end


function mp:grid_redraw()

end


function mp:get_state(i)
  return "Voice " .. i .. ": " .. voices[i].current_step .. "/" .. voices[i].current_tick
end

return mp

