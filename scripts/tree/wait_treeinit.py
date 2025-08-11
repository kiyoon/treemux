#!/use/bin/env python3

import sys
import time

try:
    import pynvim
except ImportError as e:
    print("pynvim not installed")
    print(e)
    sys.exit(50)

nvim_addr = sys.argv[1]

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

# Wait until Nvim-Tree/Neo-Tree is running
filetype = ""
for _ in range(1000):
    filetype = nvim.eval("&filetype")
    if filetype in ("NvimTree", "neo-tree"):
        break
    time.sleep(0.1)
else:
    print(
        f"Timeout while waiting for Nvim-Tree/Neo-Tree to start. Filetype is: {filetype}"
    )
    sys.exit(52)

print(filetype)
