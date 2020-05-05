-- Meadowphysics grid ops

local g = grid.connect()
local grid = {}
local glyphs = {}

local rule_icons = {
  {0,0,0,0,0,0,0,0},-- o
  {0,24,24,126,126,24,24,0}, -- +
  {0,0,0,126,126,0,0,0}, -- -
  {0,96,96,126,126,96,96,0}, -- >
  {0,6,6,126,126,6,6,0}, -- <
  {0,102,102,24,24,102,102,0}, -- * rnd
  {0,120,120,102,102,30,30,0}, -- <> up/down
  {0,126,126,102,102,126,126,0} -- [] sync2 = 12
}

local function base_lighting(mp)
  for i = 1, #mp.voices do
    g:led(1, i,  1)
    g:led(3, i,  1)
    g:led(4, i,  1)
    g:led(6, i,  1)
    g:led(7, i,  1)
  end
end


function grid:draw(mp)
  g:all(0)
  if(mp.grid_mode == "voice") then
    base_lighting(mp)
    -- Show status of all voices
    for i = 1, #mp.voices do
      voice = mp.voices[i]
      if (voice.bang_type == "trigger") then
       g:led(6, i,  4)
      end
      if (voice.bang_type == "gate") then
       g:led(7, i,  4)
      end
      if (voice.is_playing) then
        g:led(3, i,  4)
      end
       -- speed (clock division)
      g:led(8 + voice.ticks_per_step, i,  4)
    end
    -- Light up the focused voice
    g:led(1, mp.grid_target_focus,  4)
    -- Show all the voices targeted by this voice
    for ti = 1, #mp.voices[mp.grid_target_focus].target_voices do
      if mp.voices[mp.grid_target_focus].target_voices[ti] == true then
        g:led(4, ti,  4)
      end
    end
  end

  if (mp.grid_mode == "pattern") then
	  for i = 1, #mp.voices do
	    local voice = mp.voices[i]
      -- show cycle range
      for ci = voice.min_cycle_length, voice.max_cycle_length do
        g:led(ci, i,  2)
      end
      -- show playhead
      if voice.is_playing then
  	    g:led(voice.current_step, i,  4)
      end
	  end
	end

  if (mp.grid_mode == "rule") then
    base_lighting(mp)
    local rule = mp.voices[mp.grid_target_focus].rule
    -- Draw the rule glyph
    local glyph = glyphs[rule]
    for yi = 1, 8 do
      for xi = 1, 10 do
        if(glyph[yi][xi] == 1) then
          g:led(xi+8, yi,  3)
        end
      end
    end
  end
  g:refresh()
end

glyphs["increment"] = {
  {0,0,0,0,0,0,0,0},
  {0,0,0,1,1,0,0,0},
  {0,0,0,1,1,0,0,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,0,0,1,1,0,0,0},
  {0,0,0,1,1,0,0,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["decrement"] ={
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["min"] ={
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,1,1,0},
  {0,0,0,0,0,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,0,0,0,0,1,1,0},
  {0,0,0,0,0,1,1,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["max"] ={
  {0,0,0,0,0,0,0,0},
  {0,1,1,0,0,0,0,0},
  {0,1,1,0,0,0,0,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,0,0,0,0,0},
  {0,1,1,0,0,0,0,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["random"] ={
  {0,0,0,0,0,0,0,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,0,0,1,1,0,0,0},
  {0,0,0,1,1,0,0,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["pole"] ={
  {0,0,0,0,0,0,0,0},
  {0,0,0,1,1,1,1,0},
  {0,0,0,1,1,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,1,1,0,0,0},
  {0,1,1,1,1,0,0,0},
  {0,0,0,0,0,0,0,0}
}

glyphs["stop"] ={
  {0,0,0,0,0,0,0,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,0,0,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,1,1,1,1,1,1,0},
  {0,0,0,0,0,0,0,0}
}

return grid