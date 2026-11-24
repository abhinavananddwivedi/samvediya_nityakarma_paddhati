# Builds the static site in docs/ from transcripts/*.md and Images/web/.
# Usage: Rscript scripts/build_site.R
# docs/ is generated output: never hand-edit it (docs/assets/fonts/ is the only kept input).
#
# Source format (one file per printed page, named NNN.md in book order) -- see CLAUDE.md:
#   YAML front matter (section, label, printed_page, photo, alt_photos, notes), then a body
#   whose lines are typed by prefix:
#     "# " "## " "### " headings     "> " verse/mantra line      "^ " centred line
#     ">> " right-aligned line        "<< " left-aligned line     "| " table row
#     "---" rule    "!ornament"    "!fig path | caption"    anything else: prose
#   Blank lines separate blocks. Inline: **bold**, [unclear: guess].

suppressPackageStartupMessages({
  library(tidyverse)
  library(yaml)
  library(glue)
})

script_path <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- normalizePath(file.path(dirname(script_path), ".."))
tr_dir <- file.path(root, "transcripts")
docs <- file.path(root, "docs")
web_img <- file.path(root, "Images", "web")

book <- read_yaml(file.path(root, "book.yml"))

# ---- read pages -------------------------------------------------------------

read_page <- function(path) {
  lines <- read_lines(path)
  fm_end <- which(lines == "---")[2]
  meta <- yaml.load(paste(lines[2:(fm_end - 1)], collapse = "\n"))
  meta$body <- lines[-(1:fm_end)]
  meta$slug <- tools::file_path_sans_ext(basename(path))
  meta
}

pages <- list.files(tr_dir, pattern = "^\\d{3}\\.md$", full.names = TRUE) |>
  sort() |>
  map(read_page)

section_keys <- map_chr(book$sections, "key")
stopifnot(all(map_chr(pages, "section") %in% section_keys))

# ---- inline + block rendering ----------------------------------------------

esc <- function(x) {
  x |>
    str_replace_all("&", "&amp;") |>
    str_replace_all("<", "&lt;") |>
    str_replace_all(">", "&gt;")
}

inline <- function(x) {
  x |>
    esc() |>
    str_replace_all("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>") |>
    str_replace_all("\\*([^*]+?)\\*", "<em>\\1</em>") |>
    str_replace_all("\\[unclear: ?(.+?)\\]",
                    '<span class="unclear" title="uncertain reading">\\1</span>')
}

line_type <- function(l) {
  case_when(
    l == "" ~ "blank",
    str_detect(l, "^### ") ~ "h3",
    str_detect(l, "^## ") ~ "h2",
    str_detect(l, "^# ") ~ "h1",
    str_detect(l, "^>> ") ~ "right",
    str_detect(l, "^<< ") ~ "left",
    str_detect(l, "^> ") ~ "verse",
    str_detect(l, "^\\^ ") ~ "center",
    str_detect(l, "^\\|") ~ "table",
    l == "---" ~ "hr",
    l == "!ornament" ~ "ornament",
    str_detect(l, "^!fig ") ~ "fig",
    TRUE ~ "prose"
  )
}

strip_prefix <- function(l) str_remove(l, "^(### |## |# |>> |<< |> |\\^ )")

render_table <- function(rows) {
  cells <- rows |>
    str_remove("^\\|") |>
    str_remove("\\|\\s*$") |>
    str_split("\\|") |>
    map(str_trim)
  is_sep <- map_lgl(cells, ~ all(str_detect(.x, "^:?-+:?$")))
  has_head <- length(cells) > 1 && is_sep[2]
  tr <- function(cs, tag) {
    cs <- str_replace_all(inline(cs), " // ", "<br>")
    paste0("<tr>", paste0("<", tag, ">", cs, "</", tag, ">", collapse = ""), "</tr>")
  }
  head <- if (has_head) paste0("<thead>", tr(cells[[1]], "th"), "</thead>") else ""
  body_rows <- cells[!is_sep & (seq_along(cells) > if (has_head) 1 else 0)]
  glue('<div class="table-wrap"><table>{head}<tbody>{paste(map_chr(body_rows, tr, tag = "td"), collapse = "")}</tbody></table></div>')
}

render_group <- function(type, lines) {
  txt <- strip_prefix(lines)
  switch(type,
    h1 = glue("<h2 class='t-h1'>{inline(paste(txt, collapse = ' '))}</h2>"),
    h2 = glue("<h3 class='t-h2'>{inline(paste(txt, collapse = ' '))}</h3>"),
    h3 = glue("<h4 class='t-h3'>{inline(paste(txt, collapse = ' '))}</h4>"),
    verse = {
      vl <- if_else(str_detect(txt, "^\\s"), paste0("<span class='ind'>", inline(str_trim(txt)), "</span>"), inline(txt))
      glue("<div class='verse' lang='sa'>{paste(vl, collapse = '<br>')}</div>")
    },
    center = glue("<p class='center'>{paste(inline(txt), collapse = '<br>')}</p>"),
    right = glue("<p class='right'>{paste(inline(txt), collapse = '<br>')}</p>"),
    left = glue("<p class='left'>{paste(inline(txt), collapse = '<br>')}</p>"),
    table = render_table(lines),
    hr = strrep("<hr class='rule'>", length(lines)),
    ornament = "<p class='ornament' aria-hidden='true'>❦</p>",
    fig = map_chr(lines, function(l) {
      parts <- str_split_fixed(str_remove(l, "^!fig "), "\\s*\\|\\s*", 2)
      src <- paste0("images/", str_replace(parts[1], "\\.png$", ".jpg"))
      glue("<figure><a href='{src}'><img src='{src}' alt='{esc(parts[2])}' loading='lazy'></a></figure>")
    }) |> paste(collapse = "\n"),
    prose = glue("<p>{paste(inline(txt), collapse = '<br>')}</p>")
  )
}

render_body <- function(body) {
  tibble(line = body, type = line_type(body)) |>
    mutate(grp = consecutive_id(type)) |>
    filter(type != "blank") |>
    group_by(grp) |>
    summarise(html = render_group(first(type), line), .groups = "drop") |>
    pull(html) |>
    paste(collapse = "\n")
}

# ---- shared pieces -------------------------------------------------------------

page_title <- function(p) {
  pp <- if (!is.null(p$printed_page)) glue(" · पृ० {p$printed_page}") else ""
  glue("{p$label}{pp}")
}

head_html <- function(title, desc = book$title_en) {
  glue('<!doctype html>
<html lang="hi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(desc)}">
<link rel="stylesheet" href="style.css">
</head>
<body>')
}

foot_html <- glue('<footer>{esc(book$title)} · {esc(book$title_en)} · digitised from photographs of the {esc(book$edition_en)}.</footer>
</body>
</html>')

photo_html <- function(p) {
  if (is.null(p$photo)) return("")
  alts <- unlist(p$alt_photos)
  alt_links <- if (length(alts)) {
    paste0(" · other photograph: ",
           paste(glue("<a href='images/{alts}.jpg'>{alts}</a>"), collapse = ", "))
  } else ""
  glue('<aside class="scan">
  <a href="images/{p$photo}.jpg"><img src="images/{p$photo}.jpg" alt="Photograph of this page" loading="lazy"></a>
  <p class="scan-cap">Photograph {p$photo} · <a href="images/{p$photo}.jpg">open full size</a>{alt_links}</p>
</aside>')
}

notes_html <- function(p) {
  n <- unlist(p$notes)
  unclear <- any(str_detect(p$body, "\\[unclear"))
  items <- c(inline(n), if (unclear) "Words shown <span class='unclear'>like this</span> are uncertain readings.")
  if (!length(items)) return("")
  glue("<div class='ed-notes'><p class='ed-label'>Editorial notes</p><ul>{paste0('<li>', items, '</li>', collapse = '')}</ul></div>")
}

# ---- write ------------------------------------------------------------------------

dir.create(file.path(docs, "images", "figures"), recursive = TRUE, showWarnings = FALSE)
file.create(file.path(docs, ".nojekyll"))
invisible(file.copy(file.path(root, "scripts", "site.css"), file.path(docs, "style.css"), overwrite = TRUE))

used_photos <- pages |> map(~ c(.x$photo, unlist(.x$alt_photos))) |> unlist() |> unique()
walk(used_photos, ~ file.copy(file.path(web_img, paste0(.x, ".jpg")),
                              file.path(docs, "images", paste0(.x, ".jpg")), overwrite = TRUE))
walk(list.files(file.path(web_img, "figures"), full.names = TRUE),
     ~ file.copy(.x, file.path(docs, "images", "figures", basename(.x)), overwrite = TRUE))

section_name <- set_names(map_chr(book$sections, "name"), section_keys)

for (i in seq_along(pages)) {
  p <- pages[[i]]
  prev_l <- if (i > 1) glue("<a href='{pages[[i - 1]]$slug}.html' rel='prev'>← पिछला</a>") else "<span></span>"
  next_l <- if (i < length(pages)) glue("<a href='{pages[[i + 1]]$slug}.html' rel='next'>अगला →</a>") else "<span></span>"
  nav <- glue("<nav class='pnav'>{prev_l}<a href='index.html'>अनुक्रम</a>{next_l}</nav>")
  html <- glue('{head_html(paste(page_title(p), "—", book$title))}
<header class="top"><a href="index.html">{esc(book$title)}</a> <span class="crumb">/ {esc(section_name[[p$section]])}</span></header>
{nav}
<main class="page">
  <article class="text">
    <p class="page-label">{esc(page_title(p))}</p>
    {render_body(p$body)}
    {notes_html(p)}
  </article>
  {photo_html(p)}
</main>
{nav}
{foot_html}')
  write_lines(html, file.path(docs, glue("{p$slug}.html")))
}

# full text, one long page
full_body <- pages |>
  map_chr(function(p) {
    glue("<section class='full-page' id='p{p$slug}'>
<p class='page-label'><a href='{p$slug}.html'>{esc(page_title(p))}</a></p>
{render_body(p$body)}
</section>")
  }) |>
  paste(collapse = "\n")
write_lines(glue('{head_html(paste("सम्पूर्ण पाठ —", book$title))}
<header class="top"><a href="index.html">{esc(book$title)}</a> <span class="crumb">/ सम्पूर्ण पाठ (full text)</span></header>
<main class="full">{full_body}</main>
{foot_html}'), file.path(docs, "full.html"))

# index
toc <- book$sections |>
  map_chr(function(s) {
    sp <- keep(pages, ~ .x$section == s$key)
    if (!length(sp)) return("")
    items <- map_chr(sp, ~ glue("<li><a href='{.x$slug}.html'>{esc(page_title(.x))}</a></li>"))
    glue("<section class='toc-sec'><h3>{esc(s$name)}</h3>{if (!is.null(s$note)) glue('<p class=\"sec-note\">{esc(s$note)}</p>') else ''}<ol>{paste(items, collapse = '')}</ol></section>")
  }) |>
  paste(collapse = "\n")

figs <- book$figures |>
  map_chr(~ glue("<figure><a href='{.x$page}.html'><img src='images/{.x$src}' alt='{esc(.x$caption)}' loading='lazy'></a><figcaption>{esc(.x$caption)}</figcaption></figure>")) |>
  paste(collapse = "\n")

about <- book$about |> map_chr(~ glue("<p>{inline(.x)}</p>")) |> paste(collapse = "\n")

write_lines(glue('{head_html(book$title)}
<main class="home">
  <header class="hero">
    <p class="kicker">ॐ शिवः</p>
    <h1>{esc(book$title)}</h1>
    <p class="sub">{esc(book$subtitle)}</p>
    <p class="by">{esc(book$byline)}</p>
  </header>
  <div class="gallery">{figs}</div>
  <section class="about">{about}</section>
  <p class="cta"><a href="{pages[[1]]$slug}.html">पृष्ठ-दर-पृष्ठ पढ़ें (read page by page)</a> · <a href="full.html">सम्पूर्ण पाठ (full text on one page)</a></p>
  <section class="toc"><h2>अनुक्रम · Contents</h2>{toc}</section>
</main>
{foot_html}'), file.path(docs, "index.html"))

message(glue("Built {length(pages)} pages into {docs}"))
