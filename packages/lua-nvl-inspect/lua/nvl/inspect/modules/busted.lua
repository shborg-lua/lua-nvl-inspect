local term = require("term")
-- local inspect = require("nvl.inspect.modules.inspect")

local colors

local isatty = io.type(io.stdout) == "file" and term.isatty(io.stdout)

local isWindows = package.config:sub(1, 1) == "\\"

if isWindows and not os.getenv("ANSICON") then
	colors = setmetatable({}, {
		__index = function()
			return function(s)
				return s
			end
		end,
	})
	isatty = false
else
	colors = require("term.colors")
end

return function(options)
	local busted = require("busted")
	if not busted or not busted.subscribe then
		return
	end
	local handler = require("busted.outputHandlers.base")()
	---@alias nvl.inspect.modules.debug_print.context_item {[1]:nvl.inspect.modules.debug_print.context,[2]:string}

	---@type table<nvl.inspect.modules.debug_print.context_item>
	local debug_msg_queue = {}

	local clock = function(ms)
		if ms < 1000 then
			return colors.cyan(("%7.2f"):format(ms))
		elseif ms < 10000 then
			return colors.yellow(("%7.2f"):format(ms))
		else
			return colors.bright(colors.red(("%7.2f"):format(ms)))
		end
	end

	handler.suiteEnd = function(suite, count, data)
		for _, value in ipairs(debug_msg_queue) do
			io.write(value[2])
		end

		io.flush()
		return nil, true
	end

	handler.testStart = function(element, parent)
		return nil, true
	end

	-- called by P. example: P("a message", "some value")
	---comment
	---@param data string
	---@param context nvl.inspect.modules.debug_print.context
	handler.dprint = function(data, context)
		table.insert(debug_msg_queue, { context, data })
	end

	-- TODO:
	-- Maby: do not io.write here. Instead find the node
	-- and add the debug message to the node
	handler.testEnd = function(element, parent, data)
		local node_list = parent.it or parent.describe
		for _, node in ipairs(node_list) do
			for index, value in
				ipairs(debug_msg_queue --[[ @as nvl.inspect.modules.debug_print.context_item[] ]])
			do
				local context = value[1].busted
				if node.name == context.text then
					table.remove(debug_msg_queue, index)

					-- format a message for htest output
					--
					--    3.73   OK 26: #unit #nvl.inspect nvl.inspect.modules.debug_print.formatter formatter.items formats a message
					-- it      msg: a message [ 01 {string}:'some value' ]

					local str = colors.green(string.format("%-8s", context.kind)) .. colors.yellow(value[2])
					io.write(str)
				end
			end
		end

		io.flush()
		return nil, true
	end

	-- busted.subscribe({ "suite", "end" }, handler.suiteEnd)
	-- busted.subscribe({ 'test', 'start' }, handler.testStart, { predicate = handler.cancelOnPending })
	busted.subscribe({ "test", "end" }, handler.testEnd, { predicate = handler.cancelOnPending })

	return handler
end
