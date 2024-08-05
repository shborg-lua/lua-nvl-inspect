---  class nvl.package.ConfigOptionsExports
---  field globals table<string,nvl.core.config.mod_info>
---
---  class nvl.package.ConfigOptionsBase
---  field exports table

---  class nvl.package.config_exports
---  field setup fun(options:nvl.package.ConfigOptionsBase):boolean setup function of a package
---
---

---@alias nvl.types.list_iterator_ret fun():number,any|nil
---@alias nvl.types.list_iterator fun(t:table):nvl.types.list_iterator_ret
---@alias nvl.types.dict_iterator_ret fun():string,any
---
---@generic T: table, K, V
---@alias nvl.types.dict_iterator fun(table: table<K, V>, index?: K):K, V # |for-in| iterator over sorted keys and their values
