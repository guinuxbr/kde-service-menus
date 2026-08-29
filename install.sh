#!/usr/bin/env bash
set -euo pipefail

# Determine default Service Menu directory (Plasma 6 default with Plasma 5 fallback)
detect_service_menu_dir() {
    if [[ -n "${KDE_SERVICE_MENU_DIR:-}" ]]; then
        echo "${KDE_SERVICE_MENU_DIR}"
    elif [[ -d "${HOME}/.local/share/kservices5/ServiceMenus" && ! -d "${HOME}/.local/share/kio/servicemenus" ]]; then
        echo "${HOME}/.local/share/kservices5/ServiceMenus"
    else
        echo "${HOME}/.local/share/kio/servicemenus"
    fi
}

USER_SERVICE_MENU_DIR="$(detect_service_menu_dir)"

# Print usage information
print_usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [<service_menu_name>...]

Installs or uninstalls KDE Service Menus for Dolphin / KIO.

Options:
  -a, --all            Process all available Service Menus.
  -u, --uninstall      Uninstall the specified Service Menu(s).
  -l, --list           List available Service Menus and their installation status.
  -n, --dry-run        Show actions that would be performed without modifying files.
  -t, --target-dir DIR Override destination service menu directory
                       (Current: ${USER_SERVICE_MENU_DIR}).
  -h, --help           Show this help message and exit.

Examples:
  $0 --all                     Install all available menus
  $0 create_folder_for_file    Install only the 'create_folder_for_file' menu
  $0 --list                    List all available menus and installation status
  $0 --uninstall --all         Uninstall all menus
EOF
}

# Find all available service menus in current repository
get_available_menus() {
    local script_dir
    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    local menus=()

    for d in "${script_dir}"/*/; do
        [[ -d "$d" ]] || continue
        local name
        name="$(basename -- "$d")"
        if [[ -f "${d}/${name}.desktop" ]]; then
            menus+=("$name")
        fi
    done

    echo "${menus[@]}"
}

# List available menus and their status
list_menus() {
    local -a available_menus
    read -r -a available_menus <<< "$(get_available_menus)"

    if [[ ${#available_menus[@]} -eq 0 ]]; then
        printf 'No service menus found in repository.\n'
        return 0
    fi

    printf 'Available KDE Service Menus:\n\n'
    printf '%-30s %-15s %s\n' "Menu Name" "Status" "Destination Directory"
    printf '%-30s %-15s %s\n' "---------" "------" "---------------------"

    for menu in "${available_menus[@]}"; do
        local desktop_link="${USER_SERVICE_MENU_DIR}/${menu}.desktop"
        local menu_dir="${USER_SERVICE_MENU_DIR}/${menu}"
        local status="Not Installed"

        if [[ -e "${desktop_link}" || -d "${menu_dir}" ]]; then
            status="Installed"
        fi

        printf '%-30s %-15s %s\n' "${menu}" "${status}" "${USER_SERVICE_MENU_DIR}"
    done
}

# Install a single service menu
install_service_menu() {
    local menu_name="$1"
    local dry_run="${2:-false}"
    local script_dir
    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    local src_dir="${script_dir}/${menu_name}"
    local desktop_file="${src_dir}/${menu_name}.desktop"

    if [[ ! -d "${src_dir}" ]]; then
        printf 'Error: directory for Service Menu "%s" not found.\n' "${menu_name}" >&2
        return 1
    fi
    if [[ ! -f "${desktop_file}" ]]; then
        printf 'Error: service menu desktop file "%s" does not exist.\n' "${desktop_file}" >&2
        return 1
    fi

    local dest_subdir="${USER_SERVICE_MENU_DIR}/${menu_name}"
    local dest_desktop_file="${USER_SERVICE_MENU_DIR}/${menu_name}.desktop"

    if [[ "${dry_run}" == true ]]; then
        printf '[Dry-run] Would create directory: %s\n' "${USER_SERVICE_MENU_DIR}"
        printf '[Dry-run] Would copy: %s -> %s\n' "${src_dir}" "${dest_subdir}"
        printf '[Dry-run] Would create symlink: %s -> %s\n' "${dest_desktop_file}" "${dest_subdir}/${menu_name}.desktop"
        printf '[Dry-run] Would set executable permissions on scripts in %s\n' "${dest_subdir}"
        return 0
    fi

    # Ensure target service menu folder exists
    mkdir -p -- "${USER_SERVICE_MENU_DIR}"

    # Clean old installation if exists
    rm -rf -- "${dest_subdir}"
    rm -f -- "${dest_desktop_file}"

    # Copy files and symlink desktop file
    cp -a -- "${src_dir}" "${dest_subdir}"
    ln -s -- "${dest_subdir}/${menu_name}.desktop" "${dest_desktop_file}"

    # Ensure scripts and desktop files have executable permissions
    chmod u+x -- "${dest_subdir}/${menu_name}.desktop"
    if compgen -G "${dest_subdir}/*.sh" >/dev/null; then
        chmod u+x -- "${dest_subdir}"/*.sh
    fi

    printf 'Installed service menu "%s" -> %s\n' "${menu_name}" "${USER_SERVICE_MENU_DIR}"
}

# Uninstall a single service menu
uninstall_service_menu() {
    local menu_name="$1"
    local dry_run="${2:-false}"
    local dest_subdir="${USER_SERVICE_MENU_DIR}/${menu_name}"
    local dest_desktop_file="${USER_SERVICE_MENU_DIR}/${menu_name}.desktop"

    if [[ ! -e "${dest_desktop_file}" && ! -d "${dest_subdir}" ]]; then
        printf 'Service Menu "%s" is not installed in %s\n' "${menu_name}" "${USER_SERVICE_MENU_DIR}"
        return 0
    fi

    if [[ "${dry_run}" == true ]]; then
        printf '[Dry-run] Would remove: %s\n' "${dest_desktop_file}"
        printf '[Dry-run] Would remove directory: %s\n' "${dest_subdir}"
        return 0
    fi

    rm -f -- "${dest_desktop_file}"
    rm -rf -- "${dest_subdir}"

    printf 'Uninstalled service menu "%s" from %s\n' "${menu_name}" "${USER_SERVICE_MENU_DIR}"
}

# Main option parsing
action="install"
process_all=false
dry_run=false
list_only=false
names=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        -l|--list)
            list_only=true
            shift
            ;;
        -u|--uninstall)
            action="uninstall"
            shift
            ;;
        -a|--all)
            process_all=true
            shift
            ;;
        -n|--dry-run)
            dry_run=true
            shift
            ;;
        -t|--target-dir)
            if [[ -z "${2:-}" ]]; then
                printf 'Error: --target-dir requires a directory argument.\n' >&2
                exit 1
            fi
            USER_SERVICE_MENU_DIR="$2"
            shift 2
            ;;
        -*)
            printf 'Error: Unknown option "%s". Use --help for usage.\n' "$1" >&2
            exit 1
            ;;
        *)
            names+=("$1")
            shift
            ;;
    esac
done

if [[ "${list_only}" == true ]]; then
    list_menus
    exit 0
fi

if [[ "${process_all}" == false && ${#names[@]} -eq 0 ]]; then
    print_usage
    exit 1
fi

targets=()
if [[ "${process_all}" == true ]]; then
    read -r -a targets <<< "$(get_available_menus)"
    if [[ ${#targets[@]} -eq 0 ]]; then
        printf 'No service menus found to process.\n' >&2
        exit 1
    fi
else
    targets=("${names[@]}")
fi

has_errors=false
for target in "${targets[@]}"; do
    if [[ "${action}" == "install" ]]; then
        if ! install_service_menu "${target}" "${dry_run}"; then
            has_errors=true
        fi
    elif [[ "${action}" == "uninstall" ]]; then
        if ! uninstall_service_menu "${target}" "${dry_run}"; then
            has_errors=true
        fi
    fi
done

if [[ "${has_errors}" == true ]]; then
    exit 1
fi
