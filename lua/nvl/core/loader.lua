---@class nvl.Loader
local loader = {}

local utils = require("nvl.core.utils")
---@alias nvl.accessor_target {f:fun(...:any):any}

---@class nvl.AccessorRegistry
---@field map table<string,nvl.accessor_target>

---@class nvl.PackageRegistry
---@field discovered table<string,nvl.Package>
---@field loaded table<string,nvl.Package>

---@class _nvl
---@field packages nvl.PackageRegistry the package registry
---@field accessor nvl.AccessorRegistry the accessor registry

---@class nvl
---@field _ _nvl internal
local nvl = {
	__class = { name = "nvl" },
	_ = {
		packages = {
			discovered = {},
			loaded = {},
		},
		accessor = {
			keys = {},
			map = {},
		},
	},
}

local nvl_mt = {}
nvl_mt.__index = function(t, k)
	print(string.format("nvl_mt.__index k=%s", k))

	local v = rawget(t, k)
	if v then
		return v
	end

	local internal = rawget(t, "_")
	local accessor = internal.accessor.map[k]

	if type(accessor) == "table" then
		if type(accessor.f) == "function" then
			print(string.format("accessor found for key=%s", k))
			return accessor.f()
		end
	end
end

function nvl.init()
	nvl = setmetatable(nvl, nvl_mt)
	return nvl
end

---
---@param pkg nvl.Package
function nvl.add_package(pkg)
	nvl._.packages.discovered[pkg.name] = pkg
	nvl._.accessor.map[pkg.name] = {
		f = function()
			return pkg
		end,
	}
end

-- ---@param name string symbol name
-- function NvlPackage:pack_symbol(name)
-- 	local sym = self.module[name]
--
-- 	if not sym then
-- 		-- TODO: handle error
-- 		print("symbol is nil")
-- 		return
-- 	end
--
-- 	return sym
-- end
--
-- ---comment
-- ---@param module_name string module name
-- function loader.pack_module(module_name)
-- 	return NvlPackage
-- end
--
local accessor = {}
local accessor_mt = {}

---comment
function loader.entrypoint()
	print("nvl: loader.entrypoint called")
	local compat = require("nvl.core.compat")
	local config = require("nvl.core.config")

	nvl.init()

	for pack_name, nvl_pack_path in pairs(config.development.packages) do
		print(string.format("discovered package %s", pack_name))

		local nvl_pack_name = pack_name:match("nvl%.(%w+)")
		package.path = package.path .. ";" .. nvl_pack_path .. "/lua/?.lua"
		package.path = package.path .. ";" .. nvl_pack_path .. "/lua/?/init.lua"
		local pkg = NvlPackage:new(nvl_pack_name, nvl_pack_path)
		P({
			">>>>>>>>>>",
			pkg = pkg.config,
		})
		nvl.add_package(pkg)
	end

	return nvl
	-- nvl.inspect = require("nvl.core.inspect")
end

return loader
