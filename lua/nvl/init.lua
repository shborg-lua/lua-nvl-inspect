--- @class nvl.exports
local M = {}
local nvl

---comment
---@param options nvl.ConfigOptions
---@return unknown
local function setup(options)
	require("nvl.core.setup")(options)
	nvl = require("nvl.core.loader").entrypoint()
	return nvl
end

return setmetatable({}, {
	__index = function(t, k)
		if k == "setup" then
			return setup
		end
		if not nvl then
			nvl = require("nvl.core.loader").entrypoint()
		end
		return nvl
	end,
})
