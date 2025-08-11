#!/usr/bin/env bash

SIDE_PANE_ID="$1"
TARGET_DIR="$2"
TREE_CLIENT="$3"
COMMAND="$4"

if [ "$TREE_CLIENT" == "neo-tree" ]; then
	if [ "$COMMAND" == "change_root" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"require('neo-tree.sources.manager').get_state('filesystem').commands.change_root('$TARGET_DIR')" 
		"EOF"
	elif [ "$COMMAND" == "go_to_child" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"require('neo-tree.sources.manager').get_state('filesystem').commands.find('$TARGET_DIR')" 
		"EOF"
	elif [ "$COMMAND" == "go_to_parent" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"require('neo-tree.sources.manager').get_state('filesystem').commands.find('$TARGET_DIR')" 
		"EOF"
	fi
else
	if [ "$COMMAND" == "change_root" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"nt_api = require('nvim-tree.api')" 
		"nt_api.tree.change_root('$TARGET_DIR')" 
		"EOF"
	elif [ "$COMMAND" == "go_to_child" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"nt_api = require('nvim-tree.api')" 
		"nt_api.tree.find_file('$TARGET_DIR')" 
		"local nt_node = nt_api.tree.get_node_under_cursor()" 
		"if nt_node ~= nil then" 
		"  if nt_node.absolute_path ~= '$TARGET_DIR' then" 
		"    nt_api.tree.change_root('$side_pane_root')" 
		"    nt_api.tree.find_file('$TARGET_DIR')" 
		"    local nt_node = nt_api.tree.get_node_under_cursor()" 
		"  end" 
		"  if not nt_node.open then" 
		"    nt_api.node.open.edit()" 
		"  end" 
		"end" 
		"EOF"
	elif [ "$COMMAND" == "go_to_parent" ]; then
		mux send-keys -t "$SIDE_PANE_ID" \
		Escape ":lua << EOF"
		"nt_api = require('nvim-tree.api')" 
		"nt_api.tree.find_file('$TARGET_DIR')" 
		"local nt_node = nt_api.tree.get_node_under_cursor()" 
		"if nt_node ~= nil then" 
		"  if nt_node.absolute_path ~= '$TARGET_DIR' then" 
		"    nt_api.tree.change_root('$side_pane_root')" 
		"    nt_api.tree.find_file('$TARGET_DIR')" 
		"    local nt_node = nt_api.tree.get_node_under_cursor()" 
		"  end" 
		"  if nt_node.open then" 
		"    nt_api.node.open.edit()" 
		"  end" 
		"end" 
		"EOF"
	fi
fi
