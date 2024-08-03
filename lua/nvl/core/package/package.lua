local Package = {}

local accessor = {}

---comment
---@param self nvl.core.Package
---@return string
function accessor.module_root_path(self)
	assert(type(self) == "table", "accessor.module_root_path: self must be a table")
	return self.path .. "/lua/nvl/" .. self.name
end

--- @class nvl.core.Package
--- @field name string the name of the package
--- @field path string the file path of the package
--- @field config table the configuration table for this package
Package = setmetatable({}, {
	__call = function(t, ...)
		return t:new(...)
	end,
})

local PackageMt = {}
PackageMt.__index = function(t, k)
	print(string.format("PackageMt.__index k=%s", k))
	local v = rawget(t, k) or rawget(Package, k)
	if v then
		return v
	end

	local as = accessor[k]
	if type(as) == "function" then
		as(t)
	end

	-- load module when requested
	if k == "module" then
		return t:load_module("init")
	end

	if k == "config" then
		return t:load_module("config")
	end
end

---@param name string module name
---@param path string module repository path
function Package:new(name, path)
	local obj = {
		name = name,
		path = path,
	}

	obj.__index = self
	return setmetatable(obj, PackageMt)
end

---comment
---@param module_name string
---@return string
function Package:module_path(module_name)
	assert(type(module_name) == "string", "NvlPackage.module_path: module_name must be a string")
	return self.path .. "/lua/nvl/" .. self.name .. "/" .. module_name
end

---comment
---@param filename string the module name without extension
---@return table|nil
function Package:load_module(filename)
	assert(type(filename) == "string", "NvlPackage.load_module: filename must be a string")
	local path_module = self:module_path(filename .. ".lua")

	local factory = loadfile(path_module, "bt")
	if type(factory) == "function" then
		P({
			"SSSSSSSSSSSSSSSSSSSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
			mod = factory(),
		})
		return factory()
	end
end

return Package
