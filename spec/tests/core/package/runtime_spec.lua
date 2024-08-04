local assert = assert
---@cast assert -function,+nvl.test.luassert

local utils = require("nvl.core.utils")

describe("#unit", function()
	describe("nvl.core.runtime", function()
		describe("package.path.register", function()
			it("registers a package", function()
				local runtime = require("nvl.core.runtime")
				local git_root = require("nvl.core.utils").git_root()
				runtime.package.path.register(runtime.joinpath(git_root, "packages", "nvl-inspect"))
				runtime.package.path.register(runtime.joinpath(git_root, "packages", "nvl-utils"))

				assert(runtime.package.path._registered[1]:find("packages/nvl-inspect", 1, true))
				assert(runtime.package.path._registered[2]:find("packages/nvl-utils", 1, true))
			end)
		end)

		describe("package.path.scan", function()
			local runtime = require("nvl.core.runtime")
			runtime.package.path.scan()
			assert(runtime.package.path._rpath[1]:find("packages/nvl-inspect/lua/?.lua", 1, true))
			assert(runtime.package.path._rpath[2]:find("packages/nvl-inspect/lua/?/init.lua", 1, true))
			assert(runtime.package.path._rpath[3]:find("packages/nvl-utils/lua/?.lua", 1, true))
			assert(runtime.package.path._rpath[4]:find("packages/nvl-utils/lua/?/init.lua", 1, true))
			assert(
				runtime.package.path._discovered["inspect"].config:find(
					"packages/nvl-inspect/lua/nvl/inspect/config.lua",
					1,
					true
				)
			)
			assert(
				runtime.package.path._discovered["inspect"].full_path:find(
					"packages/nvl-inspect/lua/nvl/inspect",
					1,
					true
				)
			)
			assert.equal("inspect", runtime.package.path._discovered["inspect"].name)

			-- Check second entry
			assert(
				runtime.package.path._discovered["utils"].config:find(
					"packages/nvl-utils/lua/nvl/utils/config.lua",
					1,
					true
				)
			)
			assert(
				runtime.package.path._discovered["utils"].full_path:find("packages/nvl-utils/lua/nvl/utils", 1, true)
			)
			assert.equal("utils", runtime.package.path._discovered["utils"].name)
		end)
		describe("joinpath", function()
			it("returns a joined path ", function()
				local runtime = require("nvl.core.runtime")
				assert.same("a" .. runtime.pathsep .. "b" .. runtime.pathsep .. "c", runtime.joinpath("a", "b", "c"))
			end)
		end)
	end)
end)
