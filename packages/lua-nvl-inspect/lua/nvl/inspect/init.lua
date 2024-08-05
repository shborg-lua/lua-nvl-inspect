--- @class nvl.inspect.exports
local M = {}

local unpack = table.unpack or unpack

local init_done

local config = require("nvl.inspect.config")
local inspect = require("nvl.inspect.modules.inspect")
local debug_print = require("nvl.inspect.modules.debug_print")

---@param o table Table to index
---@param ... any Optional keys (0 or more, variadic) via which to index the table
---@return any # Nested value indexed by key (if it exists), else nil
local function tbl_get(o, ...)
	local keys = { ... }
	if #keys == 0 then
		return nil
	end
	for i, k in ipairs(keys) do
		o = o[k] --- @type any
		if o == nil then
			return nil
		elseif type(o) ~= "table" and next(keys, i) then
			return nil
		end
	end
	return o
end

local function inject_globals()
	for global_name, mod_info in
		pairs(config.exports.globals --[[ @as table<string,nvl.inspect.config.mod_info> ]])
	do
		local ok, mod = pcall(require, mod_info[1])
		if ok then
			table.remove(mod_info, 1)
			if #mod_info > 0 then
				local v = tbl_get(mod, unpack(mod_info))
				if v then
					_G[global_name] = v
				end
			else 

					_G[global_name] = mod
			end
		end
	end
end

local function init()
	init_done = true
	if config.exports.enable_global then
		inject_globals()
		-- print("nvl.inspec: hooking into _G")
		-- _G.inspect = inspect
		-- _G.P = debug_print.dprint.P
	end
end

---@param options nvl.inspect.ConfigOptions
function M.setup(options)
	config.setup(options)
	init()
end

if not init_done then
	init()
end

return setmetatable(M, {
	__call = function(_, ...)
		return inspect(...)
	end,
	__index = function(_, k)
		if k == "config" then
			return require("nvl.inspect.config")
		end
	end,
})
