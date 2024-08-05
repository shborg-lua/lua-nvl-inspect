local assert = assert
---@cast assert -function,+nvl.test.luassert

local utils = require("nvl.core.utils")

describe("#nvl.core.package", function()
	describe("Registry", function()
		local Registry = require("nvl.core.package.registry")
		it("provides version information on all NVL packages", function()
			local package_list = {}
			for pack_name, pack_data in Registry.packages() do
				package_list[pack_name] = pack_data
			end
			assert.Table(package_list)
			assert.Table(package_list.inspect)
			assert.String(package_list.inspect.version)
			assert.Table(package_list.utils)
			assert.String(package_list.utils.version)
		end)
	end)
end)
