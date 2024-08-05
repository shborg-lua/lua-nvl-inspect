---@class nvl.core.rocks.module_exports
local M = {}
local utils = require("nvl.core.utils")
local runtime = require("nvl.core.runtime")

---@class nvl.core.rocks.RocksTrees
local RocksTrees = {

	---@type table<string,nvl.core.rocks.Tree>
	_trees = {},
}

---@type nvl.core.rocks.Tree
local Tree = {} ---@diagnostic disable-line: missing-fields

---@class nvl.core.rocks.DiscoveredPackage
---@field name string
---@field path string
---@field config? string
---@field build? string

---@class nvl.core.rocks.PathRegistry
---@field registerd string[]
---@field discovered table<string,nvl.core.rocks.DiscoveredPackage>
---
---@class nvl.core.rocks._Tree
---@field packages nvl.core.rocks.PathRegistry

---@class nvl.core.rocks.TreeOptions

---Represents a rocks tree
---@class nvl.core.rocks.Tree
---@field path string
---@field name string
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
				-- discovered = {},
				-- loaded = {},
			},
		},
		name = name,
		path = path,
	}
	obj.__index = self
	return setmetatable(obj, self)
end

function Tree:lpath()
	local s = self.path .. "/lua/?.lua;"
	s = s .. self.path .. "/lua/?/init.lua"
	return s
end

-- -- Function to add a directory to package.path
-- function Tree:inject_lua_path()
-- 	package.path = table.concat(self._.packages.lua_path, ";") .. package.path
-- end
--
function Tree.lua_version()
	local version = _VERSION
	local digits = version:match("%d+%.%d+")
	return digits
end

function Tree.is_dir(path)
	assert(type(path) == "string", "runtime.is_dir: path must be a string")
	local f = io.open(path, "r")
	if not f then
		return false
	end
	local _, err, code = f:read(1)
	f:close()
	return (code == 21) or (err ~= nil)
end

function Tree.path_exists(path, kind)
	assert(type(path) == "string", "runtime.is_dir: path must be a string")
	assert(kind == "file" or kind == "directory", "runtime.is_dir: kind must be 'file' or 'directory'")

	local f = io.open(path, "r")
	if f then
		f:close()
		if kind == "file" then
			return not Tree.is_dir(path)
		elseif kind == "directory" then
			return Tree.is_dir(path)
		end
	end
	return false
end

-- Function to match the pattern with the Lua version
function Tree.match_nvl_dir(path)
	local version_digits = Tree.lua_version()
	local pattern = "(.*%/lua%-nvl%-(%w+)%/share%/lua%/" .. version_digits .. ")"
	return path:match(pattern)
end

function Tree:add(file, path)
	local pkg = {
		name = file,
		path = path,
		config = Tree.path_exists(path .. "/config.lua", "file") and path .. "/config.lua" or nil,
		cmd = (Tree.path_exists(path .. "/cmd.lua", "file") and path .. "/cmd.lua" or nil)
			or (Tree.path_exists(path .. "/cmd", "directory") and path .. "/cmd" or nil),
	}

	self._.packages[file] = pkg
end

function Tree.packages()
	return utils.factory.dict_iter(Tree._.packages)
end

function Tree.luarocks_factory_(opts)
	opts = opts or {}

	local Registry = require("nvl.core.package.registry")

	local kind = opts.kind or "lazy.nvim"

	local function lazy_nvim()
		local lazy_rocks = runtime.joinpath(vim.fn.stdpath("data"), "lazy-rocks")

		for pack_name, _ in Registry.packages() do
			local rt = Tree("repository: " .. pack_name, runtime.joinpath(lazy_rocks, "lua-nvl-" .. pack_name))
			local path = rt.path .. "/share/lua/5.1/nvl/" .. pack_name
			rt:add(pack_name, path)
			RocksTrees._trees[rt.name] = rt
		end
	end

	-- for path in string.gmatch(package.path, "([^;]+)") do
	-- 	runtime.package.path.register(path)
	-- end
	--
	if opts.kind == "lazy_nvim" then
		return lazy_nvim()
	end

	return RocksTrees
end

function Tree.luarocks_factory(tree_root, package_root)
	tree_root = tree_root or runtime.joinpath(utils.git_root(), "packages")
	package_root = package_root or "/lua/nvl/"
	local Registry = require("nvl.core.package.registry")

	for pack_name, _ in Registry.packages() do
		local rt = Tree(pack_name, runtime.joinpath(tree_root, "lua-nvl-" .. pack_name))
		local path = rt.path .. package_root .. pack_name
		rt:add(pack_name, path)
		RocksTrees._trees[rt.name] = rt
	end
	return RocksTrees
end

function RocksTrees.inject_lpath()
	for _, tree in pairs(RocksTrees._trees) do
		package.path = package.path .. ";" .. tree:lpath()
	end
end

M.RocksTrees = RocksTrees
M.Tree = Tree

return M
