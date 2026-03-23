#!/usr/bin/env python3
"""
md_to_qmd.py
Konverterer pandoc-genererte Markdown-filer (fra Word) til Quarto (.qmd).

Transformasjoner:
  - Kapitteloverskrift (nummerert liste + span) → # N. Tittel
  - Delkapitteloverskrift (span + N.N Tittel)  → ## N.N Tittel
  - Kursiv eneståendeover                       → ### Tittel
  - Frittstående seksjonstittel (plain tekst)   → ### Tittel
  - HTML <img ...> → ![](sti)
  - Bildesti ./output/media/ → ./media/
  - HTML-tekstboks (<table> med én <th>) → ::: {.callout-note}
  - Rydder <span class="...">, <u>, <mark> m.m.
  - Legger til YAML-frontmatter
  - Lagrer som .qmd

Bruk:
  python3 md_to_qmd.py output/kapittel_*.md
"""

import sys
import re
import os


# ---------------------------------------------------------------------------
# Hjelpefunksjoner
# ---------------------------------------------------------------------------

def strip_html_tags(text: str) -> str:
    """Fjerner enkle HTML-tagger som <span ...>, </span>, <u>, </u> osv."""
    text = re.sub(r'<span[^>]*>', '', text)
    text = re.sub(r'</span>', '', text)
    text = re.sub(r'</?u>', '', text)
    text = re.sub(r'<mark>', '', text)
    text = re.sub(r'</mark>', '', text)
    return text


def fix_image_paths(text: str) -> str:
    """Korrigerer bildesti fra ./output/media/ til ./media/"""
    return text.replace('./output/media/', './media/')


def convert_html_img(text: str) -> str:
    """Konverterer <img src="..." style="..."> til ![](sti)"""
    def replace_img(m):
        src = m.group(1)
        return f'![]({src})'
    return re.sub(r'<img\s+src="([^"]+)"[^>]*/>', replace_img, text)


def convert_factbox_table(block: str) -> str:
    """
    Konverterer en HTML-tabell med én header-celle (Word tekstboks)
    til en Quarto callout-note.
    """
    # Finn alt innhold i <th>...</th>
    th_match = re.search(r'<th>(.*?)</th>', block, re.DOTALL)
    if not th_match:
        return block

    inner = th_match.group(1).strip()

    # Rydd HTML-tagger fra innholdet
    inner = re.sub(r'</?p>', '\n', inner)
    inner = re.sub(r'<ul>', '', inner)
    inner = re.sub(r'</ul>', '', inner)
    inner = re.sub(r'<li><p>(.*?)</p></li>', r'- \1', inner, flags=re.DOTALL)
    inner = re.sub(r'<li>(.*?)</li>', r'- \1', inner, flags=re.DOTALL)
    inner = re.sub(r'<[^>]+>', '', inner)  # fjern resterende tagger

    # Rydd opp tomme linjer
    lines = [l.rstrip() for l in inner.splitlines()]
    lines = [l for i, l in enumerate(lines)
             if not (l == '' and i > 0 and lines[i-1] == '')]
    inner = '\n'.join(lines).strip()

    return f'\n::: {{.callout-note}}\n{inner}\n:::\n'


def process_file(path: str) -> None:
    with open(path, encoding='utf-8') as f:
        content = f.read()

    # --- Trinn 1: Konverter faktaboks-tabeller (HTML-tabeller fra Word) -----
    # Mønster: <table> med <colgroup> og én <th> som inneholder tekst
    def replace_table(m):
        return convert_factbox_table(m.group(0))

    content = re.sub(
        r'<table>.*?</table>',
        replace_table,
        content,
        flags=re.DOTALL
    )

    # --- Trinn 2: Rydd <aside> (fotnoteliste som HTML) ----------------------
    # Pandoc bruker <aside> for footnotes i gfm-modus av og til
    content = re.sub(r'<aside[^>]*>.*?</aside>', '', content, flags=re.DOTALL)

    # --- Trinn 3: Fjern HTML-kommentarer og class="anchor"-spans -----------
    content = re.sub(r'<span id="[^"]*" class="anchor"></span>\s*', '', content)
    content = re.sub(r'<span id=\'[^\']*\' class=\'anchor\'></span>\s*', '', content)
    content = strip_html_tags(content)

    # --- Trinn 4: Konverter kapitteloverskrift (nummerert liste + tittel) ---
    # Mønster: "N.  Tittel" (etter at span er fjernet)
    # Pandoc lager "1.  Tittel" som ordered list item for H1
    def replace_chapter(m):
        num = m.group(1).rstrip('.')
        title = m.group(2).strip()
        return f'# {num}. {title}'

    content = re.sub(
        r'^(\d+)\.\s{2}(.+)$',
        replace_chapter,
        content,
        flags=re.MULTILINE
    )

    # --- Trinn 5: Konverter delkapitteloverskrifter (N.N Tittel på egen linje)
    # Mønster: linje som starter med tall.tall (f.eks. "4.1 Tittel")
    def replace_subchapter(m):
        num = m.group(1)
        title = m.group(2).strip()
        return f'## {num} {title}'

    content = re.sub(
        r'^(\d+\.\d+)\s+(.+)$',
        replace_subchapter,
        content,
        flags=re.MULTILINE
    )

    # --- Trinn 6: Kursive enelinjer → ### overskrift -----------------------
    # Mønster: *Tekst* alene på en linje (Word-stil for H3/H4)
    def replace_italic_heading(m):
        title = m.group(1).strip()
        return f'### {title}'

    content = re.sub(
        r'^\*([^*\n]+)\*\s*$',
        replace_italic_heading,
        content,
        flags=re.MULTILINE
    )

    # --- Trinn 7: Konverter HTML-bilder → Markdown-bilder -------------------
    content = convert_html_img(content)

    # --- Trinn 8: Rett opp bildestier ---------------------------------------
    content = fix_image_paths(content)

    # --- Trinn 9: Rydd tomme linjer (maks to på rad) -----------------------
    content = re.sub(r'\n{3,}', '\n\n', content)

    # --- Trinn 10: Lag YAML-frontmatter ------------------------------------
    # Hent tittel fra første overskrift
    title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else os.path.basename(path)

    frontmatter = f'---\ntitle: "{title}"\nformat: html\n---\n\n'
    content = frontmatter + content.lstrip()

    # --- Skriv .qmd-fil ----------------------------------------------------
    out_path = os.path.splitext(path)[0] + '.qmd'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(content)

    lines = content.count('\n')
    print(f'  {os.path.basename(out_path)}  ({lines} linjer)')


# ---------------------------------------------------------------------------
# Hovedprogram
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    files = sys.argv[1:]
    if not files:
        print('Bruk: python3 md_to_qmd.py output/kapittel_*.md')
        sys.exit(1)

    print(f'Konverterer {len(files)} filer til .qmd ...')
    for path in sorted(files):
        process_file(path)
    print('Ferdig.')
