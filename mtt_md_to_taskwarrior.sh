#!/bin/bash
# vim: set tabstop=4 shiftwidth=4 expandtab list:

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
    echo "Usage: mtt_md_to_taskwarrior.sh [--help] [--mask PATTERN] [--project NAME]"
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

# Function to convert readable format (2025-03-29) to TaskWarrior date format (20250329T120000Z)
# to  suitable for obsidian "tasks" plugin
format_date() {
    local input_date="$1"
    # Convert from YYYY-MM-DD to YYYYMMDDThhmmssZ format
    # Adding default time 12:00:00
    if [[ $input_date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "${input_date//-/}T120000Z"
    else
        # If input is not in expected format, return as-is
        echo "$input_date"
    fi
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
    #  Extract the task description
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

    # Remove [dependsOn:: ...] from the description
    description=$(echo "$description" | sed -E 's/\[dependsOn:: [^]]+\]//')

    # Remove [priority:: ...] from the description
    description=$(echo "$description" | sed -E 's/\[priority:: [^]]+\]//')

    # Remove tags #toto from the description
    description=$(echo "$description" | sed -E 's/#[^ ]+//')

    # Remove tags @toto from the description
    # CONFLICT @ concept does not exist in taskwarrior, doing nothing for now
    # description=$(echo "$description" | sed -E 's/@[^ ]+//')

    # remove quotes
    description=$(echo "$description" | sed -E "s/'//g")

    # Trim any extra spaces
    description=$(echo "$description" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

    # escape doubles quotes "
    escaped_description=$(echo "$description" | sed 's/"/\\"/g')
    echo "cleaned description is \"$escaped_description\""

    # Extract the start date if present
    start=$(echo "$line" | rg -o "\[start:: [^]]+\]" | sed -E 's/\[start:: (.+)\]/\1/')
    start=$(format_date "$start")
    if [ -n "$start" ]; then
        echo "found start : $start, will be matched to \"wait\""
    fi

    # Extract the end date if present
    end=$(echo "$line" | rg -o "\[end:: [^]]+\]" | sed -E 's/\[end:: (.+)\]/\1/')
    end=$(format_date "$end")
    if [ -n "$end" ]; then
        echo "found end : $end"
    fi

    # Extract the due date if present
    due=$(echo "$line" | rg -o "\[due:: [^]]+\]" | sed -E 's/\[due:: (.+)\]/\1/')
    due=$(format_date "$due")
    if [ -n "$due" ]; then
        echo "found due : $due"
    fi

    # Extract the id if present
    id=$(echo "$line" | rg -o "\[id:: [^]]+\]" | sed -E 's/\[id:: (.+)\]/\1/')
    if [ -n "$id" ]; then
        echo "found id : $id"
    fi

    # Extract the dependsOn if present
    dependsOn=$(echo "$line" | rg -o "\[dependsOn:: [^]]+\]" | sed -E 's/\[dependsOn:: (.+)\]/\1/')
    if [ -n "$dependsOn" ]; then
        echo "found dependsOn : $dependsOn"
    fi

    # Extract the priority
    priority=$(echo "$line" | rg -o "\[priority:: [^]]+\]" | sed -E 's/\[priority:: (.+)\]/\1/')
    if [ -n "$priority" ]; then
        echo "found priority : $priority"
        # Convert the priority : high to H,...
        if [ -n "$priority" ]; then
            case "$priority" in  # Convert to lowercase for comparison
                "highest") priority="H" ;;
                "high") priority="H" ;;
                "medium") priority="M" ;;
                "low") priority="L" ;;
                "lowest") priority="L" ;;
            esac
        fi
        echo "converted priority : $priority"
    fi

    # Extract all @ tags
    # CONFLICT @ concept does not exist in taskwarrior, doing nothing for now
    # at_tags=$(echo "$line" | grep -o '@[[:alnum:]]\+' | sed 's/@//' | tr '\n' ',' | sed 's/,$//')
    # echo "found @ tags: $at_tags"

    # Extract all # tags
    hash_tags=$(echo "$line" | grep -o '#[[:alnum:]]\+' | sed 's/#//' | tr '\n' ',' | sed 's/,$//')
    if [ -n "$hash_tags" ]; then
        echo "found # tags: $hash_tags"
    fi

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
    if [ -n "$all_tags" ]; then
        echo "combined tags: $all_tags"
    fi

    # Get absolute path of the source file
    abs_file_path=$(realpath "$file")

    # Generate JSON object
    # Escape double quotes in description for JSON
    json="{\"description\":\"$escaped_description\",\"status\":\"pending\""
    #  note, this is not a bug : obsidian tasks uses "start" while taskwarrior uses "wait"
    [ -n "$start" ] && json+=",\"wait\":\"$start\""
    [ -n "$end" ] && json+=",\"end\":\"$end\""
    [ -n "$due" ] && json+=",\"due\":\"$due\""
    [ -n "$id" ] && json+=",\"uuid\":\"$id\""
    [ -n "$dependsOn" ] && json+=",\"depends\":\"$dependsOn\""
    [ -n "$project_name" ] && json+=",\"project\":\"$project_name\""
    [ -n "$priority" ] && json+=",\"priority\":\"$priority\""
    [ -n "$all_tags" ] && json+=",\"tags\":[\"$(echo "$all_tags" | sed 's/,/\",\"/g')\"]"
    json+=",\"annotations\":[{\"description\":\"Source: $abs_file_path\"}]"
    json+="}"

    echo "$json" >> "$output_file"
    echo "......................................................................"
done

echo "Tasks extracted to $output_file"
echo "mtt - ------------ finished markdown tasks export -----------------"
