# Research CV

A customizable two-page research CV built with Quarto and Typst.

[View the rendered example CV](template.pdf)

The CV content and visual design are kept separate:

- `cv.yml` controls the CV content
- `cv-theme.yml` controls colors, typography, spacing, and layout
- `assets/` contains the profile image and contact icons

## Requirements

- Quarto 1.4 or newer
- Arial, or another font configured in `cv-theme.yml`

## Create a new CV

Use this repository as a Quarto template:

```bash
quarto use template AmelZulji/research-cv
````

Quarto will create a new project containing the complete CV template and all required files.

## Customize the CV

After creating the project:

1. Edit `cv.yml` to add your CV content.
2. Edit `cv-theme.yml` to customize colors, typography, spacing, and layout.
3. Replace `assets/photo.jpeg` with your own profile image if desired. If you use a different filename or location, make sure to update the corresponding path in `cv.yml`.
4. Add, remove, or replace contact icons in `assets/` as needed. Make sure the corresponding icon paths in `cv.yml` are kept up to date.

## Render

From inside the created project directory, run:

```bash
quarto render
```

The rendered PDF will be written to the project directory.

## Project structure

```text
research-cv/
├── template.qmd
├── _quarto.yml
├── cv.yml
├── cv-theme.yml
├── assets/
│   ├── photo.jpeg
│   ├── email.svg
│   ├── location.svg
│   ├── github.svg
│   ├── linkedin.svg
│   └── bluesky.svg
└── _extensions/
    └── research-cv/
        ├── _extension.yml
        ├── cv.lua
        └── cv-shell.typ
```

`template.qmd` connects the CV content and theme files to the custom `research-cv-typst` format. In most cases, you only need to edit `cv.yml`, `cv-theme.yml`, and the files in `assets/`.

## Customize the theme

The main theme color is defined in `cv-theme.yml`:

```yaml
colors:
  theme: "#6F777A"
```

Several other colors are derived automatically from this value, so changing `colors.theme` recolors the CV consistently.

Individual colors can also be overridden with fixed hexadecimal values:

```yaml
colors:
  theme: "#526D82"
  accent: "theme_color.darken(10%)"
  panel: "#EEF2F5"
```

The same file also controls page layout, typography, section spacing, sidebar dimensions, header layout, publication styling, and footer settings.

## License

MIT
