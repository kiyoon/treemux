#!/usr/bin/env python3

import argparse
import os
import subprocess


def get_pane_info(pane_id, format_string):
    try:
        return (
            subprocess.check_output(
                ["tmux", "display", "-p", "-t", pane_id, format_string]
            )
            .decode("utf-8")
            .strip()
        )
    except subprocess.CalledProcessError:
        return ""


def get_tmux_option(option, default):
    try:
        return (
            subprocess.check_output(["tmux", "show-option", "-gqv", option])
            .decode("utf-8")
            .strip()
        )
    except subprocess.CalledProcessError:
        return default


def set_tmux_option(option, value):
    subprocess.run(["tmux", "set-option", "-gq", option, value])


def get_tree_initial_root_dir(pane_current_path):
    try:
        git_root_dir = (
            subprocess.check_output(
                ["git", "-C", pane_current_path, "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
            )
            .decode("utf-8")
            .strip()
        )
        return git_root_dir
    except (subprocess.CalledProcessError, FileNotFoundError):
        return pane_current_path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nvim-command", required=True)
    parser.add_argument("--tree-nvim-init-file")
    parser.add_argument("--editor-nvim-init-file")
    parser.add_argument("--python-command", required=True)
    parser.add_argument("--tree-client", required=True)
    parser.add_argument("--position", required=True)
    parser.add_argument("--size")
    parser.add_argument("--editor-position")
    parser.add_argument("--editor-size")
    parser.add_argument("--open-focus")
    parser.add_argument("--refresh-interval")
    parser.add_argument("--refresh-interval-inactive-pane")
    parser.add_argument("--refresh-interval-inactive-window")
    parser.add_argument("--enable-debug-pane")
    parser.add_argument("--focus")
    parser.add_argument("--pane-id", required=True)

    parsed_args = parser.parse_args()

    pane_id = parsed_args.pane_id
    nvim_command = parsed_args.nvim_command
    tree_nvim_init_file = parsed_args.tree_nvim_init_file
    editor_nvim_init_file = parsed_args.editor_nvim_init_file
    python_command = parsed_args.python_command
    tree_client = parsed_args.tree_client
    position = parsed_args.position
    size = parsed_args.size
    editor_position = parsed_args.editor_position
    editor_size = parsed_args.editor_size
    open_focus = parsed_args.open_focus
    refresh_interval = parsed_args.refresh_interval
    refresh_interval_inactive_pane = parsed_args.refresh_interval_inactive_pane
    refresh_interval_inactive_window = parsed_args.refresh_interval_inactive_window
    enable_debug_pane = parsed_args.enable_debug_pane
    focus = parsed_args.focus

    current_dir = os.path.dirname(os.path.realpath(__file__))

    pane_width = int(get_pane_info(pane_id, "#{pane_width}"))
    pane_current_path = get_pane_info(pane_id, "#{pane_current_path}")

    root_dir = get_tree_initial_root_dir(pane_current_path)

    registered_pane_prefix = get_tmux_option(
        "@treemux-registered-pane-prefix", "treemux-registered-pane-"
    )
    registered_sidebar_prefix = get_tmux_option(
        "@treemux-registered-sidebar-prefix", "treemux-registered-sidebar-"
    )

    def sidebar_registration():
        return get_tmux_option(f"{registered_pane_prefix}{pane_id}", "")

    def sidebar_pane_id():
        registration = sidebar_registration()
        if registration:
            return registration.split(",")[0]
        return ""

    def sidebar_pane_args():
        registration = sidebar_registration()
        if registration:
            return ",".join(registration.split(",")[1:])
        return ""

    def register_sidebar(sidebar_id):
        set_tmux_option(f"{registered_sidebar_prefix}{sidebar_id}", pane_id)
        set_tmux_option(
            f"{registered_pane_prefix}{pane_id}", f"{sidebar_id},{parsed_args.args}"
        )

    def sidebar_exists():
        pane_id = sidebar_pane_id()
        try:
            panes = (
                subprocess.check_output(["tmux", "list-panes", "-F", "#{pane_id}"])
                .decode("utf-8")
                .splitlines()
            )
            return pane_id in panes
        except subprocess.CalledProcessError:
            return False

    def has_sidebar():
        return bool(sidebar_registration()) and sidebar_exists()

    def kill_sidebar():
        nonlocal pane_width
        s_pane_id = sidebar_pane_id()
        s_args = sidebar_pane_args().split(",")
        s_position = s_args[5]
        s_width = int(get_pane_info(s_pane_id, "#{pane_width}"))

        subprocess.run([f"{current_dir}/save_sidebar_width.sh", root_dir, str(s_width)])

        subprocess.run(["tmux", "kill-pane", "-t", s_pane_id])

        new_pane_width = int(get_pane_info(pane_id, "#{pane_width}"))
        if new_pane_width == pane_width:
            direction_flag = "-L" if "left" in s_position else "-R"
            subprocess.run(["tmux", "resize-pane", direction_flag, str(s_width + 1)])

        pane_width = new_pane_width

    def sidebar_left():
        return "left" in position

    def no_focus():
        return not focus.startswith("focus")

    def size_defined():
        return bool(size)

    def desired_sidebar_size():
        half_pane = pane_width // 2
        sidebar_file = os.path.join(os.environ["HOME"], ".treemux-sidebar-size")
        if os.path.exists(sidebar_file):
            with open(sidebar_file, "r") as f:
                for line in f:
                    d, w = line.strip().split(",")
                    if d == root_dir:
                        return int(w)

        if size_defined() and int(size) < half_pane:
            return int(size)

        return half_pane

    def use_inverted_size():
        tmux_version = get_tmux_option("version", "0").replace(".", "")
        return int(tmux_version) <= 20

    def split_sidebar(position):
        sidebar_size = desired_sidebar_size()
        if use_inverted_size():
            sidebar_size = pane_width - sidebar_size - 1

        nvim_addr = f"/tmp/kiyoon-tmux-treemux-{pane_id}"

        if tree_client == "neo-tree":
            cmd = [
                "tmux",
                "new-window" if position == "left" else "split-window",
                "-c",
                root_dir,
                "-P",
                "-F",
                "#{pane_id}",
                f"{nvim_command} '{root_dir}' --listen '{nvim_addr}' '+Neotree'",
            ]
            if position == "right":
                cmd.extend(["-h", "-l", str(sidebar_size)])
        else:
            cmd = [
                "tmux",
                "new-window" if position == "left" else "split-window",
                "-c",
                root_dir,
                "-P",
                "-F",
                "#{pane_id}",
                f"{nvim_command} '{root_dir}' --listen '{nvim_addr}' "
                f"""'+lua require("nvim-tree.api").tree.open({{current_window = true}})' """
                f'\'+let g:nvim_tree_remote_tmux_pane="{pane_id}"'
                f'\'+let g:nvim_tree_remote_tmux_split_position="{editor_position}"'
                f'\'+let g:nvim_tree_remote_tmux_split_size="{editor_size}"'
                f'\'+let g:nvim_tree_remote_tmux_focus="{open_focus}"'
                f'\'+let g:nvim_tree_remote_tmux_editor_init_file="{editor_nvim_init_file}"'
                f'\'+let g:nvim_tree_remote_treemux_path="{os.path.dirname(current_dir)}"'
                f'\'+let g:nvim_tree_remote_python_path="{python_command}"',
            ]
            if tree_nvim_init_file:
                cmd.extend(["-u", tree_nvim_init_file])
            if position == "right":
                cmd.extend(["-h", "-l", str(sidebar_size)])

        sidebar_id = subprocess.check_output(cmd).decode("utf-8").strip()

        if position == "left":
            subprocess.run(
                [
                    "tmux",
                    "join-pane",
                    "-hb",
                    "-l",
                    str(sidebar_size),
                    "-t",
                    pane_id,
                    "-s",
                    sidebar_id,
                ]
            )

        if int(enable_debug_pane) == 0:
            subprocess.Popen(
                [
                    f"{current_dir}/watch_and_update.sh",
                    pane_id,
                    sidebar_id,
                    root_dir,
                    nvim_addr,
                    refresh_interval,
                    refresh_interval_inactive_pane,
                    refresh_interval_inactive_window,
                    nvim_command,
                    python_command,
                    tree_client,
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        else:
            debug_cmd = f"'{current_dir}/watch_and_update.sh' '{pane_id}' '{sidebar_id}' '{root_dir}' '{nvim_addr}' '{refresh_interval}' '{refresh_interval_inactive_pane}' '{refresh_interval_inactive_window}' '{nvim_command}' '{python_command}' '{tree_client}'; sleep 100"
            subprocess.run(
                [
                    "tmux",
                    "split-window",
                    "-h",
                    "-l",
                    str(sidebar_size),
                    "-c",
                    root_dir,
                    "-P",
                    "-F",
                    "#{pane_id}",
                    debug_cmd,
                ]
            )

        return sidebar_id

    def create_sidebar():
        position = "left" if sidebar_left() else "right"
        sidebar_id = split_sidebar(position)
        register_sidebar(sidebar_id)
        if no_focus():
            subprocess.run(["tmux", "last-pane"])

    def current_pane_is_sidebar():
        return bool(get_tmux_option(f"{registered_sidebar_prefix}{pane_id}", ""))

    def current_pane_too_narrow():
        minimum_width = int(get_tmux_option("@treemux-minimum-width-for-sidebar", "10"))
        return pane_width < minimum_width

    def execute_command_from_main_pane():
        main_pane_id = get_tmux_option(f"{registered_sidebar_prefix}{pane_id}", "")
        subprocess.run(["python3", f"{current_dir}/toggle.py", parsed_args.args, main_pane_id])

    def exit_if_pane_too_narrow():
        if current_pane_too_narrow():
            subprocess.run(
                ["tmux", "display-message", "Pane too narrow for the sidebar"]
            )
            exit()

    def toggle_sidebar():
        if has_sidebar():
            kill_sidebar()
        else:
            exit_if_pane_too_narrow()
            create_sidebar()

    subprocess.run([f"{current_dir}/check_tmux_version.sh", "1.8"])

    if current_pane_is_sidebar():
        execute_command_from_main_pane()
    else:
        toggle_sidebar()


if __name__ == "__main__":
    main()
