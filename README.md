# Research CV

A customizable two-page research CV built with Quarto and Typst. Content and
appearance are kept separate: edit `cv.yml` for the CV and `cv-theme.yml` for
the design.

## Requirements

- Quarto 1.4 or newer
- A Typst installation available to Quarto
- Arial, or another font selected in `cv-theme.yml`

## Start a new CV

Once this repository is published on GitHub, create a complete working copy:

```bash
quarto use template OWNER/research-cv
```

Quarto copies the starter project and renames `template.qmd` to match the new
directory. Alternatively, clone or download this repository directly.

## Edit and render

1. Replace the example content in `cv.yml`.
2. Replace `assets/headshot-placeholder.png` and update contact links.
3. Adjust colors, typography, spacing, and layout in `cv-theme.yml`.
4. Render the document:

```bash
quarto render template.qmd
```

The PDF is written next to the source document.

## Use the format in an existing Quarto project

Install only the reusable format from GitHub:

```bash
quarto add OWNER/research-cv
```

Then select it in a document:

```yaml
---
title: "Curriculum Vitae"
metadata-files:
  - cv-theme.yml
  - cv.yml
format:
  research-cv-typst:
    keep-typ: true
---
```

The document must provide `cv` and `cv_theme` metadata. The easiest setup is
to copy `cv.yml`, `cv-theme.yml`, and `assets/` from the starter template.

## Project structure

```text
research-cv/
├── template.qmd
├── cv.yml
├── cv-theme.yml
├── assets/
└── _extensions/research-cv/
    ├── _extension.yml
    ├── cv.lua
    └── cv-shell.typ
```

The included name, institutions, dates, research descriptions, publications,
and portrait are fictional examples intended only to demonstrate the template.

## Theme colors

Change `colors.theme` to recolor the derived palette. Any derived expression
can be replaced with a fixed hexadecimal color:

```yaml
colors:
  theme: "#526D82"
  accent: "theme_color.darken(10%)"
  panel: "#EEF2F5"
```

## License

MIT
