#!/usr/bin/env bash
# fname-strip-beginning.sh
# Usage: fname-strip-beginning.sh <prefix> [directory]
#
# Strips a prefix from all filenames in a directory (default: current dir).
# Only renames files that actually start with the given prefix.
# Skips directories (files only).

set -euo pipefail

# --- Args ---
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $(basename "$0") <prefix> [directory]"
    echo "  prefix     The text to strip from the beginning of each filename"
    echo "  directory  Optional. Defaults to current directory (.)"
    exit 0
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename "$0") <prefix> [directory]"
    echo "  prefix     The text to strip from the beginning of each filename"
    echo "  directory  Optional. Defaults to current directory (.)"
    exit 1
fi

PREFIX="$1"
DIR="${2:-.}"

if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

PREFIX_LEN=${#PREFIX}
renamed=0
skipped=0

echo "Scanning: $DIR"
echo "Prefix to strip: \"$PREFIX\""
echo "---"

for filepath in "$DIR"/*; do
    # Skip if not a regular file
    [[ -f "$filepath" ]] || continue

    filename="$(basename "$filepath")"

    # Check if filename starts with the prefix
    if [[ "$filename" == "$PREFIX"* ]]; then
        new_name="${filename:$PREFIX_LEN}"

        if [[ -z "$new_name" ]]; then
            echo "  SKIP (would be empty): $filename"
            skipped=$((skipped + 1))
            continue
        fi

        new_path="$DIR/$new_name"

        if [[ -e "$new_path" ]]; then
            echo "  SKIP (target exists): $filename -> $new_name"
            skipped=$((skipped + 1))
            continue
        fi

        mv "$filepath" "$new_path"
        echo "  Renamed: $filename -> $new_name"
        renamed=$((renamed + 1))
    else
        echo "  No match:  $filename"
    fi
done

echo "---"
echo "Done. Renamed: $renamed  |  Skipped: $skipped"
