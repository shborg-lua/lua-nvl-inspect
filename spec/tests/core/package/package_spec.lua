local assert = assert
---@cast assert -function,+nvl.test.luassert

---
---@param nvl any
---@param expect any
local function validate_package(nvl, expect)
	local pkg = nvl[expect.name]
	assert.Table(nvl)
	assert.Table(pkg)
	assert.equal(expect.name, pkg.name)

	assert.String(pkg.path)
	assert(pkg.path:find("lua%-nvl%-" .. expect.name))

	assert.Table(pkg.config)
	assert.Function(pkg.config.setup)
	local module = pkg.module
	P({
		"SETUP----------------",
		module = module,
	})
	assert.Table(pkg.module)
end
local utils = require("nvl.core.utils")

describe("#unit", function()
	describe("nvl.core.package", function()
		describe("Package", function()
			describe("new", function()
				it("returns a lazy initialized Package", function()
					local Package = require("nvl.core.package").Package
					local config = require("nvl.core.config")

					local pkg = Package(
						"inspect",
						config.runtime.joinpath(utils.git_root(), "build", "2.1.0-beta3", "share", "lua", "5.1")
					)

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
end)
