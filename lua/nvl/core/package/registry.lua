---@class nvl.core.package.RegistryPackage
---@field name string
---@field version string

---@class nvl.core.package.Registry
---@field _packages table<string,nvl.core.package.RegistryPackage>
local Registry = {
	format = "lua",
	_packages = {},
}

local utils = require("nvl.core.utils")
local runtime = require("nvl.core.runtime")

local init_done

local function git_root()
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if not handle then
		return handle
	end
	local result = handle:read("*a")
	handle:close()
	result = result:gsub("%s+", "") -- Remove any trailing whitespace
	if result == "" then
		return nil, "Not a git repository"
	else
		return result
	end
end

-- Helper function to extract package name and version from rockspec filename
function Registry.parse_rockspec_filename(filename)
	local name, major, minor, patch, build

	-- Match versioned rockspec filenames
	name, major, minor, patch, build = filename:match("lua%-nvl%-(%w+)%-(%d+)%.(%d+)%.(%d+)%-(%d+)%.rockspec")
	if name then
		local version = table.concat({ major, minor, patch }, ".") .. "-" .. build
		return name, version
	end

	-- Ignore scm rockspec filenames for version extraction
	return nil, nil
end

-- Function to scan the packages directory and build the registry data
function Registry.update()
	local data = {
		meta = {
			version = "1.0",
		},
		packages = {},
	}
	local lfs = require("lfs")

	for dir in lfs.dir("packages") do
		if dir ~= "." and dir ~= ".." then
			local package_dir = "packages/" .. dir
			for file in lfs.dir(package_dir) do
				if file:match("%.rockspec$") then
					local full_path = package_dir .. "/" .. file
					local name, version = Registry.parse_rockspec_filename(file)
					if name and version then
						data.packages[name] = { version = version }
						print("Found package:", name, "Version:", version)
					else
						print("Skipping file (not a versioned rockspec):", full_path)
					end
				end
			end
		end
	end

	return data
end

function Registry.packages()
	return utils.factory.dict_iter(Registry._packages)
end

-- Function to write data to a file in the specified format
---@param data table
---@paran format? "json"|"lua"
function Registry.serialize(data, format)
	format = format or "lua"
	local filename = ".nvl_registry." .. format
	local file = io.open(filename, "w")
	if not file then
		error("Error opening file " .. filename)
	end

	if format == "lua" then
		file:write("return {\n")
		file:write(string.format('  meta = {\n    version = "%s",\n  },\n', data.meta.version))
		file:write("  packages = {\n")
		for name, info in pairs(data.packages) do
			file:write(string.format('    %s = {\n      version = "%s",\n    },\n', name, info.version))
		end
		file:write("  },\n")
		file:write("}\n")
	else
		print("Registry.serialize: json NOT IMPLEMENTED")
		-- file:write(json.encode(data, { indent = true }))
	end

	file:close()
end

function Registry.sync()
	local data = Registry.update()
	Registry.serialize(data)
end

function Registry.init()
	local nvl_registry_file = ".nvl_registry." .. Registry.format

	local path_nvl_registry

	if vim then
		path_nvl_registry = vim.api.nvim_get_runtime_file(nvl_registry_file, false)
		if not path_nvl_registry then
			--- TODO: handle this error
			print(string.format("Registry.init: cannot find nvl registry file: '%s'", nvl_registry_file))
			return
		end

		path_nvl_registry = path_nvl_registry[1]
	else
		--- TODO: this is for development only
		--- handle luarocks library correclty
		path_nvl_registry = runtime.joinpath(utils.git_root(), nvl_registry_file)
	end

	local fact = loadfile(path_nvl_registry)
	if type(fact) == "function" then
		for key, value in pairs(fact().packages) do
			Registry._packages[key] = value
		end
	end
end
if not init_done then
	Registry.init()
end

return Registry
