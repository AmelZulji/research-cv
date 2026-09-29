// ============================================================
// DATA
// ============================================================

#let cv = yaml("cv.yml")


// ============================================================
// DESIGN SYSTEM
//
// Most visual changes should happen in this section.
// ============================================================


// ------------------------------------------------------------
// Typography
// ------------------------------------------------------------

#let type = (
  font: "Arial",
  body: 9.5pt,

  // Relative to body size
  title: 2em,
  heading: 1.15em,
  subheading: 1.02em,
  minor: 0.95em,
  meta: 0.9em,
)


// ------------------------------------------------------------
// Color
// ------------------------------------------------------------

#let base_color = rgb("#6F777A")

#let color = (
  text: base_color.darken(85%),
  muted: base_color.darken(18%),
  panel: base_color.lighten(88%),
  rule: base_color.lighten(55%),
)


// ------------------------------------------------------------
// Page geometry
// ------------------------------------------------------------

#let layout = (
  page_height: 297mm,

  header_height: 48mm,
  sidebar_width: 65mm,

  // Padding inside every major grid cell
  inset: 7mm,

  // Dedicated date column in Education / Experience
  date_width: 23mm,
  date_gap: 4mm,
)

// The photo is as large as possible while still fitting
// inside BOTH the header height and sidebar column.
#let photo_size = calc.min(
  layout.header_height - 2 * layout.inset,
  layout.sidebar_width - 2 * layout.inset,
)


// ------------------------------------------------------------
// General spacing rhythm
// ------------------------------------------------------------

#let space = (
  // Within one tightly related unit
  tight: 0.3em,

  // Related elements
  related: 0.55em,

  // Separate entries / projects
  item: 0.9em,

  // Major sections
  section: 1.4em,

  // Organization → first project
  entry_body: 0.85em,
)


// ------------------------------------------------------------
// Section rule
// ------------------------------------------------------------

#let rule_width = 0.6pt


// ------------------------------------------------------------
// Tags
// ------------------------------------------------------------

#let tag_style = (
  // Padding inside each tag
  pad_x: 0.4em,
  pad_y: 0.3em,

  // Distance between tags
  gap_x: 0.15em,

  // Distance between wrapped rows of tags
  gap_y: 0.2em,

  radius: 0.5em,
)


// ------------------------------------------------------------
// Bullets
// ------------------------------------------------------------

#let bullet_style = (
  // Wrapped lines WITHIN one long bullet
  leading: 0.12em,

  // Distance BETWEEN separate bullets
  gap: 0.28em,

  // Position of bullet marker
  indent: 0pt,

  // Marker → text distance
  body_indent: 0.5em,
)


// ------------------------------------------------------------
// Contact icons
// ------------------------------------------------------------

#let contact_style = (
  icon_size: 0.85em,
  icon_gap: 0.45em,
)


// ============================================================
// DOCUMENT DEFAULTS
// ============================================================

#set document(
  title: cv.name,
)

#set page(
  paper: "a4",
  margin: 0pt,
)

#set text(
  font: type.font,
  size: type.body,
  fill: color.text,
  lang: "en",
)

// Normal text and profile rhythm.
#set par(
  leading: 0.5em,
  spacing: 0.35em,
)

// Components below own structural spacing.
#set block(
  spacing: 0pt,
)


// ============================================================
// TYPOGRAPHIC HIERARCHY
// ============================================================


// Name
#let title(body) = text(
  size: type.title,
  weight: "bold",
  body,
)


// Major section heading
//
// Experience
// ─────────────────────────────
#let heading(body) = block(
  width: 100%,
)[
  #stack(
    spacing: space.tight,

    text(
      size: type.heading,
      weight: "bold",
      body,
    ),

    line(
      length: 100%,
      stroke: rule_width + color.rule,
    ),
  )
]


// Degree / position
#let subheading(body) = text(
  size: type.subheading,
  weight: "bold",
  body,
)


// Project / skill group / publication title
#let minor(body) = text(
  size: type.minor,
  weight: "bold",
  body,
)


// Dates / organizations / contacts / tags
#let meta(body) = text(
  size: type.meta,
  fill: color.muted,
  body,
)


// ============================================================
// GENERIC COMPONENTS
// ============================================================


// ------------------------------------------------------------
// Major section
//
// Heading
// ─────────────────
// content
// ------------------------------------------------------------

#let section(label, body) = block(
  below: space.section,
)[
  #stack(
    spacing: space.related,

    heading(label),

    body,
  )
]


// ------------------------------------------------------------
// Education / Experience entry
//
// LEFT COLUMN                         DATE
//
// Position / Degree                  2021–2026
// Organization
//
// Project
// • bullet
//
// Everything except the date stays inside the left column.
// ------------------------------------------------------------

#let entry(label, date, detail, body: none) = block(
  below: if body == none {
    space.related
  } else {
    space.item
  },
)[
  #grid(
    columns: (
      1fr,
      layout.date_width,
    ),

    column-gutter: layout.date_gap,

    align: (
      left + top,
      right + top,
    ),


    // Main content
    [
      #let header = stack(
        spacing: space.tight,

        subheading(label),

        meta(detail),
      )

      #if body == none {
        header
      } else {
        stack(
          spacing: space.entry_body,

          header,

          body,
        )
      }
    ],


    // Date rail
    [
      #meta(date)
    ],
  )
]


// ------------------------------------------------------------
// Smaller titled item
//
// Project / skill category / publication
// ------------------------------------------------------------

#let item(label, body) = block(
  below: space.item,
)[
  #stack(
    spacing: space.tight,

    minor(label),

    body,
  )
]


// ============================================================
// BULLETS
// ============================================================

#let bullets(values) = [
  // These paragraph settings apply ONLY inside bullets.
  #set par(
    justify: true,
    leading: bullet_style.leading,
    spacing: 0pt,
  )

  #list(
    tight: true,

    spacing: bullet_style.gap,

    indent: bullet_style.indent,
    body-indent: bullet_style.body_indent,

    ..values.map(
      value => [#value]
    )
  )
]


// ============================================================
// TAGS
// ============================================================

#let tag(body) = box(
  inset: (
    x: tag_style.pad_x,
    y: tag_style.pad_y,
  ),

  radius: tag_style.radius,
  fill: white,

)[
  #meta(body)
]


#let tags(values) = [
  // Local line spacing controls wrapped tag rows.
  #set par(
    leading: tag_style.gap_y,
    spacing: 0pt,
  )

  #for value in values [
    #tag(value)
    #h(tag_style.gap_x)
  ]
]


// ============================================================
// CONTACTS
//
// YAML key → matching assets/<key>.svg
//
// email → assets/email.svg
// github → assets/github.svg
// etc.
// ============================================================

#let contact(kind, value) = grid(
  columns: (
    contact_style.icon_size,
    auto,
  ),

  column-gutter: contact_style.icon_gap,

  align: (
    center + horizon,
    left + horizon,
  ),

  [
    #image(
      "assets/" + kind + ".svg",
      width: contact_style.icon_size,
    )
  ],

  [
    #meta(value)
  ],
)


#let contacts(values) = align(center)[
  #stack(
    spacing: space.tight,

    ..values.pairs().map(
      pair => contact(
        pair.at(0),
        pair.at(1),
      )
    ),
  )
]


// ============================================================
// HEADER
//
// First column exactly matches the sidebar width:
//
// |    sidebar width    |      equal      |      equal      |
// |       photo         | name + contact  |     profile     |
//
// This gives the photo and sidebar the same vertical axis.
// ============================================================

#grid(
  columns: (
    layout.sidebar_width,
    1fr,
    1fr,
  ),

  rows: (
    layout.header_height,
  ),

  inset: layout.inset,
  fill: color.panel,

  align: (
    center + horizon,
    center + horizon,
    left + horizon,
  ),


  // ----------------------------------------------------------
  // Photo
  // ----------------------------------------------------------

  [
    #box(
      width: photo_size,
      height: photo_size,

      radius: 50%,
      clip: true,

    )[
      #image(
        cv.photo,

        width: 100%,
        height: 100%,

        fit: "cover",
      )
    ]
  ],


  // ----------------------------------------------------------
  // Identity + contacts
  // ----------------------------------------------------------

  [
    #stack(
      spacing: space.related,

      stack(
        spacing: space.tight,

        title(cv.name),

        cv.title,
      ),

      contacts(cv.contact),
    )
  ],


  // ----------------------------------------------------------
  // Profile
  // ----------------------------------------------------------

  [
    // Profile only: justified.
    #set par(
      justify: true,
    )

    #cv.profile
  ],
)


// ============================================================
// BODY
//
// First body column exactly matches the first header column.
//
// |      sidebar       |                main                |
// ============================================================

#grid(
  columns: (
    layout.sidebar_width,
    1fr,
  ),

  rows: (
    layout.page_height - layout.header_height,
  ),

  inset: layout.inset,

  fill: (
    color.panel,
    none,
  ),

  align: (
    left + top,
    left + top,
  ),


  // ==========================================================
  // SIDEBAR
  // ==========================================================

  [

    // --------------------------------------------------------
    // Skills
    // --------------------------------------------------------

    #for (skill_section, groups) in cv.skills [

      #section(
        skill_section,

        [
          #for (group_name, values) in groups [

            #item(
              group_name,

              tags(values),
            )
          ]
        ],
      )
    ]


    // --------------------------------------------------------
    // Languages
    // --------------------------------------------------------

    #section(
      "Languages",

      tags(cv.languages),
    )
  ],


  // ==========================================================
  // MAIN COLUMN
  // ==========================================================

  [

    // --------------------------------------------------------
    // Education
    // --------------------------------------------------------

    #section(
      "Education",

      [
        #for degree in cv.education [

          #entry(
            degree.degree,
            degree.dates,
            degree.institution,
          )
        ]
      ],
    )


    // --------------------------------------------------------
    // Experience
    // --------------------------------------------------------

    #section(
      "Experience",

      [
        #for job in cv.experience [

          #entry(
            job.role,
            job.dates,
            job.organization,

            body: [

              #for project in job.projects [

                #item(
                  project.title,

                  bullets(project.bullets),
                )
              ]
            ],
          )
        ]
      ],
    )
  ],
)


// ============================================================
// PAGE 2
// ============================================================

#pagebreak()


#block(
  width: 100%,
  inset: layout.inset,
)[

  // ----------------------------------------------------------
  // Publications
  // ----------------------------------------------------------

  #section(
    "Publications",

    [
      #for publication in cv.publications [

        #item(
          publication.title,

          [
            #publication.authors

            #linebreak()

            #meta(publication.details)
          ],
        )
      ]
    ],
  )


  // ----------------------------------------------------------
  // Additional sections
  // ----------------------------------------------------------

  #for (section_name, entries) in cv.additional [

    #section(
      section_name,

      [
        #for entry in entries [

          #item(
            entry.title,

            entry.description,
          )
        ]
      ],
    )
  ]
]