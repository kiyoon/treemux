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
	local tree_client="$(tree_client)"
	local enable_debug_pane="$(enable_debug_pane)"

	set_tmux_option "${VAR_KEY_PREFIX}-${tree_key}" "${nvim_command},${tree_nvim_init_file},${editor_nvim_init_file},${python_command},${tree_position},${tree_width},${editor_position},${editor_size},${open_focus},${refresh_interval},${refresh_interval_inactive_pane},${refresh_interval_inactive_window},${enable_debug_pane},,${tree_client}"
	set_tmux_option "${VAR_KEY_PREFIX}-${tree_focus_key}" "${nvim_command},${tree_nvim_init_file},${editor_nvim_init_file},${python_command},${tree_position},${tree_width},${editor_position},${editor_size},${open_focus},${refresh_interval},${refresh_interval_inactive_pane},${refresh_interval_inactive_window},${enable_debug_pane},focus,${tree_client}"
}

set_key_bindings() {
	local stored_key_vars="$(stored_key_vars)"
	local key
	for option in $stored_key_vars; do
		key="$(get_key_from_option_name "$option")"
		value="$(get_value_from_option_name "$option")"
		tmux bind-key "$key" run-shell "$SCRIPTS_DIR/toggle.sh '$value' '#{pane_id}'"
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
