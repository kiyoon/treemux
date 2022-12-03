#!/use/bin/env python3

import sys

import pynvim

lua_code = """
nt_api = require('nvim-tree.api')
nt_api.tree.collapse_all()
nt_api.tree.find_file('{main_pane_cwd}')
local nt_node = nt_api.tree.get_node_under_cursor()
if nt_node ~= nil then
  if nt_node.absolute_path ~= '{main_pane_cwd}' then
    nt_api.tree.change_root('{side_pane_root}')
    nt_api.tree.find_file('{main_pane_cwd}')
    local nt_node = nt_api.tree.get_node_under_cursor()
  end
  if not nt_node.open then
    nt_api.node.open.edit()
  end
end
"""

nvim_addr = sys.argv[1]
main_pane_cwd = sys.argv[2]             # Directory to open.
side_pane_root = sys.argv[3]            # In case the root has been modified manually, go back to the original root.

nvim = pynvim.attach('socket', path=nvim_addr)
nvim.exec_lua(lua_code.format(main_pane_cwd=main_pane_cwd, side_pane_root=side_pane_root))
