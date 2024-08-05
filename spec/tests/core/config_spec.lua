local assert = assert
---@cast assert -function,+nvl.test.luassert

local utils = require("nvl.core.utils")

describe("#unit", function()
	describe("nvl.core.config", function()
		describe("setup", function()
			it("sets config values", function()
				local config = require("nvl.core.config")

				local options = {
					development = {
						enabled = true,
					},
				}
				assert.False(config.development.enabled)
				config.setup(options)
				assert.True(config.development.enabled)
			end)
		end)
	end)
end)
