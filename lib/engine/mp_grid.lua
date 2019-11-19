-- Meadowphysics grid ops

local g = grid.connect()
local grid = {}

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

function grid:draw(mp)
  g:all(0)

  -- Draw position of voices
  for i = 1, #mp.voices do
    local voice = mp.voices[i]
    g:led(voice.current_step, i,  4)
  end


  g:refresh()
end

return grid