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

local Ack = include("ack/lib/ack")
engine.name = 'Ack'


local scale_names = {}
notes = {}
local active_notes = {}

local m = midi.connect()
m.event = function(data)
  clk:process_midi(data)
end

local function all_notes_off()
  if (params:get("output") == 2 or params:get("output") == 3) then
    for _, a in pairs(active_notes) do
      midi_out_device:note_off(a, nil, meadowphysics.midi_out_channel)
    end
  end
  active_notes = {}
end

function handle_bang(e) -- Sound making thing goes here!
  if e.type == 'trigger' then
    -- print("TRIGGER", e.voice)
    -- crow.ii.jf.play_note(e.voice/12 - 37/1200,8)
    engine.trig(e.voice-1)
    make_note(e.voice-1)
    -- trigger midi

  end
  if e.type == 'gate' and e.value == 1 then
    -- print("GATE HIGH", e.voice)
  end
  if e.type == 'gate' and e.value == 0 then
    -- print("GATE LOW", e.voice)
  end
end

function make_note(track)
    -- local midich = params:get(track .."_midi_chan")
    local midi_channel = 1
    -- currently 1 == C3 (60 = 59 + 1)
    -- midi_note = (59 + n) + ( (oct - 3) * 12 )
    midi_note = track
    m:note_on(midi_note,100,midi_channel)
    table.insert(active_notes, midi_note)
end

function init()

  crow.ii.pullup(true)
  crow.ii.jf.mode(1)

  meadowphysics.init(8)
  meadowphysics.on_bang = handle_bang



  params:add_separator()
  params:add_separator()
  Ack.add_params()
  for i=1, meadowphysics.voice_count do
    Ack.add_channel_params(i)
  end

  print(engine.list_commands())

  clk.on_step = function ()
    meadowphysics:handle_tick()
    meadowphysics.should_redraw = true
    g:all(0)
  end
  clk:bpm_change(120)
  clk:start()

  -- Test properties
  -- meadowphysics.voices[1].is_playing = true
  -- meadowphysics.voices[1].target_voices = {
  --   meadowphysics.voices[1],
  --   meadowphysics.voices[2]
  -- }
  -- meadowphysics.voices[1].ticks_per_step = 1
  -- meadowphysics.voices[2].ticks_per_step = 1
  -- meadowphysics.voices[4].is_playing = true
  -- meadowphysics.voices[4].target_voices = {
  --   meadowphysics.voices[4],
  --   meadowphysics.voices[5]
  -- }
  -- meadowphysics.voices[4].ticks_per_step = 2
  -- meadowphysics.voices[5].ticks_per_step = 2
  -- meadowphysics.voices[7].is_playing = true
  -- meadowphysics.voices[7].target_voices = {
  --   meadowphysics.voices[7],
  --   meadowphysics.voices[8]
  -- }
  -- meadowphysics.voices[7].ticks_per_step = 4
  -- meadowphysics.voices[8].ticks_per_step = 4




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


