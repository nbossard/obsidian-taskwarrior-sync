#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "mtt - Loading configuration from .env file"
    set -o allexport
    source .env
    set +o allexport
fi

# Show help message
show_help() {
    echo "Usage: mtt_md_import.sh [--help] --task JSON"
    echo
    echo "Import a TaskWarrior task (in JSON format) back to its Obsidian markdown file."
    echo "The script uses the annotation containing 'Source:' to locate the original file."
    echo "And the UUID to modify the good task."
    echo
    echo "You tipically dont call this program directly, you let taskwarrior call it thought a hook. See doc."
    echo
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --task JSON  The task in JSON format (required)"
    echo
    echo "Sample call:"
    echo "mtt_md_import --task '{\"id\":0,\"description\":\"feed the cat\",\"end\":\"20250328T213759Z\",\"entry\"::\"20250328T102249Z\",\"modified\":\"20250328T213759Z\",\"project\":\"paymetrics\",\"status\":\"completed\",\"uuid\":\"eb48e204-e8be-416b-857d-8154edbbd7ad\",\"annotations\":[{\"entry\":\"20250328T213742Z\",\"description\":\"Source: \/Users\/nbossard\/PilotageDistri\/business-server\/documentation\/Agenda\/2025-03-28.md\"}],\"tags\":[\"Nicolas\"],\"urgency\":4.4}'"
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
                echo "mtt - Error: --task requires JSON data"
                show_help
            fi
            ;;
        *) echo "mtt - Unknown parameter: $1"; show_help ;;
    esac
    shift
done

if [ -z "$task_json" ]; then
    echo "mtt - Error: --task parameter is required"
    show_help
fi

echo "mtt - task to be imported is : $task_json"

# Extract source file path from annotations
echo "mtt - Extract source file path from annotations..."
echo "mtt - Checking annotations structure..."
annotations_exist=$(echo "$task_json" | jq 'has("annotations")')
if [ "$annotations_exist" != "true" ]; then
    echo "Error: Task JSON has no annotations field"
    echo "Task JSON received: $task_json"
    exit 1
fi

source_file=$(echo "$task_json" | jq -r 'if .annotations then (.annotations[] | select(.description | startswith("Source:")) | .description) else empty end' | sed 's/^Source: //')

if [ -z "$source_file" ]; then
    echo "mtt - Error: No Source annotation found in task"
    echo "mtt - Task JSON received: $task_json"
    exit 1
fi

if [ ! -f "$source_file" ]; then
    echo "mtt - Error: Source file not found: $source_file"
    exit 1
fi

echo "mtt - Processing task for file: $source_file"

# Extract task attributes
description=$(echo "$task_json" | jq -r '.description')
status=$(echo "$task_json" | jq -r '.status // empty')
start_date=$(echo "$task_json" | jq -r '.start // empty')
end_date=$(echo "$task_json" | jq -r '.end // empty')
due_date=$(echo "$task_json" | jq -r '.due // empty')
tags=$(echo "$task_json" | jq -r '.tags // empty | join(",")')
uuid=$(echo "$task_json" | jq -r '.uuid // empty')

# Convert tags to Obsidian format (@tag or #tag)
formatted_tags=""
if [ "$tags" != "" ]; then
    # Convert comma-separated tags to space-separated @tags
    formatted_tags=" $(echo "$tags" | tr ',' ' ' | sed 's/\([^ ]*\)/#\1/g')"
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
updated_task_line+="$formatted_tags"
# uuid should be last for readability
[ -n "$uuid" ] && updated_task_line+=" [id:: $uuid]"

# Find and replace the task in the file
sed -i.bak -E "s/^- \[ \].*\[id:: $uuid\].*$/$updated_task_line/" "$source_file"

# Remove backup file
rm "${source_file}.bak"

echo "mtt - Task updated in file $source_file"
echo "mtt - New task is $updated_task_line"

