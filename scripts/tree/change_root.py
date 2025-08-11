#!/use/bin/env python3

import sys

import pynvim

nvim_addr = sys.argv[1]
new_root = sys.argv[2]

nvim = pynvim.attach("socket", path=nvim_addr)

# check the filetype
filetype = nvim.eval("&filetype")

if filetype == "NvimTree":
    nvim.exec_lua("require('nvim-tree.api').tree.change_root(...)", new_root)
elif filetype == "neo-tree":
    nvim.exec_lua(
        "require('neo-tree.command').execute(...)",
        {"action": "focus", "position": "current", "dir": new_root},
    )
else:
    print(f"Unsupported filetype: {filetype}")
    sys.exit(1)
