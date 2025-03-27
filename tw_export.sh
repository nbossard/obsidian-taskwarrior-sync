#!/bin/bash

# Create or overwrite the output file
output_file="tasks.ndjson"
> "$output_file"

# Use ripgrep (rg) to search all files at once
rg "^- \\[ \\] " --no-heading --line-number --with-filename --glob "*.md" | while IFS=: read -r file line_number line; do
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

  # Trim any extra spaces
  description=$(echo "$description" | sed -E 's/^[[:space:]]+|[[:space:]]+$//')
  echo "description is $description"

  # Extract the start date if present
  start=$(echo "$line" | rg -o "\[start:: [^\]]+\]" | sed -E 's/\[start:: (.+)\]/\1/')
  echo "found start : $start"

  # Extract the end date if present
  end=$(echo "$line" | rg -o "\[end:: [^\]]+\]" | sed -E 's/\[end:: (.+)\]/\1/')
  echo "found end : $end"

  # Extract the due date if present
  end=$(echo "$line" | rg -o "\[due:: [^\]]+\]" | sed -E 's/\[due:: (.+)\]/\1/')
  echo "found due : $due"

  # Extract the id if present
  end=$(echo "$line" | rg -o "\[id:: [^\]]+\]" | sed -E 's/\[id:: (.+)\]/\1/')
  echo "found id : $id"

  # Generate JSON object
  json="{\"description\":\"$description\",\"status\":\"pending\""
  [ -n "$start" ] && json+=",\"start\":\"$start\""
  [ -n "$end" ] && json+=",\"end\":\"$end\""
  [ -n "$due" ] && json+=",\"due\":\"$due\""
  json+="}"

  echo "$json" >> "$output_file"
done

echo "Tasks extracted to $output_file"
