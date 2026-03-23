#!/bin/bash
# convert.sh
# Konverterer Word-fil til Markdown og splitter på kapitler.
#
# Bruk:
#   cd word/
#   bash convert.sh "filnavn.docx"
#
# Output:
#   output/full.md          — komplett Markdown-fil
#   output/media/           — alle bilder fra dokumentet
#   output/kapittel_*.md    — ett Markdown-dokument per kapittel

set -e

INPUT="${1:-Utviklingstrekk i folketrygden 2026 - tredjeutkast.docx}"
OUTPUT_DIR="./output"
MEDIA_DIR="$OUTPUT_DIR/media"

# ---------------------------------------------------------------------------
# Steg 1: Konverter Word → Markdown
# ---------------------------------------------------------------------------
echo "Konverterer '$INPUT' til Markdown..."

mkdir -p "$OUTPUT_DIR"

pandoc "$INPUT" \
  -t gfm \
  --extract-media="$MEDIA_DIR" \
  --wrap=none \
  -o "$OUTPUT_DIR/full.md"

echo "Ferdig. Markdown lagret i $OUTPUT_DIR/full.md"
echo "Bilder lagret i $MEDIA_DIR/"

# ---------------------------------------------------------------------------
# Steg 2: Splitt på kapitler
# Mønster: linje som starter med tall + punktum + to mellomrom + <span ...>
# Eksempel: "1.  <span id="_Toc..." class="anchor"></span>Sammendrag"
# ---------------------------------------------------------------------------
echo "Splitter på kapitler..."

python3 - "$OUTPUT_DIR/full.md" "$OUTPUT_DIR" << 'PYEOF'
import sys
import re
import os

input_file = sys.argv[1]
output_dir = sys.argv[2]

with open(input_file, encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines(keepends=True)

# Finn linjer som starter et nytt kapittel (toppnivå: "1.  <span ...")
chapter_pattern = re.compile(r'^\d+\.\s{2}<span')

split_points = [i for i, line in enumerate(lines) if chapter_pattern.match(line)]

if not split_points:
    print("Ingen kapitler funnet. Sjekk mønsteret i full.md.")
    sys.exit(1)

# Legg til en sluttmarkør
split_points.append(len(lines))

for idx, start in enumerate(split_points[:-1]):
    end = split_points[idx + 1]
    chunk = lines[start:end]

    # Hent kapittelnavnet fra første linje
    first_line = chunk[0].strip()
    title_match = re.search(r'</span>(.*)', first_line)
    title = title_match.group(1).strip() if title_match else f"kapittel_{idx + 1}"

    # Lag filnavn: nummer + tittel, ryddet for spesialtegn
    safe_title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_').lower()
    filename = f"kapittel_{idx + 1:02d}_{safe_title}.md"
    filepath = os.path.join(output_dir, filename)

    with open(filepath, 'w', encoding='utf-8') as out:
        out.writelines(chunk)

    print(f"  {filename}  ({len(chunk)} linjer)")

print("Splitting ferdig.")
PYEOF

echo ""
echo "Filer i $OUTPUT_DIR/:"
ls "$OUTPUT_DIR/"
