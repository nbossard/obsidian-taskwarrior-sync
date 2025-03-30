#!/bin/bash

echo
echo "mtt - ============ starting sync ================="
echo

show_help() {
    echo "Usage: mtt_sync.sh [OPTIONS]"
    echo
    echo "Synchronizes tasks between Markdown files and TaskWarrior."
    echo
    echo "Options:"
    echo "  --help        Show this help message"
    echo "  --mask PATTERN  Specify a file pattern to filter markdown files"
    echo "                  Example: --mask \"*.md\" or --mask \"tasks/*.md\""
    echo
    echo "Description:"
    echo "  This script performs the following operations:"
    echo "  1. Adds UUIDs to markdown tasks if missing"
    echo "  2. Exports markdown tasks to TaskWarrior format"
    echo "  3. Imports the tasks into TaskWarrior"
    echo
    echo "Note: Make sure TaskWarrior (task) is installed and properly configured."
}


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

if [ -n "$file_pattern" ]; then
    ~/perso/obsidian-taskwarrior-sync/mtt_md_add_uuids.sh --mask "$file_pattern"
    ~/perso/obsidian-taskwarrior-sync/mtt_md_export.sh --mask "$file_pattern"
else
    ~/perso/obsidian-taskwarrior-sync/mtt_md_add_uuids.sh
    ~/perso/obsidian-taskwarrior-sync/mtt_md_export.sh
fi

task import tasks.ndjson
