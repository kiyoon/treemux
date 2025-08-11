VAR_KEY_PREFIX="@treemux-key"
REGISTERED_PANE_PREFIX="@-treemux-registered-pane"
REGISTERED_SIDEBAR_PREFIX="@-treemux-is-treemux"
MINIMUM_WIDTH_FOR_SIDEBAR="71"

TREE_KEY="Tab"
TREE_OPTION="@treemux-tree"

TREE_FOCUS_KEY="Bspace"
TREE_FOCUS_OPTION="@treemux-tree-focus"

REFRESH_INTERVAL="0.5"
REFRESH_INTERVAL_OPTION="@treemux-refresh-interval"

REFRESH_INTERVAL_INACTIVE_PANE="2"
REFRESH_INTERVAL_INACTIVE_PANE_OPTION="@treemux-refresh-interval-inactive-pane"

REFRESH_INTERVAL_INACTIVE_WINDOW="5"
REFRESH_INTERVAL_INACTIVE_WINDOW="@treemux-refresh-interval-inactive-window"

NVIM_COMMAND="nvim"
NVIM_COMMAND_OPTION="@treemux-nvim-command"

TREE_NVIM_INIT_FILE=""
TREE_NVIM_INIT_FILE_OPTION="@treemux-tree-nvim-init-file"

EDITOR_NVIM_INIT_FILE=""
EDITOR_NVIM_INIT_FILE_OPTION="@treemux-editor-nvim-init-file"

PYTHON_COMMAND="/usr/bin/python3"
PYTHON_COMMAND_OPTION="@treemux-python-command"

TREE_POSITION="left"
TREE_POSITION_OPTION="@treemux-tree-position"

TREE_WIDTH="40"
TREE_WIDTH_OPTION="@treemux-tree-width"

EDITOR_POSITION="top"
EDITOR_POSITION_OPTION="@treemux-editor-position"

EDITOR_SIZE="70%"
EDITOR_SIZE_OPTION="@treemux-editor-size"

OPEN_FOCUS="editor"
OPEN_FOCUS_OPTION="@treemux-open-focus"

ENABLE_DEBUG_PANE="0"
ENABLE_DEBUG_PANE_OPTION="@treemux-enable-debug-pane"

TREE_CLIENT="nvim-tree"
TREE_CLIENT_OPTION="@treemux-tree-client"

SUPPORTED_TMUX_VERSION="1.9"

sidebar_dir() {
	local DIR_XDG="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/treemux"
	local DIR_OLD="$HOME/.tmux/treemux"

	if [ -d "$DIR_XDG" ]; then
		echo "$DIR_XDG"
	elif [ -d "$DIR_OLD" ]; then
		echo "$DIR_OLD"
	else
		echo "$DIR_XDG"
	fi
}

SIDEBAR_DIR="$(sidebar_dir)"
