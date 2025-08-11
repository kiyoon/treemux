#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

# script global vars
ARGS="$1"               # example args format: "nvim,,,python3,right,20,0.5,2,5,0,focus"
PANE_ID="$2"
NVIM_COMMAND="$(echo "$ARGS"  | cut -d',' -f1)"   # "nvim" or "NVIM_APPNAME=nvim-treemux nvim"
TREE_NVIM_INIT_FILE="$(echo "$ARGS"  | cut -d',' -f2)"   # "~/.tmux/plugins/treemux/configs/treemux_init.vim"
EDITOR_NVIM_INIT_FILE="$(echo "$ARGS"  | cut -d',' -f3)"   # ""
PYTHON_COMMAND="$(echo "$ARGS"  | cut -d',' -f4)"   # "python3"
POSITION="$(echo "$ARGS" | cut -d',' -f5)"   # "right"
SIZE="$(echo "$ARGS"     | cut -d',' -f6)"   # "20"
EDITOR_POSITION="$(echo "$ARGS" | cut -d',' -f7)"   # "top"
EDITOR_SIZE="$(echo "$ARGS" | cut -d',' -f8)"   # "70%"
OPEN_FOCUS="$(echo "$ARGS" | cut -d',' -f9)"   # "editor"
REFRESH_INTERVAL="$(echo "$ARGS"    | cut -d',' -f10)"   # "0.5"
REFRESH_INTERVAL_INACTIVE_PANE="$(echo "$ARGS"    | cut -d',' -f11)"   # "2"
REFRESH_INTERVAL_INACTIVE_WINDOW="$(echo "$ARGS"    | cut -d',' -f12)"   # "5"
ENABLE_DEBUG_PANE="$(echo "$ARGS"    | cut -d',' -f13)"   # "0"
FOCUS="$(echo "$ARGS"    | cut -d',' -f14)"   # "focus"
TREE_CLIENT="$(echo "$ARGS" | cut -d',' -f15)" # "nvim-tree" or "neo-tree"

# If you add arguments, make sure you change from kill_sidebar() as well.

PANE_WIDTH="$(get_pane_info "$PANE_ID" "#{pane_width}")"
PANE_CURRENT_PATH="$(get_pane_info "$PANE_ID" "#{pane_current_path}")"

# Root dir is either the current dir or git root dir.
get_nvimtree_root_dir() {
	if command -v \git &> /dev/null
	then
		git_root_dir="$(\git -C "$PANE_CURRENT_PATH" rev-parse --show-toplevel 2>/dev/null)"
		if [ -z "$git_root_dir" ]
		then
			echo "$PANE_CURRENT_PATH"
		else
			echo "$git_root_dir"
		fi
	else
		echo "$PANE_CURRENT_PATH"
	fi
}

NVIMTREE_ROOT_DIR="$(get_nvimtree_root_dir)"

supported_tmux_version_ok() {
	$CURRENT_DIR/check_tmux_version.sh "$SUPPORTED_TMUX_VERSION"
}

sidebar_registration() {
	get_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" ""
}

sidebar_pane_id() {
	sidebar_registration |
		cut -d',' -f1
}

sidebar_pane_args() {
	echo "$(sidebar_registration)" |
		cut -d',' -f2-
}

register_sidebar() {
	local sidebar_id="$1"
	set_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${sidebar_id}" "$PANE_ID"
	set_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" "${sidebar_id},${ARGS}"
}

registration_not_for_the_same_command() {
	local registered_args="$(sidebar_registration | cut -d',' -f2-)"
	[[ $ARGS != $registered_args ]]
}

sidebar_exists() {
	local pane_id="$(sidebar_pane_id)"
	tmux list-panes -F "#{pane_id}" 2>/dev/null |
		\grep -q "^${pane_id}$"
}

has_sidebar() {
	if [ -n "$(sidebar_registration)" ] && sidebar_exists; then
		return 0
	else
		return 1
	fi
}

current_pane_width_not_changed() {
	if [ $PANE_WIDTH -eq $1 ]; then
		return 0
	else
		return 1
	fi
}

kill_sidebar() {
	# get data before killing the sidebar
	local sidebar_pane_id="$(sidebar_pane_id)"
	local sidebar_args="$(sidebar_pane_args)"
	local sidebar_position="$(echo "$sidebar_args" | cut -d',' -f5)" # left or defults to right
	local sidebar_width="$(get_pane_info "$sidebar_pane_id" "#{pane_width}")"

	$CURRENT_DIR/save_sidebar_width.sh "$NVIMTREE_ROOT_DIR" "$sidebar_width"

	# kill the sidebar
	tmux kill-pane -t "$sidebar_pane_id"

	# check current pane "expanded" properly
	local new_current_pane_width="$(get_pane_info "$PANE_ID" "#{pane_width}")"
	if current_pane_width_not_changed "$new_current_pane_width"; then
		# need to expand current pane manually
		local direction_flag
		if [[ "$sidebar_position" =~ "left" ]]; then
			direction_flag="-L"
		else
			direction_flag="-R"
		fi
		# compensate 1 column
		tmux resize-pane "$direction_flag" "$((sidebar_width + 1))"
	fi
	PANE_WIDTH="$new_current_pane_width"
}

sidebar_left() {
	[[ $POSITION =~ "left" ]]
}

no_focus() {
	if [[ $FOCUS =~ (^focus) ]]; then
		return 1
	else
		return 0
	fi
}

size_defined() {
	[ -n $SIZE ]
}

desired_sidebar_size() {
	local half_pane="$((PANE_WIDTH / 2))"
	if directory_in_sidebar_file "$NVIMTREE_ROOT_DIR"; then
		# use stored sidebar width for the directory
		echo "$(width_from_sidebar_file "$NVIMTREE_ROOT_DIR")"
	elif size_defined && [ $SIZE -lt $half_pane ]; then
		echo "$SIZE"
	else
		echo "$half_pane"
	fi
}

# tmux version 2.0 and below requires different argument for `join-pane`
use_inverted_size() {
	[ tmux_version_int -le 20 ]
}

split_sidebar_left() {
	local sidebar_size=$(desired_sidebar_size)
	if use_inverted_size; then
		sidebar_size=$((PANE_WIDTH - $sidebar_size - 1))
	fi

	# mktemp --dry-run option is needed because the file shouldn't exist.
	# -u parameter is compatible with MacOS and Linux.
	nvim_addr="$(mktemp -u -t kiyoon-tmux-treemux-$PANE_ID.XXXXXX)"

    common_args="'+let g:nvim_tree_remote_tmux_pane=\"$PANE_ID\"' \
			'+let g:nvim_tree_remote_tmux_split_position=\"$EDITOR_POSITION\"' \
			'+let g:nvim_tree_remote_tmux_split_size=\"$EDITOR_SIZE\"' \
			'+let g:nvim_tree_remote_tmux_focus=\"$OPEN_FOCUS\"' \
			'+let g:nvim_tree_remote_tmux_editor_init_file=\"$EDITOR_NVIM_INIT_FILE\"' \
			'+let g:nvim_tree_remote_treemux_path=\"$CURRENT_DIR/..\"' \
            "

    if [[ -n "$TREE_NVIM_INIT_FILE" ]]
    then
        common_args="$common_args -u '$TREE_NVIM_INIT_FILE' "
    fi

    if [[ "$TREE_CLIENT" == "nvim-tree" ]]
    then
        common_args="$common_args '+lua require(\"nvim-tree.api\").tree.open({current_window = true})'"
    elif [[ "$TREE_CLIENT" == "neo-tree" ]]
    then
        # HACK: using `:Neotree current` command makes the tree incompletely initialized.
        # So we open on the side and close the default empty window instead.
        common_args="$common_args +Neotree '+lua vim.api.nvim_win_close(1000, false)'"
    else
        echo "Unknown TREE_CLIENT: $TREE_CLIENT"
        exit 1
    fi

    local sidebar_id="$(tmux new-window -c "$NVIMTREE_ROOT_DIR" -P -F "#{pane_id}" \
        "$NVIM_COMMAND '$NVIMTREE_ROOT_DIR' --listen '$nvim_addr' ${common_args}")"

	tmux join-pane -hb -l "$sidebar_size" -t "$PANE_ID" -s "$sidebar_id"

	if [[ $ENABLE_DEBUG_PANE -eq 0 ]]
	then
		"$CURRENT_DIR/tree/watch_and_update.sh" "$PANE_ID" "$sidebar_id" "$NVIMTREE_ROOT_DIR" "$nvim_addr" "$REFRESH_INTERVAL" "$REFRESH_INTERVAL_INACTIVE_PANE" "$REFRESH_INTERVAL_INACTIVE_WINDOW" "$NVIM_COMMAND" "$PYTHON_COMMAND" &>/dev/null &
	else
		local sidebar_id2="$(tmux split-window -h -l "$sidebar_size" -c "$NVIMTREE_ROOT_DIR" -P -F "#{pane_id}" \
			"'$CURRENT_DIR/tree/watch_and_update.sh' '$PANE_ID' '$sidebar_id' \
			'$NVIMTREE_ROOT_DIR' '$nvim_addr' "$REFRESH_INTERVAL" "$REFRESH_INTERVAL_INACTIVE_PANE" "$REFRESH_INTERVAL_INACTIVE_WINDOW" \
			'$NVIM_COMMAND' '$PYTHON_COMMAND'; sleep 100")"
	fi
	echo "$sidebar_id"
}

split_sidebar_right() {
	local sidebar_size=$(desired_sidebar_size)

	# mktemp --dry-run option is needed because the file shouldn't exist.
	# -u parameter is compatible with MacOS and Linux.
	nvim_addr="$(mktemp -u -t kiyoon-tmux-treemux-$PANE_ID.XXXXXX)"

    common_args="'+let g:nvim_tree_remote_tmux_pane=\"$PANE_ID\"' \
			'+let g:nvim_tree_remote_tmux_split_position=\"$EDITOR_POSITION\"' \
			'+let g:nvim_tree_remote_tmux_split_size=\"$EDITOR_SIZE\"' \
			'+let g:nvim_tree_remote_tmux_focus=\"$OPEN_FOCUS\"' \
			'+let g:nvim_tree_remote_tmux_editor_init_file=\"$EDITOR_NVIM_INIT_FILE\"' \
			'+let g:nvim_tree_remote_treemux_path=\"$CURRENT_DIR/..\"' \
            "
    if [[ "$TREE_CLIENT" == "nvim-tree" ]]
    then
        common_args="$common_args '+lua require('nvim-tree.api').tree.open({current_window = true})'"
    elif [[ "$TREE_CLIENT" == "neo-tree" ]]
    then
        # HACK: using `:Neotree current` command makes the tree incompletely initialized.
        # So we open on the side and close the default empty window instead.
        common_args="$common_args +Neotree '+lua vim.api.nvim_win_close(1000, false)'"
    else
        echo "Unknown TREE_CLIENT: $TREE_CLIENT"
        exit 1
    fi

    local sidebar_id="$(tmux split-window -h -l "$sidebar_size" -c "$NVIMTREE_ROOT_DIR" -P -F "#{pane_id}" \
        "$NVIM_COMMAND '$NVIMTREE_ROOT_DIR' --listen '$nvim_addr' ${common_args}")"

	if [[ $ENABLE_DEBUG_PANE -eq 0 ]]
	then
		"$CURRENT_DIR/tree/watch_and_update.sh" "$PANE_ID" "$sidebar_id" "$NVIMTREE_ROOT_DIR" "$nvim_addr" "$REFRESH_INTERVAL" "$REFRESH_INTERVAL_INACTIVE_PANE" "$REFRESH_INTERVAL_INACTIVE_WINDOW" "$NVIM_COMMAND" "$PYTHON_COMMAND" &> /dev/null &
	else
		local sidebar_id2="$(tmux new-window -c "$NVIMTREE_ROOT_DIR" -P -F "#{pane_id}" \
			"'$CURRENT_DIR/tree/watch_and_update.sh' '$PANE_ID' '$sidebar_id' \
			'$NVIMTREE_ROOT_DIR' '$nvim_addr' "$REFRESH_INTERVAL" "$REFRESH_INTERVAL_INACTIVE_PANE" "$REFRESH_INTERVAL_INACTIVE_WINDOW" \
			'$NVIM_COMMAND' '$PYTHON_COMMAND'; sleep 100 \
			")"
		tmux join-pane -hb -l "$sidebar_size" -t "$PANE_ID" -s "$sidebar_id2"
	fi
	echo "$sidebar_id"
}

create_sidebar() {
	local position="$1" # left / right
	local sidebar_id="$(split_sidebar_${position})"
	register_sidebar "$sidebar_id"
	if no_focus; then
		tmux last-pane
	fi
}

current_pane_is_sidebar() {
	local var="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	[ -n "$var" ]
}

current_pane_too_narrow() {
	[ $PANE_WIDTH -lt $MINIMUM_WIDTH_FOR_SIDEBAR ]
}

execute_command_from_main_pane() {
	# get pane_id for this sidebar
	local main_pane_id="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	# execute the same command as if from the "main" pane
	$CURRENT_DIR/toggle.sh "$ARGS" "$main_pane_id"
}

exit_if_pane_too_narrow() {
	if current_pane_too_narrow; then
		display_message "Pane too narrow for the sidebar"
		exit
	fi
}

toggle_sidebar() {
	if has_sidebar; then
		kill_sidebar
		# if using different sidebar command automatically open a new sidebar
		# if registration_not_for_the_same_command; then
		# 	create_sidebar
		# fi
	else
		exit_if_pane_too_narrow

		if sidebar_left; then
			create_sidebar "left"
		else
			create_sidebar "right"
		fi
	fi
}

main() {
	if supported_tmux_version_ok; then
		if current_pane_is_sidebar; then
			execute_command_from_main_pane
		else
			toggle_sidebar
		fi
	fi
}
main
