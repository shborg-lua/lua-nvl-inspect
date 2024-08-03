---@class nvl.Config: nvl.ConfigOptions
local M = {}

---@class nvl.config.mod_info
---@field [1] string The module name to import from
---@field [2] string The symbol inside the module

---@class nvl.ConfigOptions
local defaults = (function(projects_root)
	return {

		development = {

			nvl_root = os.getenv("$HOME") .. "/dev/projects/lua-nvl",
			packages = {

				["nvl.inspect"] = projects_root .. "/lua-nvl-inspect",
			},
		},

		exports = {
			--- @type table<string,nvl.config.mod_info>
			globals = {},

			enable_global = true,
		},
	}
end)(os.getenv("$HOME") .. "/dev/projects")

---@type nvl.ConfigOptions
local options

---@param opts? nvl.ConfigOptions
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
		if opts.exports and type(opts.exports.globals) == "table" then
			for key, value in pairs(opts.exports.globals) do
				o.exports.globals[key] = value
			end
		end
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
		---@cast options nvl.Config
		return options[key]
	end,
})

return M
