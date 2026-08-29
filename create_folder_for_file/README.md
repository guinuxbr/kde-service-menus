# KDE Service Menus: Create Folder for File

In KDE-speak, a "Service Menu" is a special entry that appears in a context menu (or other context-based interfaces) for
a file (or directory), depending on the types of files that are selected.

Check [Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus/) for more information
about service menus.

## Create folder for file

This Service Menu creates a folder for each selected file and moves the file into it. It supports selecting single or
multiple files at once.

### Examples

- **Standard files**: For `file_01.txt`, the folder `file_01` is created, and `file_01.txt` is moved into `file_01/`.
- **Files without extension**: For `file`, the folder `file.d` is created, and `file` is moved into `file.d/`.
- **Compound archives**: For `file_01.tar.xz` (or `.tar.gz`, `.tar.bz2`, `.tar.zst`), the folder `file_01` is created,
  and `file_01.tar.xz` is moved into `file_01/`.
- **Dotfiles / Hidden files**: For `.gitignore`, the folder `.gitignore.d` is created, and `.gitignore` is moved into
  `.gitignore.d/`. For `.env.local`, the folder `.env` is created.
- **Multiple files with same base**: If `file_01.txt` and `file_01.tar.xz` are both processed, they will both be moved
  into the same destination folder `file_01/`.
