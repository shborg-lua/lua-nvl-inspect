---@class nvl.inspect.modules.debug_print.exports
local M = {}

local is_loaded
local busted_handler

M.NIL = "!NIL"
M.headline_fill_char = "-"
M.headline_width = 40

local inspect = require("nvl.inspect.modules.inspect")
local formatter = {}

---comment
---@param index number
---@param tag string
---@param obj any
---@return string
function formatter.value_tuple(index, tag, obj)
	return string.format("[ %02d {%s}:'%s' ]", index, tag, obj)
end

---comment
---@param index number
---@param obj any
---@param opts? nvl.inspect.var_arg_first
---@return string|nil
function formatter.value(index, obj, opts)
	opts = opts or {}
	if obj == nil then
		return formatter.value_tuple(index, type(nil), M.NIL)
	elseif type(obj) == "table" then
		local s = formatter.value_tuple(index, type(obj), inspect(obj))
		if opts.single_line then
			s = s:gsub("%s+", " "):gsub("\n", "")
		end
		return s
	elseif type(obj) == "function" then
		return formatter.value_tuple(index, type(obj), inspect(obj))
	elseif type(obj) == "string" then
		return formatter.value_tuple(index, type(obj), obj)
	else
		return formatter.value_tuple(index, type(obj), tostring(obj))
	end
end

---comment
---@param title string
---@return string
function formatter.header(title)
	local headline_part = string.rep(M.headline_fill_char, M.headline_width / 2)
	return string.format("%s %-20s %s", headline_part, title, headline_part)
end

---comment
---@param msg string
---@return string
function formatter.message(msg)
	return string.format("msg: %s", msg)
end

---comment
---@param msg? string
---@param opts? nvl.inspect.var_arg_first
---@param ... any 1st arg string as message or any type, rest any type
---@return string[]
function formatter.items(msg, opts, ...)
	local argv = select("#", ...) > 0 and { ... } or {}
	local columns = {}

	if msg == nil then
		return { M.NIL }
	end

	if type(msg) == "string" then
		table.insert(columns, formatter.message(msg))
	else
		table.insert(argv, 1, msg)
	end
	if #argv > 0 then
		for i = 1, #argv, 1 do
			local v = argv[i]
			table.insert(columns, formatter.value(i, v, opts))
		end
	end
	return columns
end

---comment
---@param columns string[]
---@return string
function formatter.output(columns)
	local lines = {}
	-- lines[#lines + 1] = formatter.header("NVL DPRINT")
	lines[#lines + 1] = table.concat(columns, " ")
	return table.concat(lines, "\n") .. "\n"
end

---@class nvl.inspect.modules.debug_print.dprint
local dprint = {}
---@alias nvl.inspect.modules.debug_print.context {busted:{kind:string?,text:string?},function_name:string?}

---io.write interface
---@class nvl.inspect.modules.debug_print.writer
---@field write fun(data:string,context:nvl.inspect.modules.debug_print.context)
---
---
local writer = {

	---@type nvl.inspect.modules.debug_print.writer
	busted = {},
	---@type nvl.inspect.modules.debug_print.writer
	default = {},
}

function writer.default.write(data, context)
	io.write(data)
	io.flush()
end

function writer.busted.write(data, context)
	if busted_handler then
		busted_handler(data, context)
	end
end

local function has_busted()
	local ok, busted = pcall(require, "busted")
	if not ok then
		return false
	end
	return true
end

function dprint._get_busted_context(source, currentline)
	-- Read the source file into a list of lines
	local file = io.open(source, "r")
	local retval = {}
	if file then
		local lines = {}
		for line in file:lines() do
			table.insert(lines, line)
		end
		file:close()

		-- Search backwards from the current line for describe or it
		for i = currentline, 1, -1 do
			local line = lines[i]
			local describe_match = line:match([[%s*describe%s*%(["'](.*)["'],.*%)]])
			local it_match = line:match([[%s*it%s*%(["'](.*)["'],.*%)]])
			if describe_match then
				retval.text = describe_match
				retval.kind = "describe"
				break
			elseif it_match then
				retval.text = it_match
				retval.kind = "it"
				break
			end
		end
	end
	return retval
end

---comment
---@alias nvl.inspect.var_arg_first {msg?:string, single_line?:boolean}
---
---comment
---@param opts? nvl.inspect.var_arg_first
---@param ... any 1st arg string as message or any type, rest any type
function dprint._P(opts, ...)
	local msg = type(opts) == "table" and opts.msg and opts.msg or opts

	local info = debug.getinfo(2, "nSl")
	local source = info.short_src or "unknown source"
	local currentline = info.currentline or "unknown line"
	local context = {}
	context.busted = {}
	context.function_name = info.function_name

	context.busted = dprint._get_busted_context(source, currentline)
	local columns = formatter.items(msg, opts, ...)
	local out = writer.default
	if context.busted.kind then
		out = writer.busted
	end
	out.write(formatter.output(columns), context)
end
---comment
---@param msg? string
---@param ... any 1st arg string as message or any type, rest any type
function dprint.P(msg, ...)
	dprint._P({ msg = msg, single_line = true }, ...)
end

---comment
---@param msg? string
---@param ... any 1st arg string as message or any type, rest any type
function dprint.PL(msg, ...)
	dprint._P({ msg = msg, single_line = false }, ...)
end

M.formatter = formatter
M.dprint = dprint

if not is_loaded then
	if has_busted() then
		local busted = require("nvl.inspect.modules.busted")({})
		if busted then
			busted_handler = busted.dprint
		end
	end
	is_loaded = true
end
return M
