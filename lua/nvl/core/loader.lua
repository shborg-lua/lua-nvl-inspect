---@class nvl.Loader
local loader = {}

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
---@param pkg nvl.Package
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

local function create_packages(runtime)
	local Package = require("nvl.core.package").Package

	for pack_name, pack_spec in pairs(runtime.package.path._discovered) do
		local pkg = Package(pack_name, pack_spec.full_path, {
			modules = {
				config = pack_spec.config,
				build = pack_spec.build,
			},
		})
		nvl.add_package(pkg)
	end
end

---comment
function loader.entrypoint()
	local compat = require("nvl.core.compat")
	local config = require("nvl.core.config")
	local runtime = require("nvl.core.runtime")

	print(string.format("loader.entrypoint development.enabled=%s", config.development.enabled))
	if config.development.enabled then
		local git_root = require("nvl.core.utils").git_root()
		runtime.package.path.register(runtime.joinpath(git_root, "packages", "nvl-inspect"))
		runtime.package.path.register(runtime.joinpath(git_root, "packages", "nvl-utils"))
	else
		for path in string.gmatch(package.path, "([^;]+)") do
			runtime.package.path.register(path)
		end
	end

	runtime.package.path.scan()
	runtime.package.path.inject()
	create_packages(runtime)
	nvl.init()

	nvl.config = config
	nvl.runtime = runtime
	return nvl
end

return loader
