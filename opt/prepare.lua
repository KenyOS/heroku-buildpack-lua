local rockspec_path, opt_dir = ...
local strip
strip = function(str)
  return str:match("^%s*(.-)%s*$")
end
local read_cmd
read_cmd = function(cmd)
  local f = io.popen(cmd, "r")
  do
    local _with_0 = strip(f:read("*a"))
    f:close()
    return _with_0
  end
end
local tree = read_cmd("dirname " .. rockspec_path) .. "/packages"
tree = read_cmd("cd " .. tree .. " && pwd")
local luarocks_dir = opt_dir .. "/luarocks"
package.path = luarocks_dir .. "/?.lua;" .. package.path
local error
error = function(msg)
  print(msg)
  return os.exit(1)
end
if not opt_dir then
  error("Missing opt_dir")
end
if not rockspec_path then
  error("Missing rockspec_path")
end
local fn = loadfile(rockspec_path)
if not fn then
  error("Failed to open rockspec:", rockspec_path)
end
local rockspec = {
  name = "anonymous_app",
  dependencies = { }
}
setfenv(fn, rockspec)()
local path = require("luarocks.path")
local deps = require("luarocks.deps")
local install = require("luarocks.install")
local extras = { }
rockspec.dependencies = (function()
  local _accum_0 = { }
  local _len_0 = 0
  local _list_0 = rockspec.dependencies
  for _index_0 = 1, #_list_0 do
    local dep = _list_0[_index_0]
    local parsed = deps.parse_dep(dep)
    if not parsed then
      table.insert(extras, dep)
    end
    local _value_0 = parsed
    if _value_0 ~= nil then
      _len_0 = _len_0 + 1
      _accum_0[_len_0] = _value_0
    end
  end
  return _accum_0
end)()
path.use_tree(tree)
local success, msg = deps.fulfill_dependencies(rockspec)
if not success then
  error(msg)
end
local _list_0 = extras
for _index_0 = 1, #_list_0 do
  local extra = _list_0[_index_0]
  install.run(extra)
end
