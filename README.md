# publi.sh
Publi.sh is a wrapper for the pandoc universal document converter, written in bash, and intended for replicating directories of Markdown documents into HTML to be published on the web.

## Usage
`./publi.sh [options] <input directory> <output directory>`

## Options

| Flag                | Description                                     |
| ------------------- | ----------------------------------------------- |
| `-D`, `-V`          | display bash *verbose* and *xtrace* output      |
| `-d`, `-v`          | display publi.sh debugging output               |
| `-h`                | display help                                    |
| `-i <glob pattern>` | rename files matching pattern to *index.html*   |
| `-o`                | confirm overwrite of non-empty output directory |
| `-p <args>`         | pass additional arguments to pandoc             |
