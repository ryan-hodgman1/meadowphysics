-- meadowphysics
-- midi out capability
-- engine PolyPerc
--
-- key2  toggle scale mode^
-- key3  save meadowphysics
-- key3^ save scales
-- enc1  volume
-- enc2  root note
-- enc3  bpm
--

engine.name = "PolyPerc"

local hs = include("awake/lib/halfsecond")
local MeadowPhysics = require "meadowphysics/lib/mp"
local GridScales = require "meadowphysics/lib/gridscales"
local MusicUtil = require "musicutil"
local BeatClock = require "beatclock"

local active
local grid_clk
local screen_clk
local mp
local data_dir = "/home/we/dust/code/meadowphysics/data/"
local shift = 0
local gridscales
local g = grid.connect()
local midi_out_device
local midi_out_channel
local clk = BeatClock.new()
local notes = {}

local options = {
  OUTPUT = {
    "audio",
    "midi",
    "audio + midi"
  },
  STEP_LENGTH_NAMES = {
    "1 bar",
    "1/2",
    "1/3",
    "1/4",
    "1/6",
    "1/8",
    "1/12",
    "1/16",
    "1/24",
    "1/32",
    "1/48",
    "1/64"
  },
  STEP_LENGTH_DIVIDERS = {
    1,
    2,
    3,
    4,
    6,
    8,
    12,
    16,
    24,
    32,
    48,
    64
  }
}

local clk_midi = midi.connect()
clk_midi.event = function(data)
  clk:process_midi(data)
end

local notes_off_metro = metro.init()

local function all_notes_off()
  if (params:get("output") == 2 or params:get("output") == 3) then
    for _, a in pairs(active_notes) do
      midi_out_device:note_off(a, nil, midi_out_channel)
    end
  end
  active_notes = {}
end

local function step()
  all_notes_off()
  mp:clock()

  for _, n in pairs(notes) do
    local f = MusicUtil.note_num_to_freq(n)
    if (params:get("output") == 1 or params:get("output") == 3) then
      engine.hz(f)
    end

    if (params:get("output") == 2 or params:get("output") == 3) then
      midi_out_device:note_on(n, 96, midi_out_channel)
      table.insert(active_notes, n)
    end
  end
  notes = {} --why?

  if params:get("note_length") < 4 then
    notes_off_metro:start((60 / clk.bpm / clk.steps_per_beat / 4) *
    params:get("note_length"), 1)
  end
end

local function stop()
  all_notes_off()
end

local function reset_pattern()
  clk:reset()
end

function init()
  setup_params()

  -- meadowphysics
  mp = MeadowPhysics.loadornew(data_dir .. "mp.data")
  mp.mp_event = event

  -- gridscales
  gridscales = GridScales.loadornew(data_dir .. "gridscales.data")
  gridscales:add_params()

  -- metro
  grid_clk = metro.init()
  grid_clk.event = gridredraw
  grid_clk.time = 1 / 30

  screen_clk = metro.init()
  screen_clk.event = function() redraw() end
  screen_clk.time = 1 / 15

  midi_out_device = midi.connect(1)
  -- midi_out_device.event = function() end

  clk.on_step = step
  clk.on_stop = stop
  clk.on_select_internal = function() clk:start() end
  clk.on_select_external = reset_pattern
  clk:add_clock_params()
  params:set("bpm", 120)

  notes_off_metro.event = all_notes_off

  -- grid
  if g then mp:gridredraw(g) end

  screen_clk:start()
  grid_clk:start()
  clk:start()

  hs.init()
end

function event(row, state)
  if state == 1 then
    table.insert(notes, params:get("root_note") + gridscales:note(row))
  end
end

function redraw()
  if shift == 1 then
    draw_gridscales()
  else
    draw_mp()
  end
end

function draw_gridscales()
  gridscales:redraw()
end

function draw_mp()
  screen.clear()
  screen.aa(0)
  local offset_x = 24
  local offset_y = 16

  -- Draw position of each tracker
  for i = 1, 8 do
    if mp.position[i] >= 1 then
      local y = ((i - 1) * 4) + offset_y
      local x = 0
      x = ((mp.position[i] - 1) * 4) + offset_x
      screen.level(8)
      screen.move(x, y)
      screen.rect(x, y, 1, 1)
      screen.fill()
      screen.stroke()
    end
  end

  screen.update()
end

function draw_bpm()
  screen.clear()
  screen.aa(1)
  screen.move(64, 32)
  screen.font_size(32)
  screen.text(params:get("bpm"))
  screen.stroke()
  screen.update()
end

function g.key(x, y, z)
  if shift == 1 then
    gridscales:gridevent(x, y, z)
  else
    mp:gridevent(x, y, z)
  end
end

function gridredraw()
  if shift == 1 then
    gridscales:gridredraw(g)
  else
    mp:gridredraw(g)
  end
end

function enc(n, d)
  if n == 1 then
    mix:delta("output", d)
  elseif n == 2 then
    params:delta("root_note", d)
    draw_gridscales()
  elseif n == 3 then
    params:delta("bpm", d)
    draw_bpm()
  end
end

function key(n, z)
  if n == 1 and z == 1 then gridscales:set_scale(8) end
  if n == 2 and z == 1 then
    -- shift = shift ~ 1 --@todo this is probably not right
  elseif n == 3 and z == 1 then
    if shift == 1 then
      gridscales:save(data_dir .. "gridscales.data")
    else
      mp:save(data_dir .. "mp.data")
    end
  end
end

function setup_params()
  params:add{
    type = "option",
    id = "output",
    name = "output",
    options = options.OUTPUT,
    action = all_notes_off
  }

  params:add{
    type = "number",
    id = "midi_out_device",
    name = "midi out device",
    min = 1,
    max = 4,
    default = 1,
    action = function(value) midi_out_device = midi.connect(value) end
  }

  params:add{
    type = "number",
    id = "midi_out_channel",
    name = "midi out channel",
    min = 1,
    max = 16,
    default = 1,
    action = function(value)
      all_notes_off()
      midi_out_channel = value
    end
  }

  params:add_separator()

  params:add{
    type = "option",
    id = "step_length",
    name = "step length",
    options = options.STEP_LENGTH_NAMES,
    default = 4,
    action = function(value)
      clk.ticks_per_step = 96 / options.STEP_LENGTH_DIVIDERS[value]
      clk.steps_per_beat = options.STEP_LENGTH_DIVIDERS[value] / 4
      clk:bpm_change(clk.bpm)
    end
  }

  params:add{
    type = "option",
    id = "note_length",
    name = "note length",
    options = {"25%", "50%", "75%", "100%"},
    default = 4
  }

  -- engine
  params:add{
    type = "control",
    id = "amp",
    controlspec = controlspec.new(0, 1, 'lin', 0, 0.5, ''),
    action = engine.amp
  }

  params:add{
    type = "control",
    id = "pw",
    controlspec = controlspec.new(0, 100, 'lin', 0, 50, '%'),
    action = function(x) engine.pw(x / 100) end
  }

  params:add{
    type = "control",
    id = "release",
    controlspec = controlspec.new(0.1, 3.2, 'lin', 0, 1.2, 's'),
    action = engine.release
  }

  params:add{
    type = "control",
    id = "cutoff",
    controlspec = controlspec.new(50, 5000, 'exp', 0, 555, 'hz'),
    action = engine.cutoff
  }

  params:add{
    type = "control",
    id = "gain",
    controlspec = controlspec.new(0, 4, 'lin', 0, 1, ''),
    action = engine.gain
  }

  params:default()
  params:add_separator()

end