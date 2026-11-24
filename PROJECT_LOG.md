# Project log — सामवेदीय नित्यकर्म पद्धतिः (digitisation)

## Photo → book map (decided 2026-11-23)
Photos `Image_files/*.jpg` were ingested in capture order to upright `Images/pages/pNNN.jpg` (p001–p072).
Transcripts are `transcripts/NNN.md` in **book order** (not photo order).

| transcript | photo(s) | content |
|---|---|---|
| 001 | p072 (alt p001) | front cover |
| 002–004 | p002–p004 | title page, imprint, उपोद्घात |
| 005–007 | p005–p007 | आवश्यक वक्तव्य (pp. [१]–३) |
| 008–009 | p008–p009 | portraits (cropped to `Images/figures/`) |
| 010–014 | p010–p014 | परिचय (pp. [१]–५) |
| 015 | p015 | ऋषिकुल का परिचय + patrons |
| 016–017 | p016–p017 | पं० वच्चन मिश्रजी का परिचय (pp. [१]–२) |
| 018 | p018 | contents (प्रयोग-सूची) |
| 019–056 | p019–p058 minus dupes p030/p031 | the rite, printed pp. १–३८ |
| 057 | p059 | contributors list |
| 058–067 | p060–p069 | गोत्रावली tables, pp. [१]–१० (p060, p061, p066 are landscape) |
| 068 | p070 | निवेदन |
| 069 | p071 | back cover |

p030 and p031 are second photographs of printed pp. १० and ११ (p028/p029).

## Progress
- 2026-11-23: set-up; transcripts 001–018 done (front matter, biographies, contents). Site builder written.
- 2026-11-23/24: all 69 transcripts done (001–069): front matter, both family histories, the rite pp. १–३८, contributors, gotra tables pp. १–१०, निवेदन and back cover. Site built: `docs/` (69 pages + index + full.html), checked in headless Chrome at desktop and ~500 px widths.
- Photos p060, p061, p066 were landscape after ingest; rotated upright in place (Rotate270) on 2026-11-24.
- Figures cropped from photos into `Images/figures/`: p008/p009 portraits, p051 vedī diagram, p052 bali-sthāna diagram.

## Uncertain readings (marked `[unclear: …]`, highlighted on the site)
| transcript | photo | spot | reading |
|---|---|---|---|
| 021 | p021 | prātaḥsmaraṇa v.15 | कुक्कुट |
| 024 | p024 | ācamana, badly inked line | बीच की अ(ङ्गुलियों) |
| 032 | p034 | after bhūmi-japa | न्यञ्च |
| 034 | p036 | Vāmadevya gāna | इमा, ष्ठयौहो |
| 043 | p045 | first word, gutter | ब्रह्मणे |
| 044 | p046 | ācārya list | यमवाहु |
| 047 | p049 | gāna, gutter/edge | इ(हौहो), व(रम्), स्या(कारा) |
| 051 | p053 | bali mantra 5 abbreviation | अप० |
| 053 | p055 | prāṇāhuti 2 | व्या(नाय) |
| 060 | p062 | शाण्डिल्य place name | गुण्लीवो |

Other known issues, noted on their pages: p.२५ tarpaṇa numbering shows ‘१५’ and ‘५१’ twice; p.२६ has a stray line of type between rules; gotra p.१० has 12 rows against 13 on p.९.

## Rebuild
1. `scripts/tools/make_web_images.ps1` (makes `Images/web/`, resized copies)
2. `Rscript scripts/build_site.R` (R at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`)
- 2026-11-24: git repo created and pushed to https://github.com/abhinavananddwivedi/samvediya_nityakarma_paddhati (public, branch `main`). GitHub Pages serves `main:/docs` (legacy build, same as the mahākāvya); live at https://abhinavananddwivedi.github.io/samvediya_nityakarma_paddhati/ and verified. `Image_files/` (originals) and `Images/web/` are gitignored.
