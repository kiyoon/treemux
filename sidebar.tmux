#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$SCRIPTS_DIR/helpers.sh"
source "$SCRIPTS_DIR/variables.sh"
source "$SCRIPTS_DIR/tree_helpers.sh"

set_default_key_binding_options() {
	local nvim_command="$(nvim_command)"
	local tree_nvim_init_file="$(tree_nvim_init_file)"
	local editor_nvim_init_file="$(editor_nvim_init_file)"
	local python_command="$(python_command)"
	local tree_client="$(tree_client)"
	local tree_key="$(tree_key)"
	local tree_focus_key="$(tree_focus_key)"
	local tree_position="$(tree_position)"
	local tree_width="$(tree_width)"
	local editor_position="$(editor_position)"
	local editor_size="$(editor_size)"
	local open_focus="$(open_focus)"
	local refresh_interval="$(refresh_interval)"
	local refresh_interval_inactive_pane="$(refresh_interval_inactive_pane)"
	local refresh_interval_inactive_window="$(refresh_interval_inactive_window)"
	local enable_debug_pane="$(enable_debug_pane)"

	local args="--nvim-command '$nvim_command' --tree-nvim-init-file '$tree_nvim_init_file' --editor-nvim-init-file '$editor_nvim_init_file' --python-command '$python_command' --tree-client '$tree_client' --position '$tree_position' --size '$tree_width' --editor-position '$editor_position' --editor-size '$editor_size' --open-focus '$open_focus' --refresh-interval '$refresh_interval' --refresh-interval-inactive-pane '$refresh_interval_inactive_pane' --refresh-interval-inactive-window '$refresh_interval_inactive_window' --enable-debug-pane '$enable_debug_pane'"

	set_tmux_option "${VAR_KEY_PREFIX}-${tree_key}" "$args"
	set_tmux_option "${VAR_KEY_PREFIX}-${tree_focus_key}" "$args --focus focus"
}

set_key_bindings() {
	local stored_key_vars="$(stored_key_vars)"
	local key
	for option in $stored_key_vars; do
		key="$(get_key_from_option_name "$option")"
		value="$(get_value_from_option_name "$option")"
		tmux bind-key "$key" run-shell "python3 $SCRIPTS_DIR/toggle.py $value --pane-id '#{pane_id}'"
	done
}

pathadd() {
	if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
		NEW_PATH="${PATH:+"$PATH:"}$1"
		tmux set-environment -g PATH "$NEW_PATH"
	fi
}

main() {
	set_default_key_binding_options
	set_key_bindings
	pathadd "$SCRIPTS_DIR/bin"
}
main
