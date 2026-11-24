# सामवेदीय नित्यकर्म पद्धतिः

A digital edition of *Sāmavedīya Nityakarma Paddhati*, a manual of the daily rites of the Sāmaveda (Kauthuma recension). Pt. Chandrabhushan Dwivedi, Vyākaraṇācārya, compiled it. Mishri Prasad Pandey published it, and Sanmarg Press, Kashi, printed the first edition (Saṃvat 2005 / 1948 CE).

Site: https://abhinavananddwivedi.github.io/samvediya_nityakarma_paddhati/

Each page of the book was photographed and transcribed. The site shows every transcription beside its photograph. The transcription is diplomatic: the print's spelling and misprints are kept, and they are pointed out in editorial notes.

## Layout
- `transcripts/NNN.md`: one file per printed page, in book order. This is the source of truth.
- `Images/pages/`: upright photographs; `Images/figures/`: portraits and diagrams cropped from them.
- `book.yml`: site metadata. `scripts/build_site.R` and `scripts/site.css` generate `docs/`, which GitHub Pages serves.

## Rebuild
```
powershell scripts/tools/make_web_images.ps1
Rscript scripts/build_site.R
git add -A && git commit -m "..." && git push
```
See `CLAUDE.md` for the transcript format and `PROJECT_LOG.md` for the photo-to-page map and open questions.
