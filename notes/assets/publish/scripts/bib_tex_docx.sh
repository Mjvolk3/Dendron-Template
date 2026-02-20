#!/bin/bash

# notes/assets/publish/scripts/bib_tex_docx.sh
# Converts exported markdown to docx using pandoc with bibliography and Word template.
#
# Usage: bib_tex_docx.sh <input_file> <output_dir> <output_filename> [docx_subdir]
#   input_file:      path to the markdown file (e.g., ./notes/assets/export-pod-md/Paper.md)
#   output_dir:      unused (kept for CLI compatibility with bib_tex_pdf.sh)
#   output_filename: base name for the output file (e.g., Paper)
#   docx_subdir:     optional subdirectory under notes/assets/ (default: docx-pod-output)

export PATH="$HOME/.npm-global/bin:$PATH"

# Derive notes/ directory from script location (script lives at notes/assets/publish/scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

input_file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
output_dir="$2"
output_filename="$3"
docx_subdir="${4:-docx-pod-output}"
reference_docx="${NOTES_DIR}/assets/publish/ms_word_ref/paper-reference.docx"

# Create output directory
mkdir -p "${NOTES_DIR}/assets/${docx_subdir}"

# Check if reference document exists
if [ ! -f "${reference_docx}" ]; then
  echo "Error: Reference document not found at: ${reference_docx}"
  exit 1
fi

echo "Using paper-reference.docx template for Word formatting."

cd "${NOTES_DIR}" && pandoc -F mermaid-filter \
  --metadata link-citations=true \
  -s "${input_file}" \
  -o "${NOTES_DIR}/assets/${docx_subdir}/${output_filename}.docx" \
  --reference-doc="${reference_docx}" \
  --citeproc \
  --bibliography assets/bib/bib.bib \
  --metadata csl=assets/publish/bib/nature.csl \
  --strip-comments && cd ..

output_file_path="${NOTES_DIR}/assets/${docx_subdir}/${output_filename}.docx"
echo "Output file: ${output_file_path}"
