local utils = require("nvl.core.utils")
local uv = vim and vim.uv or require("luv")
local lfs = require("lfs")

--- @class nvl.Runtime
--- @field os_info nvl.OperatingSystem The operating system that Neorg is currently running under.
--- @field pathsep "\\"|"/" The operating system that Neorg is currently running under.
local runtime = {}

local os_uname = uv.os_uname ---@diagnostic disable-line: undefined-field

--- Gets the current operating system.
--- @return nvl.OperatingSystem
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

runtime.package = {
	path = {
		_rpath = {},
		_registered = {},
		_discovered = {},
	},
}
-- Function to add a directory to package.path
function runtime.package.path.add(directory)
	runtime.package.path._rpath[#runtime.package.path._rpath + 1] = directory .. "/?.lua;"
	runtime.package.path._rpath[#runtime.package.path._rpath + 1] = directory .. "/?/init.lua;"
end

-- Function to add a directory to package.path
function runtime.package.path.inject()
	package.path = table.concat(runtime.package.path._rpath, ";") .. package.path
end

-- Function to check if a path exists and is of a given type ('file' or 'directory')
local function path_exists(path, type)
	local attr = lfs.attributes(path)
	return attr and attr.mode == type
end

-- Function to add packages to package.path
function runtime.package.path.register(base_dir)
	runtime.package.path._registered[#runtime.package.path._registered + 1] = base_dir
end

-- Function to add packages to package.path
function runtime.package.path.scan()
	local function scandir(base_dir)
		local lua_dir = base_dir
		base_dir = runtime.joinpath(base_dir, "nvl")
		local ok, handle = pcall(lfs.dir, base_dir)
		-- print(string.format("scan.scandir base_dir=%s", base_dir))
		if not ok then
			return
		end
		for file in lfs.dir(base_dir) do
			if file ~= "." and file ~= ".." then
				local full_path = base_dir .. "/" .. file
				local attr = lfs.attributes(full_path)
				if attr and attr.mode == "directory" then
					runtime.package.path.add(lua_dir)
					local pkg_spec = {
						name = file,
						full_path = full_path,
						config = path_exists(full_path .. "/config.lua", "file") and full_path .. "/config.lua" or nil,
						cmd = (path_exists(full_path .. "/cmd.lua", "file") and full_path .. "/cmd.lua" or nil)
							or (path_exists(full_path .. "/cmd", "directory") and full_path .. "/cmd" or nil),
					}
					runtime.package.path._discovered[file] = pkg_spec
				end
			end
		end
	end

	for _, dir in ipairs(runtime.package.path._registered) do
		---TODO: make it work for luarock trees
		scandir(runtime.joinpath(dir, "lua"))
	end
	return runtime.package.path._discovered
end

runtime.os_info = os_info
runtime.pathsep = os_info == "windows" and "\\" or "/"

--- Concatenate directories and/or file paths into a single path with normalization
--- (e.g., `"foo/"` and `"bar"` get joined to `"foo/bar"`)
---
---@param ... string
---@return string
function runtime.joinpath(...)
	return (table.concat({ ... }, runtime.pathsep):gsub(runtime.pathsep .. runtime.pathsep .. "+", runtime.pathsep))
end

return runtime
