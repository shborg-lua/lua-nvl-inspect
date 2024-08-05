---@class nvl.core.config.Config: nvl.core.config.ConfigOptions
local Config = {}

local utils = require("nvl.core.utils")
---@class nvl.core.config.mod_info
---@field [1] string The module name to import from
---@field [2]? string The symbol inside the module

---@class nvl.core.config.ConfigOptions
---@field development {enabled:boolean}
local defaults = (function()
	return {
		__class = { name = "nvl.config" },
		development = {
			enabled = false,
		},

		runtime = require("nvl.core.runtime"),

		exports = {
			--- @type table<string,nvl.core.config.mod_info>
			globals = {},

			enable_global = true,
		},
	}
end)()

---@type nvl.core.config.ConfigOptions
local options

---@param opts? nvl.core.config.ConfigOptions
function Config.setup(opts)
	options = utils.tbl_deep_extend("force", defaults, opts or {}) or {}
end

setmetatable(Config, {
	__index = function(_, key)
		if options == nil then
			return utils.deepcopy(defaults)[key]
		end
		---@cast options nvl.core.config.Config
		return options[key]
	end,
})

return Config
