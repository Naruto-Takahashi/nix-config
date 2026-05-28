#!/usr/bin/env python3
# =========================================================================
# Rofi Window Switcher Wrapper
# 最小化（Scratchpad）されていたウィンドウを復元した際、
# 自動的にタイリング（Tiling）表示に戻すスクリプト。
# =========================================================================
import json
import subprocess
import sys

def get_tree():
    try:
        out = subprocess.check_output(["i3-msg", "-t", "get_tree"])
        return json.loads(out)
    except Exception as e:
        print(f"Error getting i3 tree: {e}", file=sys.stderr)
        return None

def find_scratchpad_ids(node, in_scratchpad=False):
    ids = set()
    is_scratch = in_scratchpad or (node.get("name") == "__i3_scratch")
    
    if is_scratch and node.get("window") is not None:
        ids.add(node["id"])
        
    for child in node.get("nodes", []):
        ids.update(find_scratchpad_ids(child, is_scratch))
    for child in node.get("floating_nodes", []):
        ids.update(find_scratchpad_ids(child, is_scratch))
        
    return ids

def find_focused_id(node):
    if node.get("focused"):
        return node.get("id")
    for child in node.get("nodes", []):
        fid = find_focused_id(child)
        if fid:
            return fid
    for child in node.get("floating_nodes", []):
        fid = find_focused_id(child)
        if fid:
            return fid
    return None

def main():
    tree = get_tree()
    scratch_ids = set()
    if tree:
        scratch_ids = find_scratchpad_ids(tree)
    
    # Rofiウィンドウ選択を起動 (洗練されたグラフィカル・グリッド形式)
    rofi_theme = """
    * {
        bg: #0f0f0f;
        fg: #ffffff;
        accent: #ffc20d;
        bg-alt: #1a1a1a;
        border-radius: 12px;
    }
    window {
        width: 75%;
        border: 1px;
        border-color: @accent;
        background-color: @bg;
        padding: 30px;
    }
    mainbox {
        background-color: transparent;
        children: [ listview ];
    }
    listview {
        columns: 3;
        lines: 2;
        spacing: 30px;
        background-color: transparent;
        fixed-columns: true;
    }
    element {
        orientation: vertical;
        padding: 15px;
        background-color: @bg-alt;
        border: 1px;
        border-color: #333333;
    }
    element selected {
        background-color: #262626;
        border-color: @accent;
    }
    element-icon {
        size: 160px;
        horizontal-align: 0.5;
        background-color: transparent;
    }
    element-text {
        horizontal-align: 0.5;
        vertical-align: 0.5;
        padding: 8px;
        margin: 10px 0px 0px 0px;
        background-color: rgba(0, 0, 0, 0.7); /* テキストの視認性確保のための暗い背景 */
        color: @fg;
        border-radius: 6px;
    }
    """
    rofi_cmd = [
        "rofi",
        "-show", "window",
        "-show-icons",
        "-window-thumbnail",
        "-theme-str", rofi_theme
    ]
    cmd = ["env", "XDG_SESSION_TYPE=x11"] + rofi_cmd + sys.argv[1:]
    subprocess.run(cmd)
    
    # 選択後のウィンドウ情報を取得して自動的に浮動表示（Floating）を解除する
    new_tree = get_tree()
    if new_tree and scratch_ids:
        focused_id = find_focused_id(new_tree)
        if focused_id in scratch_ids:
            # 最小化（Scratchpad）から復元されたウィンドウであるため、タイリング表示へ戻す
            subprocess.run(["i3-msg", "floating disable"])

if __name__ == "__main__":
    main()
