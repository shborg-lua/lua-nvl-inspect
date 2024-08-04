---@class nvl.core.rocks.module_exports
local M = {}

---@type nvl.core.rocks.Tree
local Tree = {} ---@diagnostic disable-line: missing-fields

---@class nvl.core.rocks.PathRegistry
---@field lua_path string[]
---@field registerd string[]
---@field discovered string[]
---
---@class nvl.core.rocks._Tree
---@field packages nvl.core.rocks.PathRegistry

---@class nvl.core.rocks.TreeOptions

---Represents a rocks tree
---@class nvl.core.rocks.Tree
---@field _ nvl.core.rocks._Tree
Tree = setmetatable(Tree, {
	__call = function(t, ...)
		return t:new(...)
	end,
})
Tree.__index = Tree
M.Tree = Tree

---Creates a new Tree
---@param name string a name for the instance
---@param path string the local path to the tree
---@param opts nvl.core.rocks.TreeOptions
function Tree:new(name, path, opts)
	opts = opts or {}
	assert(type(name) == "string", "nvl.core.rocks.Tree.new: name must be a string")
	assert(type(path) == "string", "nvl.core.rocks.Tree.new: path must be a string")

	local obj = {
		_ = {
			packages = {
				lua_path = {},
				discovered = {},
				registerd = {},
			},
		},
		name = name,
		path = path,
	}
	obj.__index = self
	return setmetatable(obj, self)
end

-- Function to add a directory to package.path
function Tree:add(directory)
	self._.packages.lua_path[#self._.packages.lua_path + 1] = directory .. "/?.lua;"
	self._.packages.lua_path[#self._.packages.lua_path + 1] = directory .. "/?/init.lua;"
end

-- Function to add a directory to package.path
function Tree:inject_lua_path()
	package.path = table.concat(self._.packages.lua_path, ";") .. package.path
end

function Tree.lua_version()
	local version = _VERSION
	local digits = version:match("%d+%.%d+")
	return digits
end

-- Function to match the pattern with the Lua version
function Tree.match_nvl_dir(path)
	local version_digits = Tree.lua_version()
	local pattern = "(.*%/lua%-nvl%-(%w+)%/share%/lua%/" .. version_digits .. ")"
	return path:match(pattern)
end

return M
