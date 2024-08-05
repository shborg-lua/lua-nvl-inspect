local config = require("nvl.core.config")

---comment
---@param options nvl.core.config.ConfigOptions
---@return boolean
local function setup(options)
	config.setup(options)
	return true
end

return setup
