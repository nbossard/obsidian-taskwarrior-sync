#!/bin/bash

# Show help message
show_help() {
    echo "Usage: tw_export.sh [--help]"
    echo
    echo "Export Obsidian tasks to TaskWarrior compatible NDJSON format."
    echo
    echo "The script searches for markdown task items (- [ ]) in all .md files"
    echo "and extracts task attributes like start date, end date, due date,"
    echo "and task ID into a TaskWarrior import compatible NDJSON file (tasks.ndjson)."
    echo
    echo "Options:"
    echo "  --help    Show this help message"
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        *) echo "Unknown parameter: $1"; show_help ;;
    esac
    shift
done

convert_date() {
  local input_date="$1"
  echo "${input_date//-/}"
}

# Create or overwrite the output file
output_file="tasks.ndjson"
> "$output_file"

# Use ripgrep (rg) to search all files at once
rg "^- \\[ \\] " --no-heading --line-number --with-filename --glob "*.md" | while IFS=: read -r file line_number line; do
  echo "======================================================================"
  echo "scanning file $file"
  echo "scanning line $line"
  # Extract the task description
  description=$(echo "$line" | sed -E 's/^- \[ \] (.+)/\1/')

  # Remove [start:: ...] from the description
  description=$(echo "$description" | sed -E 's/\[start:: [^]]+\]//')

  # Remove [end:: ...] from the description
  description=$(echo "$description" | sed -E 's/\[end:: [^]]+\]//')

  # Remove [end:: ...] from the description
  description=$(echo "$description" | sed -E 's/\[end:: [^]]+\]//')

  # Remove [due:: ...] from the description
  description=$(echo "$description" | sed -E 's/\[due:: [^]]+\]//')

  # Remove [id:: ...] from the description
  description=$(echo "$description" | sed -E 's/\[id:: [^]]+\]//')

  # Remove tags #toto from the description
  description=$(echo "$description" | sed -E 's/#[^ ]+//')
  #
  # Trim any extra spaces
  description=$(echo "$description" | sed -E 's/^[[:space:]]+|[[:space:]]+$//')
  echo "cleaned description is \"$description\""

  # Extract the start date if present
  start=$(echo "$line" | rg -o "\[start:: [^]]+\]" | sed -E 's/\[start:: (.+)\]/\1/')
  echo "found start : $start"
  start=$(convert_date "$start")
  echo "converted start : $start"

  # Extract the end date if present
  end=$(echo "$line" | rg -o "\[end:: [^]]+\]" | sed -E 's/\[end:: (.+)\]/\1/')
  echo "found end : $end"
  end=$(convert_date "$end")
  echo "converted start : $end"

  # Extract the due date if present
  due=$(echo "$line" | rg -o "\[due:: [^]]+\]" | sed -E 's/\[due:: (.+)\]/\1/')
  echo "found due : $due"
  due=$(convert_date "$due")
  echo "converted due : $due"

  # Extract the id if present
  id=$(echo "$line" | rg -o "\[id:: [^]]+\]" | sed -E 's/\[id:: (.+)\]/\1/')
  echo "found id : $id"

  # Generate JSON object
  json="{\"description\":\"$description\",\"status\":\"pending\""
  [ -n "$start" ] && json+=",\"start\":\"$start\""
  [ -n "$end" ] && json+=",\"end\":\"$end\""
  [ -n "$due" ] && json+=",\"due\":\"$due\""
  [ -n "$id" ] && json+=",\"uuid\":\"$id\""
  json+="}"

  echo "$json" >> "$output_file"
done

echo "Tasks extracted to $output_file"
