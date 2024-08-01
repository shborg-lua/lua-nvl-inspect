local config = require("nvl.inspect.config")
local inspect = require("nvl.inspect.modules.inspect")
local debug_print = require("nvl.inspect.modules.debug_print")

local function init()
	if config.exports.enable_global then
		_G.inspect = inspect
		_G.P = debug_print.dprint.P
	end
end
return setmetatable({}, {
	__call = function(t, ...)
		local init_done = t.init_done
		if not init_done then
			rawset(t, "init_done", true)
			init()
		end
		return inspect(...)
	end,
	__index = function(t, k)
		if k == "config" then
			return require("nvl.inspect.config")
		end
	end,
})
