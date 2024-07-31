local assert = assert
---@cast assert -function,+nvl.test.luassert

describe("#unit #nvl.inspect", function()
	it("converts a type into a string", function()
		local inspect = require("nvl.inspect")
		P(inspect)

		-- assert.equal("1", inspect(1))
	end)
end)
