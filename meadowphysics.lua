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
--

local Beatclock = require "beatclock"
local clk = Beatclock.new()
local meadowphysics = include("meadowphysics/lib/engine/core")()
local g = grid.connect()


function init()

  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  meadowphysics.init(8)
  meadowphysics.on_bang = handle_bang

  clk.on_step = function ()
    meadowphysics:handle_tick()
    meadowphysics.should_redraw = true
    g:all(0)
  end
  clk:bpm_change(120)
  clk:start()
  redraw()
end

function handle_bang(e) -- Sound making thing goes here!
  if e.type == 'trigger' then
    --print("TRIGGER", e.voice)
    -- crow.ii.jf.play_note(e.voice/12 - 37/1200,8)
  end
  if e.type == 'gate' and e.value == 1 then
    -- print("GATE HIGH", e.voice)
  end
  if e.type == 'gate' and e.value == 0 then
    -- print("GATE LOW", e.voice)
  end
end

function enc()
  meadowphysics:handle_enc()
end

function key(n,z)
  meadowphysics:handle_key(n,z)
end

function g.key(x, y, z)
  meadowphysics:handle_grid_input(x, y, z)
end


function redraw()
  screen.clear()
  meadowphysics:draw()
  screen.update()
end

oled_r = metro.init()
oled_r.time = 0.05 -- 20fps (OLED max)
oled_r.event = function()
  redraw()
  if meadowphysics.should_redraw == true then
    redraw()
    meadowphysics.should_redraw = false
  end
end
oled_r:start()

function cleanup ()
  oled_r:stop()
  clk:stop()
end


