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

meadowphysics = include("meadowphysics/lib/engine/meadowphysics")

function init()
  meadowphysics:init()
  meadowphysics:on_trigger(handle_trigger)
  meadowphysics:on_tick(handle_clock)
  redraw()
  print("GO")
end

function handle_trigger(e) -- Sound making thing goes here!
  print("trigger")
end

function handle_clock()

end

function redraw()
  screen.clear()
  screen.move(4, 16)
  screen.text(meadowphysics:get_state(1))
  screen.move(4, 24)
  screen.text(meadowphysics:get_state(2))
  screen.update()
end


-- Redraw Loops
oled_r = metro.init()
oled_r.time = 0.05 -- 20fps (OLED max)
oled_r.event = function()
  if meadowphysics.dirty == true then
    redraw()
    meadowphysics.dirty = false
  end
end
oled_r:start()


function enc()
  meadowphysics:handle_enc()
end

function key(n,z)
  meadowphysics:handle_key(n,z)
end
