## Options

Customise `treemux` by placing options in `.tmux.conf` and reloading Tmux
environment.

> Can I change the refresh rate? (default: 0.5, 2, 5)

    set -g @treemux-refresh-interval 0.1			# the focus is on the main pane or the side Nvim-Tree.
    set -g @treemux-refresh-interval-inactive-pane 1		# the focus is not on the pane but you're still in the same window.
    set -g @treemux-refresh-interval-inactive-window 3		# you left the window.

> Can I have the sidebar on the right? (supports left/right)

    set -g @treemux-tree-position 'right'

> Can I have the editor on the bottom? (supports top/bottom/left/right)

    set -g @treemux-editor-position 'bottom'

> I don't like the default 'prefix + Tab' key binding. Can I change it to be
> 'prefix + e'?

    set -g @treemux-tree 'e'

> How can I change the default 'prefix + Backspace' to be 'prefix + w'?

    set -g @treemux-tree-focus 'w'

> The default sidebar width is 40 columns. I want the sidebar to be wider by
> default!

    set -g @treemux-tree-width 60

> The default editor size is 70%. I want the nvim editor pane to be wider by
> default!

    set -g @treemux-editor-size '80%'

> When I open a file from the tree, the focus moves to the editor. I want to
> stay in the tree!

    set -g @treemux-open-focus 'tree'

> Specify Neovim path or set NVIM_APPNAME environment variable to separate the environment from the main nvim config (default: `nvim`)

    set -g @treemux-nvim-command '/path/to/nvim'
    set -g @treemux-nvim-command 'NVIM_APPNAME=nvim-treemux nvim'

> Specify Python path with `pynvim` installed (default: `/usr/bin/python3`)

    set -g @treemux-python-command '/path/to/python3'

> Dev debug mode which will open another pane for debugging.

    set -g @treemux-enable-debug-pane #

> Specify the colorscheme to use (default: `tokyonight-night`)

    set -g @treemux-colorscheme 'tokyonight-night'
