#!/use/bin/env python3

import sys
import time
from pathlib import Path

import pynvim

lua_code = """
local main_pane_first_child, side_pane_root = ...
local nt_api = require('nvim-tree.api')

nt_api.tree.find_file(main_pane_first_child)
local nt_node = nt_api.tree.get_node_under_cursor()

folder_found = true
if nt_node ~= nil then
  if nt_node.absolute_path ~= main_pane_first_child then
    nt_api.tree.change_root(side_pane_root)
    nt_api.tree.find_file(main_pane_first_child)
    local nt_node = nt_api.tree.get_node_under_cursor()
    if nt_node.absolute_path ~= main_pane_first_child then
      folder_found = false
      nt_api.tree.change_root(main_pane_first_child)
    end
  end

  if folder_found then
    if nt_node.open then
      nt_api.node.open.edit()
    end

    if (vim.fn.winline() / vim.fn.winheight(0)) > 0.5 then
      vim.cmd('normal! zz')
    end
  end
end
"""

lua_code_neotree = """
local manager = require("neo-tree.sources.manager")
local filesystem = require("neo-tree.sources.filesystem")
local fs_cmds = require("neo-tree.sources.filesystem.commands")

local function reveal_and_close_dir(new_root, reveal_dir)
  local state = manager.get_state("filesystem")

  local function on_ok()
    local node = state.tree:get_node()

    if not node or node.type ~= "directory" or node.path ~= reveal_dir then
      -- if you called this function correctly where the reveal_dir is a subdirectory of new_root,
      -- then maybe the file is hidden, so we need to unhide them.
      if not state.filtered_items.visible then
        fs_cmds.toggle_hidden(state)
        filesystem.navigate(state, new_root, reveal_dir, on_ok)
      end

      return
    end

    -- correctly located the directory, now close it
    if node:is_expanded() then
      fs_cmds.open(state)
    end

    -- Keep roughly centered
    if (vim.fn.winline() / vim.fn.winheight(0)) > 0.5 then
      vim.cmd("normal! zz")
    end
  end

  filesystem.navigate(state, new_root, reveal_dir, on_ok)
end

reveal_and_close_dir(...)
"""


nvim_addr = sys.argv[1]
# directory to close. It is the first child of the directory you're going into.
main_pane_first_child = Path(sys.argv[2])
# In case the root has been modified manually, go back to the original root.
side_pane_root = Path(sys.argv[3])

nvim = pynvim.attach("socket", path=nvim_addr)

filetype = nvim.eval("&filetype")
if filetype == "NvimTree":
    nvim.exec_lua(lua_code, str(main_pane_first_child), str(side_pane_root))
    print(
        nvim.exec_lua("return require('nvim-tree.api').tree.get_nodes().absolute_path")
    )  # print new root dir
elif filetype == "neo-tree":
    # NOTE: this doesn't work with :Neotree current. Always use :Neotree
    root_dir = nvim.exec_lua(
        "return require('neo-tree.sources.manager').get_state('filesystem').path"
    )

    # 1. main_pane_first_child is within the root dir. Do not change root and just close the dir.
    if main_pane_first_child.is_relative_to(root_dir):
        nvim.exec_lua(lua_code_neotree, root_dir, str(main_pane_first_child))
        print(root_dir)  # the new root dir is the same as the old one

    # 2. In case the root has been modified manually, go back to the original root (side_pane_root).
    elif main_pane_first_child.is_relative_to(side_pane_root):
        nvim.exec_lua(lua_code_neotree, str(side_pane_root), str(main_pane_first_child))
        print(side_pane_root)  # the new root dir

    # 3. last resort, change root to the main_pane_first_child
    else:
        nvim.exec_lua(
            "require('neo-tree.command').execute(...)",
            {"action": "focus", "position": "current", "dir": main_pane_first_child},
        )
        print(main_pane_first_child)  # the new root dir
else:
    sys.exit(1)
