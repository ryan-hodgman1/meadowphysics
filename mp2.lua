--
--   m e a d o w p h y s i c s
--
--   a grid-enabled
--   rhizomatic
--   cascading counter
--
--
--   *----
--        *-----
--            *---
--      *-----
--
--c

print(" ")
print("----------------*--------")
print("m e a d o w p h y s i c s")
print("------*------------------")
print(" ")

local BeatClock = require "beatclock"
local MeadowPhysics = include("meadowphysics/lib/mp_engine")
local data_dir = "/home/we/dust/code/meadowphysics/data/"
mp = {}
local dirty = false
local clk = BeatClock.new()
local g = grid.connect()
local bpm = 120

local meadowphysics = {}


function init()
  mp = MeadowPhysics.loadornew(data_dir .. "mp.data")
  mp.mp_event = trigger_voice -- called whenever a voice completes a cycle
  dirty = true
  clk.on_step = step
  clk:start()
  clk:bpm_change(bpm)
end

function trigger_voice(voice) -- playback function here
  print(voice)
end

function step()
  -- mp:clock()
  dirty = true
  if g then mp:gridredraw(g) end
end

function key(n, z)
  print('key down')
  mp:save(data_dir .. "mp.data")
end

function enc(n, d)
  print("enc")
end


function g.key(x, y, z)
  if shift == 1 then
    gridscales:gridevent(x, y, z)
  else
    mp:gridevent(x, y, z)
  end
end


function redraw()
  screen.clear()
  screen.aa(0)
  local offset_x = 32
  local offset_y = 16

  -- Draw position of each tracker on the norns screen
  for i = 1, 8 do
    if mp.position[i] >= 1 then
      local y = ((i - 1) * 4) + offset_y
      local x = 0
      x = ((mp.position[i] - 1) * 4) + offset_x
      if mp.position[i] == 1 then
        screen.level(16)
      else
        screen.level(4)
      end
      screen.move(x, y)
      screen.rect(x, y, 1, 1)
      screen.fill()
      screen.stroke()
    end
  end
  screen.update()
end


-- Redraw Loops
oled_r = metro.init()
oled_r.time = 0.05 -- 20fps (OLED max)
oled_r.event = function()
  if dirty == true then
    redraw()
    dirty = false
  end
end
oled_r:start()


