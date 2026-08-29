#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d -t kde-service-menu-test-XXXXXX)"

trap 'rm -rf -- "$TEMP_DIR"' EXIT

passed=0
failed=0

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Assertion failed}"
    if [[ "$expected" == "$actual" ]]; then
        printf '  \033[32mPASS\033[0m: %s\n' "$msg"
        ((passed++)) || true
    else
        printf '  \033[31mFAIL\033[0m: %s (Expected: "%s", got: "%s")\n' "$msg" "$expected" "$actual" >&2
        ((failed++)) || true
    fi
}

assert_file_exists() {
    local file="$1"
    local msg="${2:-File should exist: $file}"
    if [[ -f "$file" ]]; then
        printf '  \033[32mPASS\033[0m: %s\n' "$msg"
        ((passed++)) || true
    else
        printf '  \033[31mFAIL\033[0m: %s\n' "$msg" >&2
        ((failed++)) || true
    fi
}

assert_dir_exists() {
    local dir="$1"
    local msg="${2:-Directory should exist: $dir}"
    if [[ -d "$dir" ]]; then
        printf '  \033[32mPASS\033[0m: %s\n' "$msg"
        ((passed++)) || true
    else
        printf '  \033[31mFAIL\033[0m: %s\n' "$msg" >&2
        ((failed++)) || true
    fi
}

printf '\n=== 1. Testing create_folder_for_file.sh ===\n'

WORKDIR="${TEMP_DIR}/workdir"
mkdir -p "$WORKDIR"

# Test standard file
touch "$WORKDIR/document.txt"
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/document.txt"
assert_dir_exists "$WORKDIR/document" "Directory created for document.txt"
assert_file_exists "$WORKDIR/document/document.txt" "File moved to document/document.txt"

# Test file without extension
touch "$WORKDIR/mybinary"
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/mybinary"
assert_dir_exists "$WORKDIR/mybinary.d" "Directory created for mybinary -> mybinary.d"
assert_file_exists "$WORKDIR/mybinary.d/mybinary" "File moved to mybinary.d/mybinary"

# Test tarball compound extensions (.tar.gz, .tar.xz)
touch "$WORKDIR/source_code.tar.gz"
touch "$WORKDIR/archive.v1.0.tar.xz"
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/source_code.tar.gz" "$WORKDIR/archive.v1.0.tar.xz"
assert_dir_exists "$WORKDIR/source_code" "Directory created for source_code.tar.gz -> source_code"
assert_file_exists "$WORKDIR/source_code/source_code.tar.gz" "File moved to source_code/source_code.tar.gz"
assert_dir_exists "$WORKDIR/archive.v1.0" "Directory created for archive.v1.0.tar.xz -> archive.v1.0"
assert_file_exists "$WORKDIR/archive.v1.0/archive.v1.0.tar.xz" "File moved to archive.v1.0/archive.v1.0.tar.xz"

# Test dotfiles
touch "$WORKDIR/.gitignore"
touch "$WORKDIR/.env.local"
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/.gitignore" "$WORKDIR/.env.local"
assert_dir_exists "$WORKDIR/.gitignore.d" "Directory created for .gitignore -> .gitignore.d"
assert_file_exists "$WORKDIR/.gitignore.d/.gitignore" "File moved to .gitignore.d/.gitignore"
assert_dir_exists "$WORKDIR/.env" "Directory created for .env.local -> .env"
assert_file_exists "$WORKDIR/.env/.env.local" "File moved to .env/.env.local"

# Test files with spaces and special chars
touch "$WORKDIR/photo with spaces (1).jpg"
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/photo with spaces (1).jpg"
assert_dir_exists "$WORKDIR/photo with spaces (1)" "Directory created for spaced filename"
assert_file_exists "$WORKDIR/photo with spaces (1)/photo with spaces (1).jpg" "Spaced file moved properly"

# Test collision safety (file already exists in destination)
mkdir -p "$WORKDIR/collision_test"
echo "existing" > "$WORKDIR/collision_test/collision_test.txt"
echo "new" > "$WORKDIR/collision_test.txt"
set +e
"$SCRIPT_DIR/create_folder_for_file/create_folder_for_file.sh" "$WORKDIR/collision_test.txt" >/dev/null 2>&1
collision_status=$?
set -e
assert_eq "1" "$collision_status" "Script rejects overwriting existing destination file"
assert_file_exists "$WORKDIR/collision_test.txt" "Source file remains intact when collision occurs"

printf '\n=== 2. Testing install.sh ===\n'

INSTALL_TARGET="${TEMP_DIR}/servicemenus_target"

# Test dry-run does not create directory
"$SCRIPT_DIR/install.sh" --target-dir "$INSTALL_TARGET" --dry-run --all >/dev/null
if [[ ! -d "$INSTALL_TARGET" ]]; then
    printf '  \033[32mPASS\033[0m: --dry-run did not create target directory\n'
    ((passed++)) || true
else
    printf '  \033[31mFAIL\033[0m: --dry-run created target directory\n' >&2
    ((failed++)) || true
fi

# Test full installation into custom directory
"$SCRIPT_DIR/install.sh" --target-dir "$INSTALL_TARGET" --all >/dev/null
assert_dir_exists "$INSTALL_TARGET/create_folder_for_file" "Installed menu subdirectory exists"
assert_file_exists "$INSTALL_TARGET/create_folder_for_file.desktop" "Desktop file symlink created"

# Check executable bits
if [[ -x "$INSTALL_TARGET/create_folder_for_file/create_folder_for_file.sh" ]]; then
    printf '  \033[32mPASS\033[0m: Installed helper script has executable permissions\n'
    ((passed++)) || true
else
    printf '  \033[31mFAIL\033[0m: Installed helper script is not executable\n' >&2
    ((failed++)) || true
fi

# Test uninstallation
"$SCRIPT_DIR/install.sh" --target-dir "$INSTALL_TARGET" --uninstall --all >/dev/null
if [[ ! -e "$INSTALL_TARGET/create_folder_for_file.desktop" && ! -d "$INSTALL_TARGET/create_folder_for_file" ]]; then
    printf '  \033[32mPASS\033[0m: --uninstall cleanly removed installed menu files\n'
    ((passed++)) || true
else
    printf '  \033[31mFAIL\033[0m: --uninstall left files in target directory\n' >&2
    ((failed++)) || true
fi

printf '\n=====================================\n'
printf 'Test Summary: %d Passed, %d Failed\n' "$passed" "$failed"
printf '=====================================\n'

if [[ "$failed" -gt 0 ]]; then
    exit 1
fi
