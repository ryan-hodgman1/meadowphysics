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

local meadowphysics = include("meadowphysics/lib/engine/meadowphysics")

function init()
  meadowphysics:init()
  meadowphysics:on_trigger(handle_trigger)
  meadowphysics:on_tick(handle_clock)
  redraw()
  print("GO")
end

function handle_trigger(e) -- Sound making thing goes here!
  print(e)
end

ti = 0
function handle_clock()
  ti = ti + 1
  -- print('clock')
  redraw()
end

function redraw()
  screen.clear()
  print('draw')
  screen.move(4, 8)
  screen.text(ti)
  screen.move(4, 16)
  screen.text(meadowphysics:get_state(1))
  screen.move(4, 24)
  screen.text(meadowphysics:get_state(2))
  -- meadowphysics:screen_redraw(screen)
  screen.update()
end

function enc()
  meadowphysics:handle_enc()
end

function key()
  meadowphysics:handle_key()
end
