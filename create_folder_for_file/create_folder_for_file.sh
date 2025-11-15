#!/usr/bin/env bash
set -euo pipefail

# This script is called by the 'create_folder_for_file.desktop' service menu.
# It takes a single argument: the full path to a file.
# It creates a directory based on the file's name and moves the file into it.

# Get the full file path from the first argument
FILEPATH="$1"
# Extract the file name
FILENAME=$(basename -- "$FILEPATH")
# Extract the directory path
DIR=$(dirname -- "$FILEPATH")

# Function to determine the folder name based on the file name
get_folder_name() {
    local name="$1"
    local base="${name%.*}"

    # If there's no extension, append ".d"
    if [[ "$name" == "$base" ]]; then
        echo "${name}.d"
        return
    fi

    # If it's a compound tar extension (e.g., .tar.gz), strip the .tar as well
    if [[ "$name" == *.tar.* && "$base" == *.tar ]]; then
        base="${base%.tar}"
    fi

    echo "$base"
}

# Get the folder name based on the file name
FOLDER_NAME=$(get_folder_name "$FILENAME")
# Create the folder
mkdir -p -- "$DIR/$FOLDER_NAME"
# Move the file into the new folder
mv -v -- "$FILEPATH" "$DIR/$FOLDER_NAME/"
