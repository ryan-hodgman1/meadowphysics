require 'busted.runner'()

local mp = require "mp_engine"

describe("Meadowphysics Lib", function()

  it("should not catch fire", function()
	assert.are.equal(15, 15)
  end)

end)