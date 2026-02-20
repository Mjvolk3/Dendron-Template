#!/bin/bash
# Resolve Dendron ![[note]] transclusions into a flat markdown file.
#
# Usage: export_pod_md.sh <input_file>
# Output: notes/assets/export-pod-md/<input_basename>
#
# - Strips YAML frontmatter (--- ... ---) from input and all transcluded notes
# - Replaces ![[note.path]] lines with the content of notes/note.path.md
# - Recursively resolves nested transclusions (up to 10 levels deep)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
EXPORT_DIR="${NOTES_DIR}/assets/export-pod-md"

mkdir -p "${EXPORT_DIR}"

input_file="$1"
basename="$(basename "$input_file")"

MAX_DEPTH=10

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

# Recursively resolve ![[note]] transclusions
# Usage: resolve_transclusions <file> <depth>
resolve_transclusions() {
    local file="$1"
    local depth="${2:-0}"

    if (( depth > MAX_DEPTH )); then
        echo "<!-- WARNING: max transclusion depth exceeded for ${file} -->"
        return
    fi

    strip_frontmatter "$file" | while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*\!\[\[([^\]]+)\]\][[:space:]]*$ ]]; then
            note_name="${BASH_REMATCH[1]}"
            note_file="${NOTES_DIR}/${note_name}.md"
            if [[ -f "$note_file" ]]; then
                resolve_transclusions "$note_file" $((depth + 1))
            else
                echo "$line"
                echo "<!-- WARNING: note not found: ${note_name} -->"
            fi
        else
            echo "$line"
        fi
    done
}

# Process the input and write to output
output_file="${EXPORT_DIR}/${basename}"
resolve_transclusions "$input_file" 0 > "$output_file"

echo "Exported: ${output_file}"
