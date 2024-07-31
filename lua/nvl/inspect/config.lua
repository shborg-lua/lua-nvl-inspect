---@class nvl.utils.Config: nvl.utils.ConfigOptions
local M = {}

---@class nvl.utils.ConfigOptions
local defaults = {

	exports = {
		globals = {},

		enable_global = true,
	},
}

---@type nvl.utils.ConfigOptions
local options

---@param opts? nvl.utils.ConfigOptions
function M.setup(opts)
	local o = {}
	for key, value in pairs(defaults) do
		o[key] = value
	end
	if type(opts) == "table" then
		o.exports.enable_global = opts.exports
				and type(opts.exports.enable_global) == "boolean"
				and opts.exports.enable_global
			or defaults.exports.enable_global
	end
	options = o
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			local o = {}
			for k, v in pairs(defaults) do
				o[k] = v
			end
			return o[key]
		end
		---@cast options nvl.utils.Config
		return options[key]
	end,
})

return M
