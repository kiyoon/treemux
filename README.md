# Treemux for Tmux

Nothing has been this close to an IDE!

`Treemux` opens a sidebar with Neovim's [Nvim-Tree](https://github.com/nvim-tree/nvim-tree.lua) file explorer,
with additional cool features like:

- Automatic updates on Nvim-Tree as you change directory in shell.
- Nvim-Tree to shell interaction possible with [tmux-send.nvim](https://github.com/kiyoon/tmux-send.nvim).
  - You can copy absolute path from Nvim-Tree and paste into the shell.
  - Change directory, execute programs, open with vim and anything you can imagine!
- Open files from Nvim-Tree to Neovim seamlessly, using [nvim-tree-remote.nvim](https://github.com/kiyoon/nvim-tree-remote.nvim).
  - Just open the files (double click) and it will show up in another Neovim!

<img src="https://user-images.githubusercontent.com/12980409/210149162-bdfdbed7-c2e7-4616-bcaa-9d83dedda7e3.gif" width="100%"/>

Of course you also get:

- All features from Nvim-Tree:
  - **mouse click**
  - **automatic refresh**
  - **file icons**
- All features from tmux-sidebar:
  - **smart sizing**<br/>
    Sidebar remembers its size, so the next time you open it, it will have the
    **exact same** width. This is a per-directory property, so you can have just
    the right size for multiple dirs.
  - **toggling**<br/>
    The same key binding opens and closes the sidebar.
  - **uninterrupted workflow**<br/>
    The main `prefix + Tab` key binding opens a sidebar but **does not** move
    cursor to it.
  - **pane layout stays the same**<br/>
    No matter which pane layout you prefer, sidebar tries hard not to mess your
    pane splits. Open, then close the sidebar and everything should look the same.

Furthermore, it will detect git directory and open that as root, while still opening current directory.

Tested and working on Linux, MacOS and Windows WSL2.

### Key bindings

- `prefix + Tab` - toggle sidebar with a directory tree
- `prefix + Backspace` - toggle sidebar and move cursor to it (focus it)

NOTE: Instant IDE modes are deprecated. Now you can just open a file from the tree without entering this mode.

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @treemux-tree-nvim-init-file '~/.tmux/plugins/treemux/configs/treemux_init.lua'
set -g @plugin 'kiyoon/treemux'
```

- The first line sets a separate nvim init file for the tree to separate from the editor.
    - This contains some plugins to interact neovim in another pane.
    - You can customise the tree by copying the `treemux_init.lua` file somewhere outside the repo and modifying the file.

Optionally, consider setting these options in your `.tmux.conf` (they should be set before the `set -g @plugin 'kiyoon/treemux'` line):

```tmux
# Set python with pynvim installed.
# Use an absolute path because if you activate a python virtual environment, the pynvim may not be installed on that environment.
set -g @treemux-python-command '/path/to/python3'  # default is '/usr/bin/python3'

# If you want to completely isolate the treemux's nvim config and data from your main nvim config and data, set NVIM_APPNAME.
# This will make treemux use '~/.config/nvim-treemux', '~/.local/share/nvim-treemux'
set -g @treemux-nvim-command 'NVIM_APPNAME=nvim-treemux nvim'  # default is 'nvim'
```


Hit `prefix + I` to fetch the plugin and source it.

Install python support for Neovim.

```bash
/usr/bin/python3 -m pip install --user pynvim
```

Make sure you have Neovim and lsof installed.  
```bash
nvim --version
lsof -h  # most distro include this, but maybe Arch wouldn't have it.
```

You should now be able to use the plugin.

### Updating the plugin

Not only updating the plugin itself (`prefix + U`),  
you need to also update the neovim plugins.  
Run this from the side tree:

```vim
:Lazy update
```

### Docs

- You can open a file from the command line to the remote editor split, using `treemux-nvim` command. (e.g. `treemux-nvim file.py`)
- [customisation options](docs/options.md)

### License

[MIT](LICENSE.md)
