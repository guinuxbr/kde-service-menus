#!/usr/bin/env bash
set -euo pipefail

# This script is called by the 'create_folder_for_file.desktop' service menu.
# It accepts one or more file paths, creates a folder named after each file,
# and moves the file into its respective folder.

# Optional desktop notification helper
notify_user() {
    local title="$1"
    local message="$2"
    local icon="${3:-folder-new}"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -i "$icon" "$title" "$message" 2>/dev/null || true
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --passivepopup "$message" 5 --title "$title" --icon "$icon" 2>/dev/null || true
    fi
}

# Function to determine the folder name based on the file name
get_folder_name() {
    local name="$1"
    local base

    # Handle hidden files (dotfiles)
    if [[ "$name" =~ ^\.(.*) ]]; then
        local rest="${BASH_REMATCH[1]}"
        # If no further extension in dotfile (e.g., .gitignore, .bashrc, .env)
        if [[ "$rest" != *.* ]]; then
            echo "${name}.d"
            return
        fi
        # If dotfile has a compound tar extension (e.g., .archive.tar.gz)
        local rest_base="${rest%.*}"
        if [[ "$rest" == *.tar.* && "$rest_base" == *.tar ]]; then
            rest_base="${rest_base%.tar}"
        fi
        echo ".${rest_base}"
        return
    fi

    base="${name%.*}"

    # If there is no extension, append ".d"
    if [[ "$name" == "$base" ]]; then
        echo "${name}.d"
        return
    fi

    # If it is a compound tar extension (e.g., .tar.gz, .tar.xz, .tar.bz2), strip .tar as well
    if [[ "$name" == *.tar.* && "$base" == *.tar ]]; then
        base="${base%.tar}"
    fi

    echo "$base"
}

# Process a single file
process_file() {
    local filepath="$1"

    # Normalize URL scheme if received (e.g. file:///path)
    if [[ "$filepath" =~ ^file:// ]]; then
        filepath="${filepath#file://}"
        # Decode %XX hex encoding if present
        if [[ "$filepath" =~ % ]]; then
            filepath=$(printf '%b' "${filepath//%/\\x}")
        fi
    fi

    if [[ ! -e "$filepath" && ! -L "$filepath" ]]; then
        printf 'Error: File does not exist: "%s"\n' "$filepath" >&2
        return 1
    fi

    if [[ -d "$filepath" && ! -L "$filepath" ]]; then
        printf 'Skipping directory: "%s"\n' "$filepath" >&2
        return 0
    fi

    local filename
    local parent_dir
    local folder_name
    local target_dir
    local target_file

    filename="$(basename -- "$filepath")"
    parent_dir="$(dirname -- "$filepath")"
    folder_name="$(get_folder_name "$filename")"
    target_dir="${parent_dir}/${folder_name}"
    target_file="${target_dir}/${filename}"

    if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
        printf 'Error: Destination "%s" exists and is not a directory.\n' "$target_dir" >&2
        return 1
    fi

    mkdir -p -- "$target_dir"

    if [[ -e "$target_file" ]]; then
        printf 'Error: Target file "%s" already exists in destination.\n' "$target_file" >&2
        return 1
    fi

    mv -- "$filepath" "$target_dir/"
    printf 'Moved "%s" -> "%s/"\n' "$filename" "$folder_name"
}

if [[ $# -eq 0 ]]; then
    printf 'Usage: %s <file_path>...\n' "$0" >&2
    exit 1
fi

moved_count=0
error_count=0

for item in "$@"; do
    if process_file "$item"; then
        ((moved_count++)) || true
    else
        ((error_count++)) || true
    fi
done

if [[ $error_count -gt 0 ]]; then
    notify_user "Create Folder for File" "Encountered $error_count error(s) while processing files." "dialog-warning"
    exit 1
fi
