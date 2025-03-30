#!/bin/bash

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
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Use ripgrep (rg) to search all files at once
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

done

echo "UUID addition complete"
