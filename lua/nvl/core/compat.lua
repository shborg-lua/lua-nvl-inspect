---@generic T: table
---@alias nvl.core.compat.unpack_fun fun(list:T[], i?: integer, j?: integer):T
---
---@class nvl.core.compat.module_exports
---@field unpack nvl.core.compat.unpack_fun
local M = {}

M.unpack = table.unpack or unpack

return M
