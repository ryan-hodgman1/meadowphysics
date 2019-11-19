-- Meadowphysics grid ops

local gridbuf = require "gridbuf"
local gbuf = gridbuf.new(16, 8)

local grid = {}

function grid:draw()
  print("draw grid")
end

return grid