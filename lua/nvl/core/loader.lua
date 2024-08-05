---@class nvl.core.loader.module_exports
local loader = {}

---@alias nvl.core.loader.accessor_target {f:fun(...:any):any}

---@class nvl.core.loader.AccessorRegistry
---@field map table<string,nvl.core.loader.accessor_target>

---@class nvl.core.loader.PackageRegistry
---@field discovered table<string,nvl.core.package.Package>
---@field loaded table<string,nvl.core.package.Package>

---@class _nvl
---@field packages nvl.core.loader.PackageRegistry the package registry
---@field accessor nvl.core.loader.AccessorRegistry the accessor registry

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

-- local D = function(...)
-- 	if vim then
-- 		vim.print(...)
-- 	else
-- 		P(...)
-- 	end
-- end

local nvl_mt = {}
nvl_mt.__index = function(t, k)
	local v = rawget(t, k)
	if v then
		return v
	end

	local internal = rawget(t, "_")
	local accessor = internal.accessor.map[k]

	if type(accessor) == "table" then
		if type(accessor.f) == "function" then
			return accessor.f()
		end
	end
end

function nvl.init()
	nvl = setmetatable(nvl, nvl_mt)
	return nvl
end

---
---@param pkg nvl.core.package.Package
function nvl.add_package(pkg)
	nvl._.packages.discovered[pkg.name] = pkg
	nvl._.accessor.map[pkg.name] = {
		f = function()
			nvl._.packages.discovered[pkg.name] = nil
			local v = pkg:load()
			nvl._.packages.loaded[pkg.name] = v
			return v
		end,
	}
end

---comment
---@param rocks_trees nvl.core.rocks.RocksTrees
local function create_packages(rocks_trees)
	local Package = require("nvl.core.package").Package

	for _, tree in rocks_trees.iter() do
		for pack_name, pack_spec in tree:packages() do
			local pkg = Package(pack_name, pack_spec.path, {
				modules = {
					config = pack_spec.config,
					build = pack_spec.build,
				},
			})
			nvl.add_package(pkg)
		end
	end
end

---comment
function loader.entrypoint()
	local compat = require("nvl.core.compat")
	local config = require("nvl.core.config")
	local runtime = require("nvl.core.runtime")
	local rocks = require("nvl.core.rocks")

	local tree_root
	local package_root
	if vim then
		tree_root = runtime.joinpath(vim.fn.stdpath("data"), "lazy-rocks")
		package_root = "/share/lua/5.1/nvl/"
	end

	local rt = rocks.Tree.luarocks_factory(tree_root, package_root)
	rt.inject_lpath()
	create_packages(rt)
	nvl.init()

	nvl.config = config
	nvl.runtime = runtime
	return nvl
end

return loader
