// DATA

#let cv = yaml("cv.yml")

#let publications = cv.at("publications", default: ())
#let additional = cv.at("additional", default: (:))


// ============================================================
// DESIGN SYSTEM
// ============================================================

// Typography
#let type = (
  font: "Arial",
  body: 9.5pt,

  // Relative to body size
  title: 2em,
  heading: 1.35em,
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
  tag: base_color.lighten(95%),
  rule: base_color.lighten(55%),
)


// Page geometry
#let layout = (
  page_height: 297mm,

  // Fixed header height
  header_height: 48mm,

  // Physical width of the sidebar
  sidebar_width: 70mm,

  // Fixed width of the profile region
  profile_width: 68mm,

  // Outer page/header padding
  inset: 7mm,

  // Reserved date rail in main entries
  date_width: 23mm,
  date_gap: 0mm,
)


// Normal prose rhythm
#let prose_style = (
  leading: 0.5em,
  spacing: 0.35em,
)


// General spacing rhythm
#let space = (
  // Closely related elements
  tight: 0.3em,

  // Related blocks
  related: 0.55em,

  // Separate entries or projects
  item: 0.9em,

  // Major sections
  section: 1.4em,

  // Entry header → nested content
  entry_body: 0.85em,
)


// Section underline
#let rule_width = 1pt


// Tag appearance
#let tag_style = (
  pad_x: 0.4em,
  pad_y: 0.3em,

  gap_x: 0.15em,
  gap_y: 0.2em,

  radius: 0.5em,
)


// Bullet-list appearance
#let bullet_style = (
  // Wrapped lines within one bullet
  leading: 0.2em,

  // Space between separate bullets
  gap: 0.4em,

  indent: 0pt,
  body_indent: 0.5em,
)


// Contact icons
#let contact_style = (
  icon_size: 1.6em,
  gap: 1em,
)


// Footer
#let footer_style = (
  rule_width: 0.5pt,
  gap: 0.35em,
)


// ============================================================
// HEADER GEOMETRY
// ============================================================

// Photo size is limited by both header height and sidebar width.
#let photo_size = calc.min(
  layout.header_height - 2 * layout.inset,
  layout.sidebar_width - 2 * layout.inset,
)


// The photo center is locked to the center of the sidebar.
// The first header track ends at the visible right edge
// of the photo rather than at the sidebar boundary.
#let photo_center = layout.sidebar_width / 2
#let photo_radius = photo_size / 2
#let header_photo_track = photo_center + photo_radius - layout.inset


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

#set par(
  leading: prose_style.leading,
  spacing: prose_style.spacing,
)

// Components explicitly control their own vertical spacing.
#set block(
  spacing: 0pt,
)


// ============================================================
// TYPOGRAPHY
// ============================================================

// Name
#let title(body) = text(
  size: type.title,
  weight: "bold",
  body,
)


// Major section heading
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


// Main entry title
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


// Dates, organizations, location, and secondary information
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


// Main-column entry.
// The right-hand date rail remains reserved for nested content.
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


// Wrapped lines within one bullet and spacing between
// separate bullets are controlled independently.
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
  fill: color.tag,
)[
  #meta(body)
]


// Wrapping collection of tags
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


// Contact icons take their source and optional destination
// directly from cv.yml.
#let contact(entry) = {
  let icon = image(
    entry.icon,
    width: contact_style.icon_size,
    height: contact_style.icon_size,
    fit: "contain",
    alt: entry.at("alt", default: none),
  )

  if "url" in entry {
    link(entry.url, icon)
  } else {
    icon
  }
}


// Contact icons in one centered horizontal row
#let contacts(values) = align(center)[
  #grid(
    columns: (auto,) * values.len(),
    column-gutter: contact_style.gap,
    align: center + horizon,

    ..values.map(contact),
  )
]


// Minimal footer used on the second page.
#let footer() = block(
  width: 100%,

  inset: (
    x: layout.inset,
    bottom: layout.inset,
  ),
)[
  #stack(
    spacing: footer_style.gap,

    line(
      length: 100%,
      stroke: footer_style.rule_width + color.rule,
    ),

    grid(
      columns: (
        1fr,
        auto,
      ),

      align: (
        left + horizon,
        right + horizon,
      ),

      meta(cv.name),

      context meta(
        counter(page).display(
          "1 / 1",
          both: true,
        )
      ),
    ),
  )
]


// ============================================================
// DATA RENDERERS
// ============================================================

// Sidebar skill sections
#let render_skills(skills) = [
  #for (skill_section, groups) in skills [
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
]


// Nested items inside a main entry
#let render_nested(items) = [
  #for nested_item in items [
    #item(
      nested_item.title,
      bullets(nested_item.bullets),
    )
  ]
]


// Generic main-column sections
#let render_main(sections) = [
  #for (section_name, entries) in sections [
    #section(
      section_name,

      [
        #for entry_data in entries [
          #let nested = entry_data.at(
            "items",
            default: (),
          )

          #entry(
            entry_data.title,
            entry_data.dates,
            entry_data.organization,

            body: if nested.len() == 0 {
              none
            } else {
              render_nested(nested)
            },
          )
        ]
      ],
    )
  ]
]


// Publication list
#let render_publications(entries) = [
  #for publication in entries [
    #item(
      publication.title,

      [
        #publication.authors
        #linebreak()
        #meta(publication.details)
      ],
    )
  ]
]


// Additional user-defined sections
#let render_additional(sections) = [
  #for (section_name, entries) in sections [
    #section(
      section_name,

      [
        #for entry_data in entries [
          #item(
            entry_data.title,
            entry_data.description,
          )
        ]
      ],
    )
  ]
]


// ============================================================
// HEADER
// ============================================================

// The outer grid provides one 7 mm inset around the complete
// header. The inner grid has no padding or gutter.
//
// The photo remains centered on the sidebar axis, while the
// identity begins at the visible right edge of the photo.
#grid(
  columns: (1fr,),
  rows: (layout.header_height,),

  inset: layout.inset,
  fill: color.panel,

  [
    #grid(
      columns: (
        header_photo_track,
        1fr,
        layout.profile_width,
      ),

      inset: 0pt,
      column-gutter: 0pt,

      align: (
        right + horizon,
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
            alt: "Portrait of " + cv.name,
          )
        ]
      ],

      // Identity
      [
        #align(center)[
          #stack(
            spacing: space.related,

            stack(
              spacing: space.tight,
              title(cv.name),
              cv.title,
            ),

            meta(cv.location),

            contacts(cv.contact),
          )
        ]
      ],

      // Profile
      [
        #set par(
          justify: false,
        )

        #cv.profile
      ],
    )
  ],
)


// ============================================================
// PAGE 1 BODY
// ============================================================

// Sidebar width is fixed. Both body cells receive the standard
// 7 mm inset, while main sections are data-driven through cv.main.
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
    #render_skills(cv.skills)

    #section(
      "Languages",
      tags(cv.languages),
    )
  ],

  // Main column
  [
    #render_main(cv.main)
  ],
)


// ============================================================
// PAGE 2
// ============================================================

#if publications.len() > 0 or additional.len() > 0 [
  #pagebreak()

  // Bottom float reserves space for the footer instead of
  // overlaying normal page content.
  #place(
    bottom,
    float: true,
    clearance: 0pt,
    footer(),
  )

  #block(
    width: 100%,
    inset: layout.inset,
  )[

    #if publications.len() > 0 [
      #section(
        "Publications",
        render_publications(publications),
      )
    ]

    #render_additional(additional)
  ]
]