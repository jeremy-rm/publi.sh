#!/usr/bin/env bash

PUBLISH='
publi.sh [PUHB-lish]
(n) 1.	A tool for publishing markdown on the web with pandoc.
		By jeremy.rm (jeremy.rm@01001010.net) -- Use at your own risk!
'

# -- publish_die <exit status> <args>
# -- Echo formatted exit status and additional args to console then exit with status.
publish_die() {
	echo -e "\n$0 error - exit $1: $2\n" >/dev/stderr
	exit "$1"
}

# -- publish_init <input directory> <output directory>
# -- Sanity and safety checks, debugging/verbosity output.
publish_init() {

	# Option: Debug / Verbosity Mode
	if [[ -n $DEBUG ]]
	then
		# Perform shameless attribution and create debug function.
		echo -e "$PUBLISH"
		publish_debug() {
			if [[ -n $1 ]]
			then
				echo "$0:" "$1"
			else
				echo
			fi
			return 0
		}
		publish_debug "debug output enabled"
	else
		# Create debug function placeholder.
		publish_debug() {
			return 1
		}
	fi

	# Option: Index File Renaming
	if [[ -n $INDEX ]]
	then
		publish_debug "index: $INDEX"
	fi

	# Option: Output Overwrite Acknowledgement
	if [[ -n $OVERWRITE ]]
	then
		publish_debug "overwrite warning acknowledged"
	fi

	# Option: Pandoc Command Line Options
	for pandocopt in "${PANDOC[@]}"
	do
		publish_debug "pandoc: $pandocopt"
	done

	# Sanity: Check for pandoc.
	if ! command -v pandoc &> /dev/null
	then
		publish_die 2 "pandoc was not found in PATH"
	fi

	# Sanity: Check that the correct number of args are given.
	if [[ -z $1 ]] || [[ -z $2 ]] || [[ -n $3 ]]
	then
		publish_die 2 "invalid number of arguments, use $0 -h for help"
	fi

	# Sanity: Check that source directory exists and is readable.
	if ! [[ -r "$1" ]]
	then
		publish_die 2 "source directory does not exist or is not readable: $1"
	fi

	# Safety: Check that destination directory is empty to prevent accidental overwrites.
	if [[ "$(ls -A "$2")" ]] && [[ -z $OVERWRITE ]]
	then
		publish_die 2 "destination directory is not empty, use -o to enable overwrite"
	fi

	return 0

}

# -- publish_help
# -- Echo script usage and options to console.

publish_help() {

	echo
	echo "Usage: ./publi.sh [options] <input directory> <output directory>"
	echo
	echo "	Options:"
	echo "	-D, -V			display bash verbose and xtrace output"
	echo "	-d, -v			display publi.sh debugging output"
	echo "	-h			display help"
	echo "	-i <glob pattern>	rename files matching pattern to index.html"
	echo "	-o			confirm overwrite of non-empty output directory"
	echo "	-p <arguments>		pass optional arguments to pandoc"
	echo "	-t			generate tree output (requires tree)"
	echo

	return 0

}

# -- publish_main <input directory> <output directory>
# -- Iterate over the input directory, converting and copying files to the output directory while preserving subdirectory structure.
publish_main() {

	# Iterate over the contents of $1, recursively.
	for input in "$1"/**/*
	do

		# Process only regular files.
		if [[ -f "$input" ]]
		then

			# Set $output by replacing input path with output path, preserving subdirectories.
			output="$2${input#$1}"

			# Create any necessary subdirectories, die on error.
			mkdir -p "$(dirname "${output}")" || publish_die 1 "${MSG[1]}"

			# File $input is Markdown.
			if [[ "$input" == *.md ]]
			then
				# Check if $input matches the optional index file glob.
				if [[ "$(basename "$input")" == "$INDEX" ]]
				then
					# Change $output filename and extension to index.html.
					output="$(dirname "$output")/index.html"
					publish_debug "index pattern match ($INDEX): $input -> $output"
				else
					# Change $output file extension to html.
					output="${output%.md}.html"
				fi

				# Pandoc metadata, overwritten each iteration.
				unset PANDOCMETA
				PANDOCMETA+=(--metadata="page-title:$(basename -s .md "$input")")

				# Convert file to $output with pandoc, die on error.
				publish_debug "pandoc ${PANDOC[@]} ${PANDOCMETA[@]} $input -o $output"
				pandoc "${PANDOC[@]}" "${PANDOCMETA[@]}" "$input" -o "$output" || publish_die 1 "${MSG[1]}"

			# File $input is not Markdown.
			else
				# Copy $input to $output, die on error.
				cp "$input" "$output" || publish_die 1 "${MSG[1]}"
			fi

			publish_debug "$input -> $output"

		fi

	done

	return 0

}

publish_tree()
	if [[ -n $TREE ]]
	then
		if [[ -v tree ]]
		then
			tree -H "$2" > "$TREE"
		else
			publish_debug "tree binary not found"
		fi
	fi
}

# -- Required Shell Options
set -e
set -o pipefail
shopt -s globstar

# -- Common Message Array
declare -A MSG=(
	[1]="check above this line for more information"
)

# -- Command Line Options
while getopts ":Ddhi:op:Vvt:" OPT; do
	case "${OPT}" in
		D | V)
			set -vx
			;;
		d | v)
			DEBUG=1
			;;
		h)
			echo -e "$PUBLISH"
			publish_help
			exit 0
			;;
		i)
			INDEX="${OPTARG}"
			;;
		o)
			OVERWRITE=1
			;;
		p)
			PANDOC+=("${OPTARG}")
			;;
		t)
			TREE="${OPTARG}"
			;;
		\?)
			echo
			echo "Invalid Option: ${OPTARG}"
			echo
			publish_help
			exit 2
			;;
	esac
done
shift $((OPTIND-1))

# -- Engage!
publish_init "$1" "$2"
publish_main "$1" "$2"
publish_tree "$1" "$2"

echo
exit 0
