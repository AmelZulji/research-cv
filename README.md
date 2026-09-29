# Research CV

A minimal, YAML-driven CV template built with Typst and distributed as a Quarto starter template.

Content lives in `cv.yml`; layout and visual design live in `cv.typ`. The template produces a polished two-page A4 PDF with a structured header, sidebar, education and experience sections, publications, and additional activities.

[View the example PDF](preview/cv.pdf)

## Get started

### Requirements

Install [Quarto](https://quarto.org/).

No separate Typst installation is required: Quarto includes its own Typst compiler.

The template currently uses Arial, so Arial should be available on your system. You can change the font in the design settings at the top of `cv.typ`.

### Create a new CV

```bash
quarto use template AmelZulji/research-cv
```

Then move into the newly created directory and edit:

- `cv.yml` — your CV content
- `assets/photo.jpg` — your portrait
- `cv.typ` — visual design and layout, if desired

Compile the CV with:

```bash
quarto typst compile cv.typ
```

This creates:

```text
cv.pdf
```

Quarto uses its bundled Typst compiler for this command.

## License

[MIT](LICENSE)