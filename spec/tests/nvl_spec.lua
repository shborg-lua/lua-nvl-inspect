local assert = assert
---@cast assert -function,+nvl.test.luassert

---
---@param nvl any
---@param expect any
local function validate_discovered_package(nvl, expect)
	local pkg = nvl._.packages.discovered[expect.name]
	assert.Table(nvl)
	assert.Table(pkg)
	assert.equal(expect.name, pkg.name)
	assert.String(pkg.path)
	assert(pkg.path:find("nvl%/" .. expect.name))
	assert.Table(pkg.modules)
	assert.String(pkg.modules.config)
end

---
---@param nvl any
---@param expect any
local function validate_loaded_package(nvl, expect)
	local pkg = nvl[expect.name]
	assert.Nil(nvl._.packages.discovered[expect.name])
	local pkg_ref = nvl._.packages.loaded[expect.name]
	assert.same(pkg, pkg_ref)
	assert.Table(pkg)
end

describe("#unit #nvl", function()
	describe("setup", function()
		it("sets config values", function()
			local config = require("nvl.core.config")
			local nvl = require("nvl")

			local options = {
				development = {
					enabled = true,
				},
			}
			assert.False(config.development.enabled)
			nvl.setup(options)
			assert.True(config.development.enabled)
		end)
	end)

	describe("nvl exports", function()
		local nvl = require("nvl").setup({
			development = {
				enabled = true,
			},
		})

		local packages = {
			inspect = false,
			utils = false,
		}
		for package_name, _ in pairs(packages) do
			it("exports package '" .. package_name .. "'", function()
				validate_discovered_package(nvl, {
					name = package_name,
				})
			end)
		end
	end)
	describe("nvl exports loaded packages", function()
		local nvl = require("nvl").setup({
			development = {
				enabled = true,
			},
		})
		local mod = nvl.inspect
		assert(mod)

		local packages = {
			inspect = false,
			utils = false,
		}
		for name, _ in pairs(packages) do
			local package_name = "nvl." .. name
			it("exports package '" .. package_name .. "'", function()
				validate_loaded_package(nvl, {
					name = name,
				})
			end)
		end
	end)
end)
