#!/bin/bash

# Check if sed is installed
if ! command -v sed &> /dev/null; then
    echo "Error: sed is not installed. Please install sed to continue."
    exit 1
fi

# Check if awk is installed
if ! command -v awk &> /dev/null; then
    echo "Error: awk is not installed. Please install awk to continue."
    exit 1
fi

# Check if ripgrep is installed
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep is not installed. Please install ripgrep to continue."
    echo "On macOS you can install it with: brew install ripgrep"
    echo "On Ubuntu/Debian you can install it with: sudo apt install ripgrep"
    exit 1
fi

# Check if Taskwarrior is installed
if ! command -v task &> /dev/null; then
    echo "Error: Taskwarrior is not installed. Please install Taskwarrior to continue."
    echo "On macOS you can install it with: brew install task"
    echo "On Ubuntu/Debian you can install it with: sudo apt install taskwarrior"
    exit 1
fi

echo "✅ All required tools are installed."
exit 0

