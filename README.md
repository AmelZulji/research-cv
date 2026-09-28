# Research CV

A Quarto CV template with one Typst layout, a two-page PDF, and an HTML PDF viewer.
Edit `cv.yml` for content and `cv-theme.yml` for the design.

[View the example PDF](template.pdf)

## Get started

Install Quarto 1.4 or newer and the font configured in `cv-theme.yml` (Arial by
default). Then create a project:

```bash
quarto use template AmelZulji/research-cv
```

From your new project directory:

1. Edit `cv.yml` with your profile, contacts, education, experience, and publications.
2. Replace `assets/photo.jpeg` and update image or icon paths in `cv.yml` as needed.
3. Adjust `cv-theme.yml` for colors, fonts, sizes, spacing, and column positions.
4. Render both formats:

```bash
quarto render template.qmd --to research-cv-html
```

This rebuilds `template.pdf` and creates `template.html`, which displays that PDF
with open and download links. Keep both files together when sharing or hosting;
the viewer's CSS is embedded in the HTML. Browsers without inline PDF support
can use the open/download links.

For just the PDF, use `--to research-cv-typst`. The existing `--to all` command
also works, but compiles the PDF for each format.

## Design and layout

Change `cv_theme.colors.theme` in `cv-theme.yml` to recolor both outputs. Palette
entries accept hex colors or `theme_color.lighten(N%)` / `theme_color.darken(N%)`.
Use lengths such as `mm`, `pt`, and `em` for shared layout settings.

The HTML displays the actual PDF, so fonts, spacing, wrapping, page numbers,
and pagination come from the same layout. On mobile, readers zoom the fixed
pages rather than getting a separate responsive CV layout. The PDF uses a fixed
two-page layout, so check for overflow after adding content.

`template.qmd` selects the metadata files and output formats. In
`_extensions/research-cv/`, `cv.lua` is the only CV renderer and `cv-theme.lua`
supplies its theme defaults. `cv-html.lua` calls that renderer, compiles the PDF
using Quarto's bundled Typst, and creates the viewer. `cv.css` styles only the
viewer toolbar and frame.

## License

[MIT](LICENSE)
