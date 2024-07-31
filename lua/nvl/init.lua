return setmetatable({}, {
	__index = function(t, k)
		if k == "config" then
			return require("nvl.inspect.config")
		end
		return require("nvl.inspect.modules.inspect")
	end,
})
