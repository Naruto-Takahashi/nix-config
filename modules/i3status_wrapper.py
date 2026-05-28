#!/usr/bin/env python3
import sys
import json
import subprocess
import re

def get_tiling_layout():
    try:
        proc = subprocess.run(["i3-msg", "-t", "get_tree"], capture_output=True, text=True)
        if proc.returncode != 0:
            return "splith"
        tree = json.loads(proc.stdout)
        
        def find_focused_layout(node):
            if node.get("focused") is True:
                return None
            for child in node.get("nodes", []) + node.get("floating_nodes", []):
                layout = find_focused_layout(child)
                if layout is not None:
                    return layout
                if any(c.get("focused") or find_focused_layout(c) is not None for c in node.get("nodes", []) + node.get("floating_nodes", [])):
                    return node.get("layout", "splith")
            return None
        
        layout = find_focused_layout(tree)
        return layout if layout else "splith"
    except Exception:
        return "splith"

def get_gpu_util():
    try:
        proc = subprocess.run(["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"], capture_output=True, text=True)
        if proc.returncode == 0:
            return int(proc.stdout.strip())
    except Exception:
        pass
    return None

def main():
    # Spawn i3status subprocess
    proc = subprocess.Popen(["i3status"], stdout=subprocess.PIPE, text=True)
    
    # Read headers
    line1 = proc.stdout.readline()
    print(line1, end="")
    line2 = proc.stdout.readline()
    print(line2, end="")
    
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        
        prefix = ""
        if line.startswith(","):
            prefix = ","
            json_str = line[1:].strip()
        else:
            json_str = line.strip()
            
        try:
            blocks = json.loads(json_str)
        except Exception:
            print(line, end="")
            continue
            
        new_blocks = []
        
        orig_map = {b.get("name"): b for b in blocks}
        
        def get_util_color(pct):
            if pct >= 80:
                return "#f7768e" # Red
            elif pct >= 50:
                return "#e0af68" # Yellow
            else:
                return "#9ece6a" # Green
                
        # 2. CPU Usage
        cpu_block = orig_map.get("cpu_usage")
        if cpu_block:
            match = re.search(r"(\d+)", cpu_block.get("full_text", ""))
            if match:
                cpu_pct = int(match.group(1))
                cpu_block["color"] = get_util_color(cpu_pct)
            new_blocks.append(cpu_block)
            
        # 3. GPU Usage
        gpu_pct = get_gpu_util()
        if gpu_pct is not None:
            new_blocks.append({
                "name": "gpu_util",
                "full_text": f"GPU {gpu_pct}%",
                "color": get_util_color(gpu_pct)
            })
            
        # 4. RAM (Memory)
        ram_block = orig_map.get("memory")
        if ram_block:
            match = re.search(r"RAM\s+([\d\.]+)", ram_block.get("full_text", ""))
            if match:
                used_gb = float(match.group(1))
                ram_pct = (used_gb / 32.0) * 100.0
                ram_block["color"] = get_util_color(ram_pct)
                ram_block["full_text"] = f"RAM {ram_pct:.0f}%"
            new_blocks.append(ram_block)
            
        # 5. ETH (Ethernet)
        eth_block = orig_map.get("ethernet")
        if eth_block:
            if "down" in eth_block.get("full_text", "").lower():
                eth_block["color"] = "#f7768e"
            else:
                eth_block["color"] = "#9ece6a"
            new_blocks.append(eth_block)
            
        # 6. Time (tztime local)
        time_block = orig_map.get("tztime")
        if time_block:
            new_blocks.append(time_block)
            
        print(f"{prefix}{json.dumps(new_blocks)}", flush=True)

if __name__ == "__main__":
    main()
