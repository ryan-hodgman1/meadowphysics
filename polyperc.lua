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
local MusicUtil = require "musicutil"
local hs = include('lib/halfsecond')

engine.name = 'PolyPerc'

-- voicing

function trigger(note_num, hz, voice)
  engine.hz(hz)
end

function gate_high(note_num, hz, voice)
  engine.hz(hz)
end

function gate_low(note_num, hz, voice)
  engine.hz(hz)
end


function init_engine ()
  cs_AMP = controlspec.new(0,1,'lin',0,0.5,'')
  params:add{
    type="control",id="amp",controlspec=cs_AMP,
    action=function(x) engine.amp(x) end
  }

  cs_PW = controlspec.new(0,100,'lin',0,50,'%')
  params:add{
    type="control",id="pw",controlspec=cs_PW,
    action=function(x) engine.pw(x/100) end
  }

  cs_REL = controlspec.new(0.1,3.2,'lin',0,1.2,'s')
  params:add{
    type="control",id="release",controlspec=cs_REL,
    action=function(x) engine.release(x) end
  }

  cs_CUT = controlspec.new(50,5000,'exp',0,800,'hz')
  params:add{
    type="control",id="cutoff",controlspec=cs_CUT,
    action=function(x) engine.cutoff(x) end
  }

  cs_GAIN = controlspec.new(0,4,'lin',0,1,'')
  params:add{
    type="control",id="gain",controlspec=cs_GAIN,
    action=function(x) engine.gain(x) end
  }
  
  cs_PAN = controlspec.new(-1,1, 'lin',0,0,'')
  params:add{
    type="control",id="pan",controlspec=cs_PAN,
    action=function(x) engine.pan(x) end
  }
  hs.init()
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