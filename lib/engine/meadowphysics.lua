-- 

local bc = require "beatclock"
local clk = bc.new()
local g = grid.connect()
local gridbuf = require "gridbuf"
local gbuf = gridbuf.new(16, 8)

local mp = {}
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
function mp:on_trigger(f)
  mp.handle_trigger = f
end


function handle_tick()
  print("-------------------------------------------------------------------------")
  -- Pass a tick to each voice
  for i=1,8 do
    voices[i]:tick()
  end
  print('Voice', 1, "step:", voices[1].current_step, voices[1].current_tick)
  print('Voice', 2, "step:", voices[1].current_step, voices[1].current_tick)
  
  print(" ")
end


function handle_key()

end


function handle_enc()

end


function mp:screen_redraw()

end


function mp:grid_redraw()

end


return mp

