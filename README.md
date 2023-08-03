# Macos bash cli helper functions

Simple helpers functions, mainly used for as helpers for easy access to files for writing and reading.

## Setup

1. Place the folder in your root `/Users/home` with the name `.custom`.

ie:

```sh
~/.custom
```

2. Add following line of code to `~/.zprofile` to import the index file:

```sh
source .custom/index.sh
```

3. **[Optional]**: Update the path `pth_documents` in the `index.sh` file.

This folder has the following structure. This for certain functions like `_books` or `_new`:

```sh
$pth_documents
    ├── books
    └── writings
        ├── books
        ├── ideas
        ├── notes
        └── stories
```

4. all in one

```sh
# enter path here
$src='~/.custom'

git pull link
mv custom $src

echo "source $src/index.sh" >> ~/.zprofile

open $src/index.sh


# echo "Create folderstructure? This can always be done later."
# read "fpth? Enter the path for the folders. Default: ~/Documents/custom" '~/Documents/custom'

# if [[ "$answer" =~ ("y"|"yes") ]]; then
#     mkdir -p

fi;

```

## Help

use: `_help` or `_custom help`.

## about

Some commands mayb not work

Custom functions are all prefixed with a **":"**.

Eg: **:cd**
