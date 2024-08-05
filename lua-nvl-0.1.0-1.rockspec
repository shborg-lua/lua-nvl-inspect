rockspec_format = "3.0"
package = "lua-nvl"
version = "0.1.0-1"
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
		["nvl.types"] = "lua/nvl/types.lua",
		["nvl.core.compat"] = "lua/nvl/core/compat.lua",
		["nvl.core.config"] = "lua/nvl/core/config.lua",
		["nvl.core.loader"] = "lua/nvl/core/loader.lua",
		["nvl.core.rocks"] = "lua/nvl/core/rocks.lua",
		["nvl.core.runtime"] = "lua/nvl/core/runtime.lua",
		["nvl.core.setup"] = "lua/nvl/core/setup.lua",
		["nvl.core.utils"] = "lua/nvl/core/utils.lua",
		["nvl.core.package"] = "lua/nvl/core/package/init.lua",
		["nvl.core.package.package"] = "lua/nvl/core/package/package.lua",
		["nvl.core.package.registry"] = "lua/nvl/core/package/registry.lua",
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
}
test = {
	type = "busted",
}
