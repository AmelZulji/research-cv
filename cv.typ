// DATA

#let cv = yaml("cv.yml")


// ============================================================
// DESIGN SYSTEM
// ============================================================

// Typography
#let type = (
  font: "New Computer Modern",
  body: 10pt,

  // Relative to body size
  title: 2em,
  heading: 1.4em,
  subheading: 1.1em,
  minor: 0.95em,
  meta: 0.9em,
)


// Color palette
#let base_color = rgb("#6F777A")

#let color = (
  text: base_color.darken(85%),
  muted: base_color.darken(18%),
  panel: base_color.lighten(88%),
  rule: base_color.lighten(55%),
)


// Page geometry
#let layout = (
  page_height: 297mm,

  // Fixed height of the header
  header_height: 48mm,

  // Shared width of the sidebar and photo column
  sidebar_width: 70mm,

  // Padding inside major grid cells
  inset: 7mm,

  // Reserved right-hand column for dates
  date_width: 20mm,

  // Space between main entry content and date column
  date_gap: 0mm,
)


// Photo fills as much space as possible while fitting
// within both the header height and sidebar width.
#let photo_size = calc.min(
  layout.header_height - 2 * layout.inset,
  layout.sidebar_width - 2 * layout.inset,
)


// General spacing rhythm
#let space = (
  // Elements belonging closely together
  tight: 0.3em,

  // Related blocks
  related: 0.55em,

  // Separate entries or projects
  item: 0.9em,

  // Major sections
  section: 1.4em,

  // Organization / institution → first project
  entry_body: 0.85em,
)


// Section underline
#let rule_width = 1pt


// Tag appearance
#let tag_style = (
  // Padding inside each tag
  pad_x: 0.4em,
  pad_y: 0.3em,

  // Horizontal spacing between tags
  gap_x: 0.15em,

  // Vertical spacing between wrapped rows of tags
  gap_y: 0.2em,

  radius: 0.5em,
)


// Bullet-list appearance
#let bullet_style = (
  // Line spacing inside one wrapped bullet
  leading: 0.2em,

  // Spacing between separate bullet items
  gap: 0.4em,

  // Bullet marker position
  indent: 0pt,

  // Distance between bullet marker and text
  body_indent: 0.5em,
)


// Contact icon appearance
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

// Default paragraph rhythm used by normal prose.
#set par(
  leading: 0.5em,
  spacing: 0.35em,
)

// Structural spacing is controlled by the components below.
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


// Major section heading with full-width underline
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
// COMPONENTS
// ============================================================

// Major CV section
#let section(label, body) = block(
  below: space.section,
)[
  #stack(
    spacing: space.related,
    heading(label),
    body,
  )
]


// Education / experience entry.
//
// Main content occupies the flexible left column.
// Dates occupy a dedicated fixed-width rail on the right.
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

    [
      #meta(date)
    ],
  )
]


// Smaller titled unit used for projects, skill groups,
// publications, and additional activities.
#let item(label, body) = block(
  below: space.item,
)[
  #stack(
    spacing: space.tight,
    minor(label),
    body,
  )
]


// Bullet list.
//
// Paragraph leading controls wrapped lines within one bullet.
// List spacing controls separation between individual bullets.
#let bullets(values) = [
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


// Skill / language tag
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


// Inline collection of tags with wrapping support
#let tags(values) = [
  #set par(
    leading: tag_style.gap_y,
    spacing: 0pt,
  )

  #for value in values [
    #tag(value)
    #h(tag_style.gap_x)
  ]
]


// Contact entry.
//
// The YAML key determines the icon filename:
// email → assets/email.svg
// github → assets/github.svg
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


// Center the complete contact block below the name and title.
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
// ============================================================

// The first column exactly matches the sidebar width.
// Identity and profile share the remaining space.
// Increase the final `fr` value to give the profile more width.
#grid(
  columns: (
    layout.sidebar_width,
    1fr,
    1.5fr,
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

  // Photo
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

  // Identity and contacts
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

  // Profile
  [
    #set par(
      justify: true,
    )

    #cv.profile
  ],
)


// ============================================================
// PAGE 1 BODY
// ============================================================

// Sidebar width matches the first header column.
// The body fills the remaining height of the A4 page.
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

  // Sidebar
  [
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

    #section(
      "Languages",
      tags(cv.languages),
    )
  ],

  // Main column
  [
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

  // Publications
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


  // Additional user-defined sections
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