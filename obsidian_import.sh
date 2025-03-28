#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "Loading configuration from .env file"
    set -o allexport
    source .env
    set +o allexport
fi

# Show help message
show_help() {
    echo "Usage: obsidian_import.sh [--help] --task JSON"
    echo
    echo "Import a TaskWarrior task (in JSON format) back to its Obsidian markdown file."
    echo "The script uses the annotation containing 'Source:' to locate the original file."
    echo
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --task JSON  The task in JSON format (required)"
    exit 0
}

# Parse command line arguments
task_json=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        --task)
            shift
            if [[ -n "$1" ]]; then
                task_json="$1"
            else
                echo "Error: --task requires JSON data"
                show_help
            fi
            ;;
        *) echo "Unknown parameter: $1"; show_help ;;
    esac
    shift
done

if [ -z "$task_json" ]; then
    echo "Error: --task parameter is required"
    show_help
fi

echo "task to be imported is : $task_json"

# Extract source file path from annotations
echo "Extract source file path from annotations..."
echo "Checking annotations structure..."
annotations_exist=$(echo "$task_json" | jq 'has("annotations")')
if [ "$annotations_exist" != "true" ]; then
    echo "Error: Task JSON has no annotations field"
    echo "Task JSON received: $task_json"
    exit 1
fi

source_file=$(echo "$task_json" | jq -r 'if .annotations then (.annotations[] | select(.description | startswith("Source:")) | .description) else empty end' | sed 's/^Source: //')

if [ -z "$source_file" ]; then
    echo "Error: No Source annotation found in task"
    echo "Task JSON received: $task_json"
    exit 1
fi

if [ ! -f "$source_file" ]; then
    echo "Error: Source file not found: $source_file"
    exit 1
fi

echo "Processing task for file: $source_file"

# Extract task attributes
description=$(echo "$task_json" | jq -r '.description')
status=$(echo "$task_json" | jq -r '.status // empty')
start_date=$(echo "$task_json" | jq -r '.start // empty')
end_date=$(echo "$task_json" | jq -r '.end // empty')
due_date=$(echo "$task_json" | jq -r '.due // empty')
uuid=$(echo "$task_json" | jq -r '.uuid // empty')
tags=$(echo "$task_json" | jq -r '.tags // empty | join(",")')

# Convert tags to Obsidian format (@tag or #tag)
formatted_tags=""
if [ "$tags" != "" ]; then
    # Convert comma-separated tags to space-separated @tags
    formatted_tags=" $(echo "$tags" | tr ',' ' ' | sed 's/\([^ ]*\)/@\1/g')"
fi

# Build the updated task line
if [ "$status" = "completed" ]; then
    updated_task_line="- [x] $description"
else
    updated_task_line="- [ ] $description"
fi
[ -n "$start_date" ] && updated_task_line+=" [start:: $start_date]"
[ -n "$end_date" ] && updated_task_line+=" [end:: $end_date]"
[ -n "$due_date" ] && updated_task_line+=" [due:: $due_date]"
[ -n "$uuid" ] && updated_task_line+=" [id:: $uuid]"
updated_task_line+="$formatted_tags"

# Find and replace the task in the file
sed -i.bak -E "s/^- \[ \].*\[id:: $uuid\].*$/$updated_task_line/" "$source_file"

# Remove backup file
rm "${source_file}.bak"

echo "Task updated in $source_file"
echo "New task is $updated_task_line"

