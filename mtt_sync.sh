#!/bin/bash
# vim: set tabstop=4 shiftwidth=4 expandtab list:

echo
echo "mtt - ============ starting sync ================="
echo

show_help() {
    echo "Usage: mtt_sync.sh [OPTIONS]"
    echo
    echo "Synchronizes tasks between Markdown files and TaskWarrior."
    echo
    echo "Options:"
    echo "  --help            Show this help message"
    echo "  --mask PATTERN    Specify a file pattern to filter markdown files"
    echo "                      Example: --mask \"*.md\" or --mask \"tasks/*.md\""
    echo "  --project NAME   Assign tasks to a specific project"
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
        --project)
            shift
            if [[ -n "$1" ]]; then
                project_name="$1"
            else
                echo "Error: --project requires a name"
                show_help
                exit 1
            fi
            ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done


# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check required external programs are installed first
"$SCRIPT_DIR/mtt_check_requirements.sh"
if [ $? -ne 0 ]; then
    exit 1
fi

# Build command arguments for mtt_md_add_uuids.sh (only needs mask)
uuid_args=()
[ -n "$file_pattern" ] && uuid_args+=(--mask "\"$file_pattern\"")

# Build command arguments for mtt_md_to_taskwarrior.sh (needs both mask and project)
export_args=()
[ -n "$file_pattern" ] && export_args+=(--mask "$file_pattern")
[ -n "$project_name" ] && export_args+=(--project "$project_name")

# Execute scripts with their respective arguments
"$SCRIPT_DIR/mtt_md_add_uuids.sh" "${uuid_args[@]:-}"
"$SCRIPT_DIR/mtt_md_to_taskwarrior.sh" "${export_args[@]:-}"

echo
task import tasks.ndjson
