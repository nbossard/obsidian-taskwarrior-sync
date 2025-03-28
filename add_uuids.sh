#!/bin/bash

# Use ripgrep (rg) to search all files at once
rg "^- \\[ \\] " --no-heading --line-number --with-filename --glob "*.md" | while IFS=: read -r file line_number line; do
  echo "======================================================================"
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
