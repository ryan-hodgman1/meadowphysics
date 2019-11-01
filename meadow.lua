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
  meadowphysics:init(8)
  meadowphysics:on_bang(handle_bang)
  meadowphysics:on_clock_tick(clock_tick)
  
  meadowphysics.voices[1].is_playing = true
  meadowphysics.voices[1].target_voices = { meadowphysics.voices[2]}
  meadowphysics.voices[2].target_voices = { meadowphysics.voices[1], meadowphysics.voices[3]}

  
  redraw()
end

function handle_bang(e) -- Sound making thing goes here!
  if e.type == 'trigger' then
    -- print("TRIGGER", e.voice)
  end
  if e.type == 'gate' and e.value == 1 then
    -- print("GATE HIGH", e.voice)
  end
  if e.type == 'gate' and e.value == 0 then
    -- print("GATE LOW", e.voice)
  end
end

function clock_tick()
  -- redraw()
end

function enc()
  meadowphysics:handle_enc()
end

function key(n,z)
  meadowphysics:handle_key(n,z)
end

function redraw()
  screen.clear()
  meadowphysics:screen_redraw()
  screen.update()
end

oled_r = metro.init()
oled_r.time = 0.05 -- 20fps (OLED max)
oled_r.event = function()
  redraw()
  if meadowphysics.should_redraw == true then
    -- redraw()
    -- meadowphysics.should_redraw = false
  end
end
oled_r:start()