local utils = require("nvl.core.utils")
local uv = vim and vim.uv or require("luv")
local lfs = require("lfs")

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

-- Local function to scan a directory for Lua files
local function scan_dir(dir, paths)
	local ok, iter, dir_obj = pcall(lfs.dir, dir)
	if not ok then
		-- Skip this directory if there was an error opening it
		return
	end

	for file in iter, dir_obj do
		if file ~= "." and file ~= ".." then
			local full_path = dir .. "/" .. file
			local attr = lfs.attributes(full_path)
			if attr and attr.mode == "file" and file:match("%.lua$") then
				local package_name = full_path:gsub("/", "."):gsub("\\", "."):match("^(.-)%.lua$")
				local short_name = package_name:match("nvl%.(.*)")
				paths[short_name] = package_name
			elseif attr and attr.mode == "directory" then
				-- Recursively scan subdirectories
				scan_dir(full_path, paths)
			end
		end
	end
end

-- Function to scan package.path for nvl packages
local function scan_package_path()
	local paths = {}
	local search_paths = package.path

	local function process_path(path)
		-- Replace "?" with "nvl" in each search path to look for nvl packages
		local dir = path:gsub("?", "nvl")
		scan_dir(dir, paths)
	end

	for path in string.gmatch(search_paths, "[^;]+") do
		process_path(path)
	end

	return paths
end

--- @class nvl.Runtime
--- @field os_info nvl.OperatingSystem The operating system that Neorg is currently running under.
--- @field pathsep "\\"|"/" The operating system that Neorg is currently running under.
local runtime = {

	nvl_paths = scan_package_path(),
	os_info = os_info,
	pathsep = os_info == "windows" and "\\" or "/",
}

--- Concatenate directories and/or file paths into a single path with normalization
--- (e.g., `"foo/"` and `"bar"` get joined to `"foo/bar"`)
---
---@param ... string
---@return string
function runtime.joinpath(...)
	return (table.concat({ ... }, runtime.pathsep):gsub(runtime.pathsep .. runtime.pathsep .. "+", runtime.pathsep))
end

return runtime
