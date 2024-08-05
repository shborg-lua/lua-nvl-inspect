---@class nvl.Config: nvl.ConfigOptions
local M = {}

local utils = require("nvl.core.utils")
---@class nvl.config.mod_info
---@field [1] string The module name to import from
---@field [2]? string The symbol inside the module

---@class nvl.ConfigOptions
---@field development {enabled:boolean}
local defaults = (function(projects_root)
	return {
		__class = { name = "nvl.config" },
		development = {
			enabled = false,
		},

		runtime = require("nvl.core.runtime"),

		exports = {
			--- @type table<string,nvl.config.mod_info>
			globals = {},

			enable_global = true,
		},
	}
end)()

---@type nvl.ConfigOptions
local options

---@param opts? nvl.ConfigOptions
function M.setup(opts)
	options = utils.tbl_deep_extend("force", defaults, opts or {}) or {}
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return utils.deepcopy(defaults)[key]
		end
		---@cast options nvl.Config
		return options[key]
	end,
})

return M
