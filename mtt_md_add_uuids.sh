#!/usr/bin/env bash
# vim: set tabstop=4 shiftwidth=4 expandtab list:

# Store mappings directly in temporary file
store_mapping() {
    local short_id="$1"
    local uuid="$2"
    echo "$short_id:$uuid" >> /tmp/id_mappings.tmp
}

# Function to get UUID for a short_id
get_uuid_for_short_id() {
    local short_id="$1"
    if [[ -f /tmp/id_mappings.tmp ]]; then
        awk -F: -v sid="$short_id" '$1 == sid {print $2}' /tmp/id_mappings.tmp
    fi
}

# Function to check if a short_id exists
has_mapping() {
    local short_id="$1"
    if [[ -f /tmp/id_mappings.tmp ]]; then
        grep -q "^${short_id}:" /tmp/id_mappings.tmp
        return $?
    fi
    return 1
}

# Function to print debug messages
debug_echo() {
    if [[ "$debug_mode" = true ]]; then
        echo "DEBUG: $1"
    fi
}

echo
echo "mtt - ------------ starting add UUIDs in markdown -----------------"
echo

show_help() {
    echo "Usage: mtt_md_add_uuids.sh [OPTIONS]"
    echo
    echo "Automatically adds UUIDs to markdown tasks that don't have them."
    echo "Searches for lines starting with '- [ ]' and adds [id:: uuid] if not present."
    echo
    echo "For example will transform a line like :"
    echo "- [ ] feed the cat"
    echo "to"
    echo "- [ ] feed the cat [id:: eb48e204-e8be-416b-857d-8154edbbd7ad]"
    echo
    echo "Options:"
    echo "  --help              Show this help message and exit"
    echo "  --mask PATTERN      File pattern to search (default: '*.md')"
    echo "  --debug            Enable debug mode to show detailed commands"
    echo
    echo "Example:"
    echo "  ./add_uuids.sh"
    echo "  ./add_uuids.sh --mask '*.md'"
    echo "  ./add_uuids.sh --mask 'daily/2025-03-28.md'"
    echo "  ./add_uuids.sh --help"
}

# Default file pattern
file_pattern="**/*.md"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help; exit 0 ;;
        --mask)
            shift
            if [[ -n "$1" ]]; then
                file_pattern="$1"
            else
                echo "Error: --mask requires a pattern"
                show_help
                exit 1
            fi
            ;;
        --debug)
            debug_mode=true
            ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done

# First pass: build mapping of short IDs to UUIDs
echo "First pass: Building mapping of short IDs to UUIDs..."
echo "Searching for short IDs with pattern: \\[id:: [a-z0-9]{6}\\]"
debug_echo "Running: rg --no-heading --line-number --with-filename \"\\[id:: [a-z0-9]{6}\\]\" $file_pattern"
rg --no-heading --line-number --with-filename "\\[id:: [a-z0-9]{6}\\]" $file_pattern | while IFS=: read -r file line_number line; do
    echo "Found line with short ID: $line"
    # Extract the short ID using regex
    if [[ $line =~ \[id::\ ([a-z0-9]{6})\] ]]; then
        short_id="${BASH_REMATCH[1]}"
        new_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
        store_mapping "$short_id" "$new_uuid"
        echo "Mapping short ID $short_id to UUID $new_uuid"
    fi
done

# Second pass: Update all references first
if [[ -f /tmp/id_mappings.tmp ]]; then
    echo "Updating references..."
    while IFS=: read -r short_id uuid; do
        echo "Updating dependsOn: $short_id -> $uuid in all files"
        rg --files-with-matches "\[dependsOn:: $short_id\]" $file_pattern | while read -r file; do
            echo "Updating dependsOn in $file"
            sed -i.bak "s/\[dependsOn:: $short_id\]/[dependsOn:: $uuid]/g" "$file"
            rm -f "${file}.bak"
        done
    done < /tmp/id_mappings.tmp

    # Third pass: Update the actual IDs
    echo "Updating task IDs..."
    while IFS=: read -r short_id uuid; do
        echo "Updating ID: $short_id -> $uuid in all files"
        rg --files-with-matches "\[id:: $short_id\]" $file_pattern | while read -r file; do
            echo "Updating ID in $file"
            sed -i.bak "s/\[id:: $short_id\]/[id:: $uuid]/g" "$file"
            rm -f "${file}.bak"
        done
    done < /tmp/id_mappings.tmp
fi

# Clean up temporary file
rm -f /tmp/id_mappings.tmp

# Fourth pass: Add UUIDs to tasks without any ID
rg --no-heading --line-number --with-filename "^- \\[ \\] " $file_pattern | while IFS=: read -r file line_number line; do
    echo "......................................"
    echo "scanning file $file"
    echo "scanning line $line"

    # Check if line already has an ID
    if ! echo "$line" | grep -q "\[id::"; then
        # Generate a new UUID
        new_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')

        # Create the new line with UUID
        new_line="${line} [id:: ${new_uuid}]"

        echo "new line is : $new_line"

        # Replace the line in the file using awk
        awk -v ln="$line_number" -v old="$line" -v new="$new_line" '
            NR == ln {$0 = new; print; next}
            {print}
        ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

        echo "Added UUID to line: $new_line"
    else
        echo "Line already has an ID, skipping"
    fi
    echo "......................................"
done

echo "UUID addition complete"
