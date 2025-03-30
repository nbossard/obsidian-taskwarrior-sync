#!/bin/bash

echo
echo "mtt - ------------ starting markdown tasks export -----------------"
echo
#
# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "Loading configuration from .env file"
    set -o allexport
    source .env
    set +o allexport
fi

# Show help message
show_help() {
    echo "Usage: mtt_md_export.sh [--help] [--mask PATTERN] [--project NAME]"
    echo
    echo "Export markdown tasks to TaskWarrior compatible NDJSON format."
    echo
    echo "The script searches for markdown task items (- [ ]) in files matching the mask pattern"
    echo "and extracts task attributes like start date, end date, due date,..."
    echo "and task ID into a TaskWarrior import compatible NDJSON file (tasks.ndjson)."
    echo
    echo "Options:"
    echo "  --help           Show this help message"
    echo "  --mask PATTERN   File pattern to search (default: *.md)"
    echo "  --project NAME   Assign tasks to a specific project"
    echo
    echo "Environment Variables:"
    echo "  OE_MASK         Alternative to --mask (command line takes precedence)"
    echo "  OE_PROJECT      Alternative to --project (command line takes precedence)"
    exit 0
}

# Set defaults from environment variables or fallback values
file_mask="${OE_MASK:-*.md}"
project_name="${OE_PROJECT:-}"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        --mask)
            shift
            if [[ -n "$1" ]]; then
                file_mask="$1"
            else
                echo "Error: --mask requires a pattern"
                show_help
                exit 1
            fi
            ;;
        --project)
            shift
            if [[ -n "$1" ]]; then
                project_name="$1"
            else
                echo "Error: --project requires a name"
                show_help
            fi
            ;;
        *) echo "Unknown parameter: $1"; show_help ;;
    esac
    shift
done

# Display current configuration
echo "Current configuration:"
echo "~~~~~~~~~~~~~~~~~~~~"
echo "File mask: $file_mask"
echo "Project: ${project_name:-<none>}"
echo "Output file: tasks.ndjson"
echo "~~~~~~~~~~~~~~~~~~~~"
echo

# Create or overwrite the output file
output_file="tasks.ndjson"
> "$output_file"

# Use ripgrep (rg) to search all files at once
echo "calling ripgrep with : rg   --no-heading --line-number --with-filename \"^- \\[ \\] \" \"$file_mask\""
rg --no-heading --line-number --with-filename "^- \\[ \\] "  $file_mask | while IFS=: read -r file line_number line; do
  echo "......................................................................"
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

  # Remove tags @toto from the description
  description=$(echo "$description" | sed -E 's/@[^ ]+//')

  # Trim any extra spaces
  description=$(echo "$description" | sed -E 's/^[[:space:]]+|[[:space:]]+$//')
  echo "cleaned description is \"$description\""

  # Extract the start date if present
  start=$(echo "$line" | rg -o "\[start:: [^]]+\]" | sed -E 's/\[start:: (.+)\]/\1/')
  echo "found start : $start"

  # Extract the end date if present
  end=$(echo "$line" | rg -o "\[end:: [^]]+\]" | sed -E 's/\[end:: (.+)\]/\1/')
  echo "found end : $end"

  # Extract the due date if present
  due=$(echo "$line" | rg -o "\[due:: [^]]+\]" | sed -E 's/\[due:: (.+)\]/\1/')
  echo "found due : $due"

  # Extract the id if present
  id=$(echo "$line" | rg -o "\[id:: [^]]+\]" | sed -E 's/\[id:: (.+)\]/\1/')
  echo "found id : $id"

  # Extract all @ tags
  # CONFLICT @ concept does not exist in taskwarrior, doing nothing for now
  # at_tags=$(echo "$line" | grep -o '@[[:alnum:]]\+' | sed 's/@//' | tr '\n' ',' | sed 's/,$//')
  # echo "found @ tags: $at_tags"

  # Extract all # tags
  hash_tags=$(echo "$line" | grep -o '#[[:alnum:]]\+' | sed 's/#//' | tr '\n' ',' | sed 's/,$//')
  echo "found # tags: $hash_tags"

  # Combine all tags, removing duplicates
  all_tags=""
  if [ -n "$at_tags" ] || [ -n "$hash_tags" ]; then
    # Combine tags with comma only if both are non-empty
    combined_tags=""
    if [ -n "$at_tags" ] && [ -n "$hash_tags" ]; then
      combined_tags="${at_tags},${hash_tags}"
    else
      combined_tags="${at_tags}${hash_tags}"
    fi
    all_tags=$(echo "$combined_tags" | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
  fi
  echo "combined tags: $all_tags"

  # Get absolute path of the source file
  abs_file_path=$(realpath "$file")

  # Generate JSON object
  json="{\"description\":\"$description\",\"status\":\"pending\""
  [ -n "$start" ] && json+=",\"start\":\"$start\""
  [ -n "$end" ] && json+=",\"end\":\"$end\""
  [ -n "$due" ] && json+=",\"due\":\"$due\""
  [ -n "$id" ] && json+=",\"uuid\":\"$id\""
  [ -n "$project_name" ] && json+=",\"project\":\"$project_name\""
  [ -n "$all_tags" ] && json+=",\"tags\":[\"$(echo "$all_tags" | sed 's/,/\",\"/g')\"]"
  json+=",\"annotations\":[{\"description\":\"Source: $abs_file_path\"}]"
  json+="}"

  echo "$json" >> "$output_file"
done

echo "Tasks extracted to $output_file"
