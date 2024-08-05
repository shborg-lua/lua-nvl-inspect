local assert = assert
---@cast assert -function,+nvl.test.luassert

describe("#unit #nvl.inspect", function()
	describe("nvl.inspect.modules.debug_print.debug_print", function()
		local debug_print = require("lua.nvl.inspect.modules.debug_print")
		describe("debug_print.dprint.P", function()
			it("formats a message", function()
				local dprint = debug_print.dprint
				assert.Table(dprint)
				assert.Function(dprint.P)
				dprint.P("a message")
				dprint.P("a message", "some value")
			end)
		end)
	end)

	describe("nvl.inspect.modules.debug_print.formatter", function()
		local debug_print = require("lua.nvl.inspect.modules.debug_print")
		describe("formatter.items", function()
			it("formats a message", function()
				local formatter = debug_print.formatter
				-- assert.equal("!NIL", formatter.items()[1])
				assert.equal("msg: test", formatter.items("test")[1])
				assert.equal("[ 01 {number}:'1' ]", formatter.items(1)[1])
				assert.equal("[ 01 {boolean}:'false' ]", formatter.items(false)[1])
				assert.equal("[ 01 {table}:'{ a = 1 }' ]", formatter.items({ a = 1 }, { single_line = true })[1])
				assert.equal("[ 01 {function}:'<function 1>' ]", formatter.items(function() end)[1])

				local co = coroutine.create(function() end)
				local thread_str = formatter.items(co)[1]
				assert(thread_str:find("%[ 01 {thread}:'thread: "))
			end)
		end)
	end)

	describe("nvl.inspect.config", function()
		it("returns the config", function()
			local config = require("nvl.inspect.config")
			-- P(inspect)

			assert.Table(config)
			assert.Function(config.setup)
			assert.Table(config.exports)
			assert.Boolean(config.exports.enable_global)
			assert.True(config.exports.enable_global)
		end)
	end)

	describe("nvl.inspect.setup", function()
		it("configure the library", function()
			require("nvl.inspect").setup({
				exports = {
					globals = {
						D = { "nvl.inspect.modules.debug_print", "dprint", "P" },
					},
				},
			})
			assert.Function(_G.D)
		end)
		it("creates a global debug printer named _G.P", function()
			local inspect = require("nvl.inspect")
			inspect(1)
			assert.Function(_G.P)
		end)
	end)

	describe("require nvl.inspect", function()
		it("exports as a global", function()
			local inspect = require("nvl.inspect")
			inspect(1)
			assert.Table(_G.inspect)
		end)
		it("creates a global debug printer named _G.P", function()
			local inspect = require("nvl.inspect")
			inspect(1)
			assert.Function(_G.P)
		end)
	end)

	describe("require nvl.inspect", function()
		it("exports as a global", function()
			local inspect = require("nvl.inspect")
			inspect(1)
			assert.Table(_G.inspect)
		end)
		it("converts a type into a string", function()
			local inspect = require("nvl.inspect")
			assert.equal("1", inspect(1))
		end)

		it("creates a global debug printer named _G.P", function()
			local inspect = require("nvl.inspect")
			inspect(1)
			assert.Function(_G.P)
		end)
	end)
end)