#!/usr/bin/env bash
set -euo pipefail

USER_SERVICE_MENU_DIR="${HOME}/.local/share/kio/servicemenus"

# Ensure the folder where the user Service Menus are stored exists
mkdir -p "${USER_SERVICE_MENU_DIR}"

# Function to print usage information
print_usage() {
    cat <<EOF
Usage: $0 [--all | <service_menu_name>...]
Installs specified KDE Service Menus.
  --all: Installs all available Service Menus.
  <service_menu_name>: The name of the Service Menu directory to install.
EOF
}

# Function to install a single service menu
install_service_menu() {
    local menu_name="$1"
    local src_dir="./${menu_name}"
    local desktop_file="${src_dir}/${menu_name}.desktop"

    if [[ ! -d "${src_dir}" ]]; then
        printf 'Error: directory for Service Menu "%s" not found.\n' "${menu_name}" >&2
        return 1
    fi
    if [[ ! -f "${desktop_file}" ]]; then
        printf 'Error: service menu desktop file "%s" does not exist.\n' "${desktop_file}" >&2
        return 1
    fi

    # Copy the whole menu directory (preserve resources) into a subdir, and
    # also ensure the .desktop is present at USER_SERVICE_MENU_DIR root so KDE finds it.
    local dest_subdir="${USER_SERVICE_MENU_DIR}/${menu_name}"
    local dest_desktop_file="${USER_SERVICE_MENU_DIR}/${menu_name}.desktop"
    rm -rf -- "${dest_subdir}"
    rm -f -- "${dest_desktop_file}"
    cp -a -- "${src_dir}" "${dest_subdir}"
    ln -s -- "${dest_subdir}/${menu_name}.desktop" "${dest_desktop_file}"
    chmod u+x -- "${dest_subdir}/${menu_name}.desktop"

    printf 'Installed service menu "%s" -> %s\n' "${menu_name}" "${USER_SERVICE_MENU_DIR}"
}

# Main script logic
if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
fi

# Check for --all flag
install_all=false
# Array to hold service menu names
names=()

# Loop through arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            print_usage
            exit 0
            ;;
        --all)
            install_all=true
            shift
            ;;
        *)
            names+=("$1")
            shift
            ;;
    esac
done

# Install service menus
if [[ "${install_all}" == true ]]; then
    for d in */; do
        d="${d%/}"
        if [[ -f "./${d}/${d}.desktop" ]]; then
            install_service_menu "${d}" || printf 'Failed to install "%s"\n' "${d}" >&2
        fi
    done
    printf 'All detected service menus processed.\n'
else
    has_errors=false
    for menu in "${names[@]}"; do
        if ! install_service_menu "${menu}"; then
            has_errors=true
        fi
    done
    if [[ "${has_errors}" == true ]]; then
        exit 1
    fi
fi
