---@class nvl.core.utils.module_exports
---@field factory table
---@field table table
---@field NIL string
local M = {}

local uv = vim and vim.uv or require("luv")

M.NIL = "\0"

M.table = {}

--- Return a list of all keys used in a table.
--- However, the order of the return table of keys is not guaranteed.
---
---@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@generic T
---@param t table<T, any> (table) Table
---@return T[] : List of keys
function M.table.keys(t)
	assert(type(t) == "table", "M.table.keys: t must be a table")
	--- @cast t table<any,any>

	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

--- Return a list of all values used in a table.
--- However, the order of the return table of values is not guaranteed.
---
---@generic T
---@param t table<any, T> (table) Table
---@return T[] : List of values
function M.table.values(t)
	assert(type(t) == "table", "M.table.values: t must be a table")

	local values = {}
	for _, v in
		pairs(t --[[@as table<any,any>]])
	do
		table.insert(values, v)
	end
	return values
end

--- Enumerates key-value pairs of a table, ordered by key.
---
---@see Based on https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@generic T: table, K, V
---@param t T Dict-like table
---@return fun(table: table<K, V>, index?: K):K, V # |for-in| iterator over sorted keys and their values
---@return T
function M.table.spairs(t)
	assert(type(t) == "table", "M.table.spairs: t must be a table")
	--- @cast t table<any,any>

	-- collect the keys
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	table.sort(keys)

	-- Return the iterator function.
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end, t
end

---@generic T
---@param orig T
---@param cache? table<any,any>
---@return T
local function deepcopy(orig, cache)
	if orig == M.NIL then
		return M.NIL
	elseif type(orig) == "userdata" or type(orig) == "thread" then
		error("Cannot deepcopy object of type " .. type(orig))
	elseif type(orig) ~= "table" then
		return orig
	end

	--- @cast orig table<any,any>

	if cache and cache[orig] then
		return cache[orig]
	end

	local copy = {} --- @type table<any,any>

	if cache then
		cache[orig] = copy
	end

	for k, v in pairs(orig) do
		copy[deepcopy(k, cache)] = deepcopy(v, cache)
	end

	return setmetatable(copy, getmetatable(orig))
end

--- Returns a deep copy of the given object. Non-table objects are copied as
--- in a typical Lua assignment, whereas table objects are copied recursively.
--- Functions are naively copied, so functions in the copied table point to the
--- same functions as those in the input table. Userdata and threads are not
--- copied and will throw an error.
---
--- Note: `noref=true` is much more performant on tables with unique table
--- fields, while `noref=false` is more performant on tables that reuse table
--- fields.
---
---@generic T: table
---@param orig T Table to copy
---@param noref? boolean
--- When `false` (default) a contained table is only copied once and all
--- references point to this single copy. When `true` every occurrence of a
--- table results in a new copy. This also means that a cyclic reference can
--- cause `deepcopy()` to fail.
---@return T Table of copied keys and (nested) values.
function M.deepcopy(orig, noref)
	return deepcopy(orig, not noref and {} or nil)
end

--- Tests if `t` is an "array": a table indexed _only_ by integers
--- (potentially non-contiguous). If the indexes start from 1 and
--- are contiguous then the array is also a list.
--- @see M.islist()
---
--- Empty table `{}` is an array, too.
---
---@see https://github.com/openresty/luajit2#tableisarray
---
---@param t? table
---@return boolean `true` if array-like table, else `false`.
function M.isarray(t)
	if type(t) ~= "table" then
		return false
	end

	if M.islist(t) then
		return true
	end

	--- @cast t table<any,any>

	local count = 0

	for k, _ in pairs(t) do
		-- Check if the number k is an integer
		if type(k) == "number" and k == math.floor(k) then
			count = count + 1
		else
			return false
		end
	end

	if count > 0 then
		return true
	end
	return false
end

--- Tests if `t` is a "list": a table indexed _only_ by contiguous integers starting
--- from 1 (what lua-length calls a "regular array").
---
--- Empty table `{}` is a list, too.
---
---@see M.isarray()
---
---@param t? table
---@return boolean `true` if list-like table, else `false`.
function M.islist(t)
	if type(t) ~= "table" then
		return false
	end

	local j = 1
	for _ in
		pairs(t--[[@as table<any,any>]])
	do
		if t[j] == nil then
			return false
		end
		j = j + 1
	end

	return true
end

--- Checks if a table is empty.
---
---@see https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@param t table Table to check
---@return boolean `true` if `t` is empty
function M.tbl_isempty(t)
	assert(type(t) == "table", "M.tbl_isempty: expected t as table")
	return next(t) == nil
end

--- We only merge empty tables or tables that are not an array (indexed by integers)
local function can_merge(v)
	return type(v) == "table" and (M.tbl_isempty(v) or not M.isarray(v))
end

local function tbl_extend(behavior, deep_extend, ...)
	if behavior ~= "error" and behavior ~= "keep" and behavior ~= "force" then
		error('invalid "behavior": ' .. tostring(behavior))
	end

	if select("#", ...) < 2 then
		error("wrong number of arguments (given " .. tostring(1 + select("#", ...)) .. ", expected at least 3)")
	end

	local ret = {} --- @type table<any,any>

	for i = 1, select("#", ...) do
		local tbl = select(i, ...)
		assert(type(tbl) == "table", "M.tbl_extend: expected tbl as table")
		--- @cast tbl table<any,any>
		if tbl then
			for k, v in pairs(tbl) do
				if deep_extend and can_merge(v) and can_merge(ret[k]) then
					ret[k] = tbl_extend(behavior, true, ret[k], v)
				elseif behavior ~= "force" and ret[k] ~= nil then
					if behavior == "error" then
						error("key found in more than one map: " .. k)
					end -- Else behavior is "keep".
				else
					ret[k] = v
				end
			end
		end
	end
	return ret
end

--- Merges two or more tables.
---
---@see extend()
---
---@param behavior 'error'|'keep'|'force' Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... table Two or more tables
---@return table : Merged table
function M.tbl_extend(behavior, ...)
	return tbl_extend(behavior, false, ...)
end

--- Merges recursively two or more tables.
---
---@see M.tbl_extend()
---
---@generic T1: table
---@generic T2: table
---@param behavior 'error'|'keep'|'force' Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... T2 Two or more tables
---@return T1|T2 (table) Merged table
function M.tbl_deep_extend(behavior, ...)
	return tbl_extend(behavior, true, ...)
end

--- Deep compare values for equality
---
--- Tables are compared recursively unless they both provide the `eq` metamethod.
--- All other types are compared using the equality `==` operator.
---@param a any First value
---@param b any Second value
---@return boolean `true` if values are equals, else `false`
function M.deep_equal(a, b)
	if a == b then
		return true
	end
	if type(a) ~= type(b) then
		return false
	end
	if type(a) == "table" then
		--- @cast a table<any,any>
		--- @cast b table<any,any>
		for k, v in pairs(a) do
			if not M.deep_equal(v, b[k]) then
				return false
			end
		end
		for k in pairs(b) do
			if a[k] == nil then
				return false
			end
		end
		return true
	end
	return false
end

--- @class M.tbl_contains.Opts
--- @inlinedoc
---
--- `value` is a function reference to be checked (default false)
--- field predicate? boolean

--- Checks if a table contains a given value, specified either directly or via
--- a predicate that is checked for each value.
---
--- Example:
---
--- ```lua
--- M.tbl_contains({ 'a', { 'b', 'c' } }, function(v)
---   return M.deep_equal(v, { 'b', 'c' })
--- end, { predicate = true })
--- -- true
--- ```
---
---@see M.list_contains() for checking values in list-like tables
---
---@param t table Table to check
---@param value any Value to compare or predicate function reference
---@param opts? M.tbl_contains.Opts Keyword arguments |kwargs|:
---@return boolean `true` if `t` contains `value`
function M.tbl_contains(t, value, opts)
	assert(type(t) == "table", "M.tbl_contains: expected t as table")
	--- @cast t table<any,any>

	local pred --- @type fun(v: any): boolean?
	if opts and opts.predicate then
		-- M.validate({ value = { value, "c" } })
		pred = value
	else
		pred = function(v)
			return v == value
		end
	end

	for _, v in pairs(t) do
		if pred(v) then
			return true
		end
	end
	return false
end

--- Checks if a list-like table (integer keys without gaps) contains `value`.
---
---@see M.tbl_contains() for checking values in general tables
---
---@param t table Table to check (must be list-like, not validated)
---@param value any Value to compare
---@return boolean `true` if `t` contains `value`
function M.list_contains(t, value)
	assert(type(t) == "table", "M.list_contains: expected t as table")
	--- @cast t table<any,any>

	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function M.git_root()
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if not handle then
		return handle
	end
	local result = handle:read("*a")
	handle:close()
	result = result:gsub("%s+", "") -- Remove any trailing whitespace
	if result == "" then
		return nil, "Not a git repository"
	else
		return result
	end
end

--- Concatenate directories and/or file paths into a single path with normalization
--- (e.g., `"foo/"` and `"bar"` get joined to `"foo/bar"`)
---
---@param ... string
---@return string
function M.joinpath(...)
	return (table.concat({ ... }, "/"):gsub("//+", "/"))
end

function M.file_exists(file)
	return uv.fs_stat(file) ~= nil ---@diagnostic disable-line: undefined-field
end

return M
