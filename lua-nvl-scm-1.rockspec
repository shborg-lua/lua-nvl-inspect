---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "lua-nvl"
version = "scm-1"
source = {
	url = "https://github.com/shborg-lua/lua-nvl/archive/refs/tags/" .. version .. ".zip",
}
description = {
	summary = "A library for Lua and Neovim",
	detailed = "`nvl` is WIP",
	homepage = "http://github.com/shborg-lua/lua-nvl",
	license = "MIT",
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",

	modules = {
		["nvl"] = "lua/nvl/init.lua",
		["nvl.core.config"] = "lua/nvl/core/config.lua",
		["nvl.core.modules"] = "lua/nvl/core/modules/init.lua",
	},
	copy_directories = {},
	platforms = {},
}
test_dependencies = {
	"busted",
	"busted-htest",
	"nlua",
	"luacov",
	"luacov-html",
	"luacov-multiple",
	"luacov-console",
	"luafilesystem",
	"lua-cjson",
}
test = {
	type = "busted",
}
