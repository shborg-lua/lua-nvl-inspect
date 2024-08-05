# NVL Library

This library is part of the NVL project and is currently in early
development. Please note that it is a work in progress.

## Packages

NVL Packages must conform to the following interface:

```lua
local pkg = require'nvl.mypack'

-- pkg returns the following table
local SPEC = {
}
```

## Naming

General rules:

- namespace in lowercase
- exported symbols in CamelCase or UPPERCASE or IUpperCase
- prepend private symbols with an `_` character

```lua
--- this is a namespace
--- @class nvl.core.rocks

--- this is an export table
--- It is in lowercase to distinguish from other symbols
--- and to have a standard name for this type.
--- @class nvl.core.rocks.module_exports

--- this is a custom type 
--- @alias nvl.core.rocks.hander_fun fun(...:any):boolean
local function(...) return true end

--- this is a Class
--- @class nvl.core.rocks.Rocks
local Rocks = {}


--- this is a private Class which should 
--- not because be exported
--- @class nvl.core.rocks._Rocks
local _Rocks = {}

--- this is an Interface
--- I use an uppercase I to distinguish from classes
--- and because it's short 
--- @class nvl.core.rocks.IRocksScanner
local IRocksScanner = {}
function IRocksScanner.scan() end

--- this is a constant
--- @class nvl.core.rocks.TYPES
local TYPES = {}

--- this is an options table
--- @class nvl.core.rocks.RocksOptions
local RocksOptions = {}


```

## Packaging and Deployment

`NVL` uses `luarocks` for packaging and deployment.

### lazy.nvim

`lazy.nvim` uses a separate `luarocks` tree for each plugin.
see: lazy.nvim/lua/lazy/pkg/rockspec.lua

### NVL Core Library

rockspec module of NVL:

```lua
 modules = {
  ["nvl"] = "lua/nvl/init.lua",
  ["nvl.core.config"] = "lua/nvl/config.lua",
  ["nvl.core.modules"] = "lua/nvl/modules/init.lua",
 },


```

### NVL Package

The [inspect package](https://github.com/shborg-lua/lua-nvl-inspect) for NVL looks like:

```lua
modules = {
  ["nvl.inspect"] = "lua/nvl/inspect/init.lua",
  ["nvl.inspect.config"] = "lua/nvl/inspect/config.lua",
  ["nvl.inspect.modules.inspect"] = "lua/nvl/inspect/modules/inspect.lua"
},
 ```

## Credits

Special thanks to the following teams and developers:

- the author of kikito/inspect.lua

Feel free to reach out for further information or if you encounter any issues.
