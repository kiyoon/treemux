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
tree_client = sys.argv[3]

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
    nvim.exec_lua("require('neo-tree.sources.manager').get_state('filesystem').commands.change_root('{}')".format(path))
else:
    nvim.exec_lua("require('nvim-tree.api').tree.change_root('{}')".format(path))
