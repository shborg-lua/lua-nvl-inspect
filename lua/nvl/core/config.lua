---@class nvl.Config: nvl.ConfigOptions
local M = {}

local utils = require("nvl.core.utils")

--- @class nvl.ConfigOptions
--- @field os_info nvl.OperatingSystem The operating system that Neorg is currently running under.
--- @field pathsep "\\"|"/" The operating system that Neorg is currently running under.
local defaults = (function(projects_root)
	return {
		__class = { name = "nvl.config" },

		runtime = require("nvl.core.runtime"),

		development = {
			nvl_root = projects_root .. "/dev/projects/lua-nvl",
			packages = {
				["nvl.utils"] = projects_root .. "/lua-nvl-utils",
				["nvl.inspect"] = projects_root .. "/lua-nvl-inspect",
			},
		},

		exports = {
			--- @type table<string,nvl.config.mod_info>
			globals = {},

			enable_global = true,
		},
	}
end)(os.getenv("HOME") .. "/dev/projects")

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
