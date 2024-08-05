local assert = assert
---@cast assert -function,+nvl.test.luassert

local utils = require("nvl.core.utils")

describe("#unit", function()
	describe("nvl.core.runtime", function()
		describe("lua_version", function()
			it("returns the Lua version", function()
				local runtime = require("nvl.core.runtime")
				assert.String(runtime.lua_version())
				assert(runtime.lua_version():match("%d+%.%d+"))
			end)
		end)
		describe("is_nvl_rocks_tree_dir", function()
			it("returns the dir if a path is an nvl package path in a rocks tree", function()
				local runtime = require("nvl.core.runtime")
				local test_path = "/home/someuser/.local/share/nvim/lazy-rocks/lua-nvl-utils/share/lua/5.1/?/init.lua"
				assert.String(runtime.is_nvl_rocks_tree_dir(test_path))
			end)
		end)
		describe("is_dir", function()
			it("returns true if a file is a directory", function()
				local runtime = require("nvl.core.runtime")

				local git_root = require("nvl.core.utils").git_root()
				local test_path = runtime.joinpath(git_root, "Makefile")
				assert.False(runtime.is_dir(test_path))
				test_path = runtime.joinpath(git_root, "spec")
				assert.True(runtime.is_dir(test_path))
			end)
		end)
		describe("package.path.register", function()
			it("registers a package", function()
				local runtime = require("nvl.core.runtime")
				local git_root = require("nvl.core.utils").git_root()
				runtime.package.path.register(runtime.joinpath(git_root, "packages", "lua-nvl-inspect"))
				runtime.package.path.register(runtime.joinpath(git_root, "packages", "lua-nvl-utils"))

				assert(runtime.package.path._registered[1]:find("packages/lua-nvl-inspect", 1, true))
				assert(runtime.package.path._registered[2]:find("packages/lua-nvl-utils", 1, true))
			end)
		end)

		describe("package.path.scan", function()
			it("scans for nvl packages", function()
				local runtime = require("nvl.core.runtime")
				runtime.package.path.scan()
				assert(runtime.package.path._rpath[1]:find("packages/lua-nvl-inspect/lua/?.lua", 1, true))
				assert(runtime.package.path._rpath[2]:find("packages/lua-nvl-inspect/lua/?/init.lua", 1, true))
				assert(runtime.package.path._rpath[3]:find("packages/lua-nvl-utils/lua/?.lua", 1, true))
				assert(runtime.package.path._rpath[4]:find("packages/lua-nvl-utils/lua/?/init.lua", 1, true))
				assert(
					runtime.package.path._discovered["inspect"].config:find(
						"packages/lua-nvl-inspect/lua/nvl/inspect/config.lua",
						1,
						true
					)
				)
				assert(
					runtime.package.path._discovered["inspect"].full_path:find(
						"packages/lua-nvl-inspect/lua/nvl/inspect",
						1,
						true
					)
				)
				assert.equal("inspect", runtime.package.path._discovered["inspect"].name)

				-- Check second entry
				assert(
					runtime.package.path._discovered["utils"].config:find(
						"packages/lua-nvl-utils/lua/nvl/utils/config.lua",
						1,
						true
					)
				)
				assert(
					runtime.package.path._discovered["utils"].full_path:find(
						"packages/lua-nvl-utils/lua/nvl/utils",
						1,
						true
					)
				)
				assert.equal("utils", runtime.package.path._discovered["utils"].name)
			end)
		end)
		describe("joinpath", function()
			it("returns a joined path ", function()
				local runtime = require("nvl.core.runtime")
				assert.same("a" .. runtime.pathsep .. "b" .. runtime.pathsep .. "c", runtime.joinpath("a", "b", "c"))
			end)
		end)
	end)
end)
