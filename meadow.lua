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
  redraw()
end

function handle_trigger(e) -- Sound making thing goes here!
  print(e)
end

function redraw()
  screen.clear()
  meadowphysics:screen_redraw()
  screen.update()
end

function enc()
  meadowphysics:handle_enc()
end

function key()
  meadowphysics:handle_key()
end
