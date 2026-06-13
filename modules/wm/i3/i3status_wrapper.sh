#!/usr/bin/env bash
# i3status wrapper to add focused workspace tiling direction

# Run i3status and read line by line
i3status | while read -r line; do
  if [[ "$line" =~ ^,\[.*\]$ ]]; then
    prefix=","
    json_array="${line#,}"
  elif [[ "$line" =~ ^\[.*\]$ ]]; then
    prefix=""
    json_array="$line"
  else
    echo "$line"
    continue
  fi

  layout=$(i3-msg -t get_tree | jq -r 'recurse(.nodes[], .floating_nodes[]) | select(any(.nodes[]; .focused == true) or any(.floating_nodes[]; .focused == true)) | .layout' 2>/dev/null)
  
  if [ "$layout" = "splith" ]; then
    indicator="SPLIT: H"
    color="#ffc20d"
  elif [ "$layout" = "splitv" ]; then
    indicator="SPLIT: V"
    color="#f7768e"
  else
    indicator="SPLIT: -"
    color="#888888"
  fi

  new_block=$(jq -n --arg text "$indicator" --arg col "$color" '{name: "tiling_direction", full_text: $text, color: $col}')

  gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
  if [ -n "$gpu_util" ]; then
    # Make GPU block white as requested
    gpu_block=$(jq -n --arg text "GPU ${gpu_util}%" --arg col "#ffffff" '{name: "gpu_util", full_text: $text, color: $col}')
    # Prepend blocks and dynamically force the ethernet block color to white
    modified_json=$(echo "$json_array" | jq --argjson block "$new_block" --argjson gpu "$gpu_block" '([$block, $gpu] + .) | map(if .name == "ethernet" then .color = "#ffffff" else . end)' -c)
  else
    modified_json=$(echo "$json_array" | jq --argjson block "$new_block" '([$block] + .) | map(if .name == "ethernet" then .color = "#ffffff" else . end)' -c)
  fi
  
  echo "${prefix}${modified_json}"
done
