--- @class nvl.exports
local M = {}
local nvl

local D = function(...)
	if vim then
		vim.print(...)
	else
		P(...)
	end
end
---comment
---@param options nvl.ConfigOptions
---@return unknown
local function setup(options)
	require("nvl.core.setup")(options)
	nvl = require("nvl.core.loader").entrypoint()
	return nvl
end

---FIXME: ensure that setup can be called without
---calling entrypoint
if not nvl then
	nvl = require("nvl.core.loader").entrypoint()
	nvl.setup = setup
end

return nvl
-- return setmetatable({}, {
-- 	__index = function(t, k)
-- 		if k == "setup" then
-- 			return setup
-- 		end
-- 		if not nvl then
-- 			nvl = require("nvl.core.loader").entrypoint()
-- 		end
-- 		return nvl
-- 	end,
-- })
