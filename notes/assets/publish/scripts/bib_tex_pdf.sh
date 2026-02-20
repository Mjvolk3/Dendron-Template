#!/bin/bash

# notes/assets/publish/scripts/bib_tex_pdf.sh
# [[notes.assets.publish.scripts.bib_tex_pdf]]
# https://github.com/Mjvolk3/Dendron-Template/tree/main/notes/assets/publish/scripts/bib_tex_pdf.sh


export PATH="$HOME/.npm-global/bin:$PATH"

# Derive notes/ directory from script location (script lives at notes/assets/publish/scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

input_file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
output_dir="$2"
output_filename="$3"
pdf_subdir="${4:-pdf-output}"
header_includes_path="${NOTES_DIR}/assets/publish/tex-templates/header-includes.tex"

# Create temp directory for mermaid diagram images (inline mode doesn't work with PDF output)
mermaid_tmp_dir=$(mktemp -d)
export MERMAID_FILTER_LOC="${mermaid_tmp_dir}"
export MERMAID_FILTER_SCALE=4
export MERMAID_FILTER_WIDTH=1200

# Puppeteer config for headless servers (Chrome needs --no-sandbox)
puppeteer_config="${mermaid_tmp_dir}/puppeteer.json"
echo '{"args": ["--no-sandbox"]}' > "${puppeteer_config}"
export MERMAID_FILTER_PUPPETEER_CONFIG="${puppeteer_config}"

echo "Edit notes/assets/publish/tex-templates/header-includes.tex for customizing spacing."

cd "${NOTES_DIR}" && pandoc -F mermaid-filter \
  -L assets/publish/filters/break-long-code.lua \
  --metadata link-citations=true \
  -s "${input_file}" \
  -o "${NOTES_DIR}/assets/${pdf_subdir}/${output_filename}.pdf" \
  --pdf-engine=xelatex \
  --citeproc \
  --bibliography assets/publish/bib/bib.bib \
  --metadata csl=assets/publish/bib/nature.csl \
  -V geometry:'top=2cm, bottom=1.5cm, left=2cm, right=2cm' \
  --include-in-header="${header_includes_path}" \
  --strip-comments --dpi=600 && cd ..

# Cleanup mermaid temp directory and error log
rm -rf "${mermaid_tmp_dir}"
rm -f mermaid-filter.err
cd ..
rm -f mermaid-filter.err

output_file_path="${NOTES_DIR}/assets/${pdf_subdir}/${output_filename}.pdf"
echo "Output file: ${output_file_path}"
