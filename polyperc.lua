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
local MusicUtil = require "musicutil"

engine.name = 'PolyPerc'


local scale_names = {}

notes = {
  69,
  71,
  72,
  74,
  76,
  77,
  79,
  81
}

-- local active_notes = {}

local m = midi.connect()
m.event = function(data)
  clk:process_midi(data)
end

local function all_notes_off()
  for i = 1, 8 do
    m:note_off(params:get("voice_" .. i .. "__midi_note"), 100, params:get("midi_out_channel"))
  end
end

function handle_bang(e) -- Sound making thing goes here!
  if e.type == 'trigger' then
    engine.hz(MusicUtil.note_num_to_freq(notes[e.voice]))
    make_note(e.voice)
    crow.ii.jf.play_note((e.voice-60)/12,5)
  end
  if e.type == 'gate' and e.value == 1 then
    -- print("GATE HIGH", e.voice)
  end
  if e.type == 'gate' and e.value == 0 then
    -- print("GATE LOW", e.voice)
  end
end

function make_note(track)
    midi_note = params:get("voice_" .. track .. "__midi_note")
    m:note_on(midi_note, 100, params:get("midi_out_channel"))
end

function init()

  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  -- meadowphysics.init(16)
  meadowphysics.init(8)
  meadowphysics.on_bang = handle_bang
  meadowphysics.clock = clk

  params:add_separator()
  params:add_separator()

  clk.on_step = function ()
    all_notes_off()
    meadowphysics:handle_tick()
    meadowphysics.should_redraw = true
    g:all(0)
  end
  clk:bpm_change(120)
  clk:start()
  redraw()

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

gridredrawtimer = metro.init(function() gridredraw() end, 0.02, -1)
gridredrawtimer:start()

oled_r = metro.init()
oled_r.time = 0.05 -- 20fps (OLED max)
oled_r.event = function()
  redraw()
  -- if meadowphysics.should_redraw == true then
  --   redraw()
  --   meadowphysics.should_redraw = false
  -- end
end
oled_r:start()

function cleanup ()
  oled_r:stop()
  clk:stop()
end


