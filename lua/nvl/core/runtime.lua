local utils = require("nvl.core.utils")
local uv = vim and vim.uv or require("luv")

--- @class nvl.Runtime
--- @field os_info nvl.core.runtime.OperatingSystem The operating system that Neorg is currently running under.
--- @field pathsep "\\"|"/" The operating system that Neorg is currently running under.
--- @field lua_version string The running Lua version
local runtime = {}

local os_uname = uv.os_uname ---@diagnostic disable-line: undefined-field
--- @alias nvl.core.runtime.OperatingSystem "linux"|"mac"|"windows"|"wsl"|"wsl2"|"bsd"

---Gets the current operating system.
---@return nvl.core.runtime.OperatingSystem
local function get_os_info()
	local os = os_uname().sysname:lower()

	if os:find("windows_nt") then
		return "windows"
	elseif os == "darwin" then
		return "mac"
	elseif os == "linux" then
		local f = io.open("/proc/version", "r")
		if f ~= nil then
			local version = f:read("*all")
			f:close()
			if version:find("WSL2") then
				return "wsl2"
			elseif version:find("microsoft") then
				return "wsl"
			end
		end
		return "linux"
	elseif os:find("bsd") then
		return "bsd"
	end

	error("[nvl]: Unable to determine the currently active operating system!")
end

local os_info = get_os_info()

local function lua_version()
	local version = _VERSION
	local digits = version:match("%d+%.%d+")
	return digits
end

runtime.lua_version = lua_version()
runtime.os_info = os_info
runtime.pathsep = os_info == "windows" and "\\" or "/"

--- Concatenate directories and/or file paths into a single path with normalization
--- (e.g., `"foo/"` and `"bar"` get joined to `"foo/bar"`)
---
---@param ... string
---@return string?
function runtime.joinpath(...)
	local pathsep = runtime.pathsep or "/"
	return (table.concat({ ... }, pathsep):gsub(pathsep .. pathsep .. "+", pathsep))
end

return runtime
