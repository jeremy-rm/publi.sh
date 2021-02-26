# publi.sh
Publi.sh is a wrapper for the pandoc universal document converter, written in bash, and intended for replicating directories of Markdown documents into HTML to be published on the web.

## Usage
`./publi.sh [options] <input directory> <output directory>`

## Options

| Flag        | Description                           |
| ----------- | ------------------------------------- |
| `-d`, `-v`  | display verbose debugging output      |
| `-h`        | display help                          |
| `-i <glob>` | rename matching files to index.html   |
| `-o`        | confirm overwrite of output directory |
| `-p <args>` | pass additional arguments to pandoc   |

### `-d`, `-v`
Verbose debugging output will display all options passed to pandoc, external or otherwise, as well as the input and output paths of each file being processed.

### `-i <file>`
If an `index.html` file is required but does not exist, any files [globbing](https://tldp.org/LDP/abs/html/globbingref.html) `pattern` will be renamed `index.html` upon conversion. For example, if every directory contains a markdown file beginning with the characters `000_` which serves as a table of contents, that may serve as a meaningful `index.html` when published online.

Example: `publi.sh -o -i "000_*.md" ~/markdown ~/public_html`

Here, each file matching `000_*.md` will be renamed `index.html` when converted. It should be noted that this can cause overwrites if multiple files match in a single directory.

### `-o`
By default, publi.sh will exit with an error if the chosen output directory is not empty to prevent accidentally overwriting its contents. The user can either remove the contents of the output directory prior to running publi.sh, or use the `-o` flag to acknowledge the overwrite and disable the error.

### `-p <args>`
Sometimes it can be useful to specify additional arguments to pandoc. This can be done using the `-p` flag, which can be used multiple times if needed.

Example: `publi.sh -o -p --title-prefix="My Website" -p --toc-depth=4 ~/markdown ~/public_html`
