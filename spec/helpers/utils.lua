local M = {}

local uv
if vim and vim.uv then
	uv = vim.uv
else
	uv = require("luv")
end

---@class feint.test.string_set_ret
---@field check fun(s:string)
---@field valid fun():boolean
---@field items table
---
---
---comment
---@param ... string
---@return feint.test.string_set_ret
function M.string_set(...)
	local words = { ... }
	local o = {
		items = {},
	}
	for _, word in ipairs(words) do
		o.items[word] = false
	end

	function o.check(s)
		for key, _ in pairs(o.items) do
			if s == key then
				o.items[key] = true
			end
		end
	end

	function o.valid()
		local all_valid = true
		for _, value in pairs(o.items) do
			if not value then
				all_valid = false
			end
		end

		return all_valid
	end
	return o
end

-- Creating a simple setTimeout wrapper
function M.set_timeout(timeout, callback)
	local timer = uv.new_timer()
	timer:start(timeout, 0, function()
		timer:stop()
		timer:close()
		callback()
	end)
	return timer
end

return M
