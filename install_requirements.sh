#!/bin/bash

luarocks install --server=https://github.com/lunarmodules/luafilesystem.git luafilesystem
luarocks install --server=https://github.com/acd/lua-yaml.git lua-yaml
luarocks install --server=https://github.com/moteus/lua-sqlite3.git sqlite3
luarocks install --server=https://github.com/lunarmodules/luasocket luasocket
luarocks install --server=https://github.com/rxi/json.lua.git json
luarocks install --server=https://github.com/lunarmodules/luasec luasec
# luarocks install --server=https://github.com/msva/lua-htmlparser.git htmlparser
# luarocks install https://raw.github.com/sampsyo/lua-sundown/master/lua-sundown-0.1-1.rockspec