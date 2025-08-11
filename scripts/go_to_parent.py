#!/usr/bin/env python3

import sys
import time

try:
    import pynvim
except ImportError as e:
    print("pynvim not installed")
    print(e)
    sys.exit(50)

nvim_addr = sys.argv[1]
path = sys.argv[2]
side_pane_root = sys.argv[3]
tree_client = sys.argv[4]

for _ in range(1000):
    try:
        nvim = pynvim.attach("socket", path=nvim_addr)
    except Exception as e:
        time.sleep(0.1)
    else:
        break
else:
    print("Timeout while waiting for nvim to start")
    sys.exit(51)

if tree_client == "neo-tree":
    nvim.exec_lua("require('neo-tree.sources.manager').get_state('filesystem').commands.find('{}')".format(path))
    print(nvim.exec_lua("return require('neo-tree.sources.manager').get_state('filesystem').path"))
else:
    lua_code = """
    nt_api = require('nvim-tree.api')
    nt_api.tree.find_file('{main_pane_cwd}')
    local nt_node = nt_api.tree.get_node_under_cursor()

    if nt_node ~= nil then
        if nt_node.absolute_path ~= '{main_pane_cwd}' then
            nt_api.tree.change_root('{side_pane_root}')
            nt_api.tree.find_file('{main_pane_cwd}')
            nt_node = nt_api.tree.get_node_under_cursor()
        end

        if nt_node.open then
            nt_api.node.open.edit()
        end
    end
    """
    nvim.exec_lua(lua_code.format(main_pane_cwd=path, side_pane_root=side_pane_root))
    print(nvim.exec_lua("return require('nvim-tree.api').tree.get_nodes().absolute_path"))
