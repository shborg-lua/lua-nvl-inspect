local utils = require("nvl.core.utils")
local uv = vim and vim.uv or require("luv")

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

function runtime.lua_version()
	local version = _VERSION
	local digits = version:match("%d+%.%d+")
	return digits
end

-- Function to match the pattern with the Lua version
function runtime.is_nvl_rocks_tree_dir(path)
	local version_digits = runtime.lua_version()
	local pattern = "(.*%/lua%-nvl%-(%w+)%/share%/lua%/" .. version_digits .. ")"
	return path:match(pattern)
	-- vim.print({
	-- 	">>>>>>>>>>>>>>>>>>>",
	-- 	m = m,
	-- })
end

function runtime.is_dir(path)
	assert(type(path) == "string", "runtime.is_dir: path must be a string")
	local f = io.open(path, "r")
	if not f then
		return false
	end
	local _, err, code = f:read(1)
	f:close()
	return (code == 21) or (err ~= nil)
end

local function path_exists(path, kind)
	assert(type(path) == "string", "runtime.is_dir: path must be a string")
	assert(kind == "file" or kind == "directory", "runtime.is_dir: kind must be 'file' or 'directory'")

	local f = io.open(path, "r")
	if f then
		f:close()
		if kind == "file" then
			return not runtime.is_dir(path)
		elseif kind == "directory" then
			return runtime.is_dir(path)
		end
	end
	return false
end

-- Function to add packages to package.path
function runtime.package.path.register(base_dir)
	runtime.package.path._registered[#runtime.package.path._registered + 1] = base_dir
end

local function create_pkg_spec(file, full_path)
	return {
		name = file,
		full_path = full_path,
		config = path_exists(full_path .. "/config.lua", "file") and full_path .. "/config.lua" or nil,
		cmd = (path_exists(full_path .. "/cmd.lua", "file") and full_path .. "/cmd.lua" or nil)
			or (path_exists(full_path .. "/cmd", "directory") and full_path .. "/cmd" or nil),
	}
end

-- function to add packages to package.path
function runtime.package.path.scan()
	local function scandir(base_dir)
		local lua_dir = base_dir
		base_dir = runtime.joinpath(base_dir, "nvl")
		print(string.format("scan.scandir base_dir=%s", base_dir))
		local handle = io.popen('ls -a "' .. base_dir .. '"')
		if not handle then
			return
		end
		for file in handle:lines() do
			if file ~= "." and file ~= ".." then
				local full_path = runtime.joinpath(base_dir, file)
				print(string.format("scan.scandir full_path=%s", full_path))
				local f = io.open(full_path, "r")
				if f then
					f:close()
					if runtime.is_dir(full_path) then
						runtime.package.path.add(lua_dir)
						runtime.package.path._discovered[file] = create_pkg_spec(file, full_path)
					end
				end
			end
		end
		handle:close()
	end

	for _, dir in ipairs(runtime.package.path._registered) do
		-- "lazy-rocks/lua-nvl-utils/share/lua/5.1/?.lua"
		print(string.format("registerd dir=%s", dir))
		---todo: make it work for luarock trees
		local full_path, nvl_pkg_name
		full_path, nvl_pkg_name = runtime.is_nvl_rocks_tree_dir(dir)

		print(string.format("match full_path=%s nvl_pkg_name=%s", full_path, nvl_pkg_name))
		if full_path and nvl_pkg_name then
			runtime.package.path._discovered[nvl_pkg_name] =
				create_pkg_spec(nvl_pkg_name, full_path .. "/nvl." .. nvl_pkg_name)
		else
			scandir(runtime.joinpath(dir, "lua"))
		end
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
