#!/bin/bash
# Resolve Dendron ![[note]] transclusions into a flat markdown file.
#
# Usage: export_pod_md.sh <input_file>
# Output: notes/assets/export-pod-md/<input_basename>
#
# - Strips YAML frontmatter (--- ... ---) from input and all transcluded notes
# - Replaces ![[note.path]] lines with the content of notes/note.path.md
# - Only processes top-level ![[...]] (not nested transclusions in transcluded notes)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
EXPORT_DIR="${NOTES_DIR}/assets/export-pod-md"

mkdir -p "${EXPORT_DIR}"

input_file="$1"
basename="$(basename "$input_file")"

# Strip YAML frontmatter (--- ... ---) from a file
strip_frontmatter() {
    awk '
    BEGIN { in_fm=0; fm_done=0; first=1 }
    {
        if (first && $0 == "---") { in_fm=1; first=0; next }
        first=0
        if (in_fm && $0 == "---") { in_fm=0; fm_done=1; next }
        if (!in_fm) print
    }
    ' "$1"
}

# Process the input: strip frontmatter, then resolve ![[note]] transclusions
output_file="${EXPORT_DIR}/${basename}"

strip_frontmatter "$input_file" | while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*\!\[\[([^\]]+)\]\][[:space:]]*$ ]]; then
        note_name="${BASH_REMATCH[1]}"
        note_file="${NOTES_DIR}/${note_name}.md"
        if [[ -f "$note_file" ]]; then
            strip_frontmatter "$note_file"
        else
            echo "$line"
            echo "<!-- WARNING: note not found: ${note_name} -->"
        fi
    else
        echo "$line"
    fi
done > "$output_file"

echo "Exported: ${output_file}"
