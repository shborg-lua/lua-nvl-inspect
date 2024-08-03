local assert = assert
---@cast assert -function,+nvl.test.luassert

local utils = require("nvl.core.utils")

describe("#unit", function()
	describe("nvl.core.runtime", function()
		describe("joinpath", function()
			it("returns a lazy initialized Package", function()
				local runtime = require("nvl.core.runtime")
				P({
					"AAAAAAAAAAAAAAAAAAAAAAAA",
					runtime = runtime,
				})

				-- for package_name, _ in pairs(packages) do
				-- 	it("exports package '" .. package_name .. "'", function()
				-- 		validate_package(nvl, {
				-- 			name = package_name,
				-- 		})
				-- 	end)
				-- end
			end)
		end)
	end)
end)
