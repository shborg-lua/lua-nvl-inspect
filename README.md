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

## Packaging and Deployment

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
