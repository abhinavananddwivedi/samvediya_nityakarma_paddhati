# CLAUDE.md

This project digitises a short printed book: **सामवेदीय नित्यकर्म पद्धतिः** (Sāmaveda, Kauthuma śākhā daily rites). Pt. Chandrabhushan Dwivedi compiled it; it was published Saṃvat 2005 (1948 CE) by Sanmarg Press, Kashi. The user's great-grandfather wrote it. The sister project is the grandfather's mahākāvya at `D:\Babaji_files` (GitHub Pages site *sri_markandeya_charitam*).

## Layout
- `Image_files/`: the user's original photos. Never modify them.
- `Images/pages/pNNN.jpg`: upright, EXIF-free copies in capture order (p001–p072). **Photo numbers are not book pages**; see the map in `PROJECT_LOG.md`.
- `Images/figures/`: crops from the photos (portraits, diagrams), at full resolution.
- `Images/web/`: resized copies for the site, made by `scripts/tools/make_web_images.ps1`.
- `transcripts/NNN.md`: one file per printed page, **in book order** (001 cover … 069 back cover). This is the source of truth.
- `book.yml`: site title, about text, home-page gallery, section list.
- `scripts/build_site.R` (tidyverse) plus `scripts/site.css` build `docs/`. `docs/` is generated, so never hand-edit it. `docs/assets/fonts/` holds the self-hosted Noto Sans Devanagari.
- `scripts/tools/`: `crop.ps1`, `bands.ps1` (n bands), `crop_rot.ps1` (deskew), `contact_sheet.ps1`, `ingest_pages.ps1`, `montage.ps1`.

## Transcript format
YAML front matter (`section`, quoted `label`, `printed_page`, `photo`, optional `alt_photos`, `notes`), then a body typed by line prefix:
- `# `/`## `/`### ` headings;
- `> ` verse lines (a leading space after `> ` indents the line);
- `^ ` centred, `>> ` right-aligned, `<< ` left-aligned;
- `| ` table rows (` // ` inside a cell is a line break);
- `---` a printed rule; `!ornament`; `!fig path | caption`; anything else is prose.

Inline marks: `**bold**`, `*italic*`, `[unclear: guess]`.

## Conventions
- Transcribe diplomatically: keep the print's spelling, misprints, numerals and punctuation, and point out misprints in `notes`. Never "correct" mantras from memory of the standard text.
- Mark every doubtful reading `[unclear: …]` and list it in `PROJECT_LOG.md`.
- Photos p030 and p031 are retakes of printed pp. १०–११; they are attached as `alt_photos`.
