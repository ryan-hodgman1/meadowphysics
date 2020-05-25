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

local meadowphysics = include("meadowphysics/lib/mp/core")()
local g = grid.connect()

-- voicing

local Ack = include("ack/lib/ack")
engine.name = 'Ack'

function trigger(note_num, hz, voice)
  engine.trig(voice-1)
end

function gate_high(note_num, hz, voice)
end

function gate_low(note_num, hz, voice)

end

function init_engine ()
  Ack.add_params()
  for i=1, meadowphysics.voice_count do
    Ack.add_channel_params(i)
  end
end




-- core stuff

function init()
  meadowphysics.init()
  params:add_separator()
  init_engine()
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
