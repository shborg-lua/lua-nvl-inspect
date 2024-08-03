local M = {}
local config = require("nvl.core.config")

---comment
---@param options nvl.ConfigOptions
---@return boolean
function M.setup(options)
	config.setup(options)
	return true
end

return M
