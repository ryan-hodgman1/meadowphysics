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
local scale = include("meadowphysics/lib/engine/scale")
local g = grid.connect()
local MusicUtil = require "musicutil"

engine.name = 'PolyPerc'

local scale_names = {}

notes = { 69, 71, 72, 74, 76, 77, 79, 81}

local m = midi.connect()
m.event = function(data)
  clk:process_midi(data)
end

local function midi_notes_off()
  for i = 1, 8 do
    m:note_off(scale.notes[i], 100, params:get("midi_out_channel"))
  end
end

function handle_bang(e) -- Sound making thing goes here!
  if e.type == 'trigger' then
    engine.hz(MusicUtil.note_num_to_freq(scale.notes[e.voice]))
    make_midi_note(e.voice)
    crow.ii.jf.play_note((e.voice-60)/12,5)
  end
  if e.type == 'gate' and e.value == 1 then
    -- print("GATE HIGH", e.voice)
  end
  if e.type == 'gate' and e.value == 0 then
    -- print("GATE LOW", e.voice)
  end
end

function make_midi_note(track)
    m:note_on(scale.notes[track], 100, params:get("midi_out_channel"))
end

function init()

  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  scale:make_params()

  init_engine()

  meadowphysics.init(8)
  meadowphysics.on_bang = handle_bang
  meadowphysics.clock = clk

  params:add_separator()
  params:add_separator()


  clk.on_step = function ()
    midi_notes_off()
    meadowphysics:handle_tick()
    gridredraw()
    g:all(0)
  end
  clk:bpm_change(120)
  clk:start()

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


function gridredraw()
  meadowphysics:gridredraw()
end


function cleanup ()

end

function init_engine ()

  -- Engine Params
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
  
end


