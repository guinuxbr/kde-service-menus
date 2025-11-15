# KDE Service Menus

![GitHub repo size](https://img.shields.io/github/repo-size/guinuxbr/kde-service-menus)
![GitHub contributors](https://img.shields.io/github/contributors/guinuxbr/kde-service-menus)
![GitHub Repo stars](https://img.shields.io/github/stars/guinuxbr/kde-service-menus)
![GitHub forks](https://img.shields.io/github/forks/guinuxbr/kde-service-menus)
![Twitter Follow](https://img.shields.io/twitter/follow/guinuxbr?style=social)

In KDE-speak, a "Service Menu" is a special entry that appears in a context menu (or other context-based interfaces) for a file (or directory), depending on the types of files selected.

Check [Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus/) for more information about the service menus.

## Prerequisites

The [Dolphin](https://apps.kde.org/en-gb/dolphin/) file manager must be installed.

## Installation

The Service Menus can be installed using the `install.sh` script.

```bash
./install.sh --help                
Usage: ./install.sh [--all | <service_menu_name>...]
Installs specified KDE Service Menus.
  --all: Installs all available Service Menus.
  <service_menu_name>: The name of the Service Menu directory to install.
```

The script will install the desktop file and helper scripts when needed.

## Using KDE Service Menus

To use the Service Menus, open Dolphin and right-click a file.

You can also select multiple files by CTRL+Click, then right-click to see the available actions.

## Contributing to KDE Service Menus

To contribute to KDE Service Menus, follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin kde-service-menus/<location>`
5. Create the pull request

Alternatively, see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Maintainer

I'm the only one here! Help me! 🙂

- [@guinuxbr](https://github.com/guinuxbr)

## Contributors

Check the "[Contributors](https://github.com/guinuxbr/kde-service-menus/graphs/contributors)" panel.

## Contact

If you want to contact me, you can email <guinuxbr@gmail.com>.

## License

This project uses the following license: [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).
