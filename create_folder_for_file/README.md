# KDE Service Menus

In KDE-speak a "Service Menu" is a special entry that appears in a context menu (or other context-based interfaces) for a file (or for directory), depending on the type of files that are selected.

Check [Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus/) for more information about the service menus.

## Create folder for file

This Service Menu will create a folder for the selected file.

### Examples

- For the file `file_01.txt`, the folder `file_01` will be created, and `file_01.txt` will be moved to `file_01`.
- For the file `file`, the folder `file.d` will be created, and `file` will be moved to `file.d`.
- For the file `file_01.tar.xz`, the folder `file_01` will be created, and `file_01.tar.xz` will be moved to `file_01`.
- If `file_01.txt` and `file_01.tar.xz` exist, they will be moved to the same folder `file_01`.
