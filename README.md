# KDE Service Menus

![CI](https://github.com/guinuxbr/kde-service-menus/actions/workflows/ci.yml/badge.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/guinuxbr/kde-service-menus)
![GitHub contributors](https://img.shields.io/github/contributors/guinuxbr/kde-service-menus)
![GitHub Repo stars](https://img.shields.io/github/stars/guinuxbr/kde-service-menus)
![GitHub forks](https://img.shields.io/github/forks/guinuxbr/kde-service-menus)

In KDE-speak, a "Service Menu" is a special entry that appears in a context menu (or other context-based interfaces) for
a file (or directory), depending on the types of files selected.

Check [Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus/) for more information
about service menus.

## Prerequisites

- [Dolphin](https://apps.kde.org/en-gb/dolphin/) file manager
- KDE Plasma 6 or Plasma 5

## Installation

The Service Menus can be managed using the `install.sh` script.

```bash
./install.sh --help
Usage: ./install.sh [OPTIONS] [<service_menu_name>...]

Installs or uninstalls KDE Service Menus for Dolphin / KIO.

Options:
  -a, --all            Process all available Service Menus.
  -u, --uninstall      Uninstall the specified Service Menu(s).
  -l, --list           List available Service Menus and their installation status.
  -n, --dry-run        Show actions that would be performed without modifying files.
  -t, --target-dir DIR Override destination service menu directory.
  -h, --help           Show this help message and exit.
```

### Install all menus

```bash
./install.sh --all
```

### Install a specific menu

```bash
./install.sh create_folder_for_file
```

### Check installed status

```bash
./install.sh --list
```

### Uninstall menus

```bash
./install.sh --uninstall --all
```

## Using KDE Service Menus

To use the Service Menus:

1. Open **Dolphin**.
2. Right-click any file (or select multiple files with `Ctrl+Click` or `Shift+Click`).
3. Select the desired action (e.g., **Create Folder for File**) from the context menu.

## Running Tests

Automated tests and ShellCheck linting can be executed locally:

```bash
# Run test suite
./tests/test_service_menus.sh

# Run ShellCheck
shellcheck install.sh create_folder_for_file/create_folder_for_file.sh tests/test_service_menus.sh
```

## Contributing to KDE Service Menus

To contribute to KDE Service Menus, follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`
3. Make your changes and run `./tests/test_service_menus.sh` to ensure all tests pass.
4. Commit your changes: `git commit -m '<commit_message>'`
5. Push to your fork: `git push origin <branch_name>`
6. Create a Pull Request.

Alternatively, see the GitHub documentation on
[creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Maintainer

I'm the only one here! Help me! 🙂

- [@guinuxbr](https://github.com/guinuxbr)

## Contributors

Check the [Contributors](https://github.com/guinuxbr/kde-service-menus/graphs/contributors) panel.

## Contact

If you want to contact me, you can email <guinuxbr@gmail.com>.

## Licence

This project uses the following licence: [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).
