local stringify = pandoc.utils.stringify

local function value_text(value)
  if value == nil then
    return ""
  end

  local kind = type(value)
  if kind == "string" or kind == "number" or kind == "boolean" then
    return tostring(value)
  end

  return stringify(value)
end

local function list(value)
  if type(value) == "table" then
    return value
  end
  return {}
end

local function q(value)
  local text = value_text(value)
  text = text:gsub("\\", "\\\\")
  text = text:gsub('"', '\\"')
  text = text:gsub("\r", "")
  text = text:gsub("\n", "\\n")
  return '"' .. text .. '"'
end

local function raw_value(value, default)
  local text = value_text(value)
  if text == "" then
    return default
  end
  return text
end

local function font_expr(value, default)
  if type(value) == "table" then
    local items = {}
    for _, font in ipairs(value) do
      local text = value_text(font)
      if text ~= "" then
        table.insert(items, q(text))
      end
    end

    if #items > 0 then
      return "(" .. table.concat(items, ", ") .. ")"
    end
  end

  return q(raw_value(value, default))
end

local function emit(out, line)
  table.insert(out, line)
end

local function text_call(text, size, opts)
  opts = opts or {}
  local args = {}
  if size then
    table.insert(args, "size: " .. size)
  end
  if opts.weight then
    table.insert(args, "weight: " .. q(opts.weight))
  end
  if opts.style then
    table.insert(args, "style: " .. q(opts.style))
  end
  if opts.fill then
    table.insert(args, "fill: " .. opts.fill)
  end
  table.insert(args, q(text))
  local call = "#text(" .. table.concat(args, ", ") .. ")"
  if opts.underline then
    return "#underline[" .. call .. "]"
  end
  return call
end

local function block_line(out, text, size, below, opts)
  emit(out, "#block(below: " .. below .. ")[")
  emit(out, "  " .. text_call(text, size, opts))
  emit(out, "]")
end

local function render_skill_items(out, items)
  local skill_items = list(items)
  if #skill_items == 0 then
    return
  end

  emit(out, "#block(below: skill_group_gap)[")
  emit(out, "  #set par(leading: 0.28em)")
  for _, item in ipairs(skill_items) do
    emit(out, "  #skill_item(" .. q(item) .. ")#h(skill_chip_gap)")
  end
  emit(out, "]")
end

local function render_tags(out, items)
  local tags = list(items)
  if #tags == 0 then
    return
  end

  emit(out, "#block(below: skill_group_gap)[")
  emit(out, "  #set par(leading: 0.28em)")
  for _, item in ipairs(tags) do
    emit(out, "  #language_tag(" .. q(item) .. ")#h(skill_chip_gap)")
  end
  emit(out, "]")
end

local function render_header_contact_row(out, contacts)
  local items = list(contacts)
  if #items == 0 then
    return
  end

  emit(out, "      #align(center)[#box(width: contact_content_w)[")
  for index, item in ipairs(items) do
    local below = index == #items and "0mm" or "contact_row_after"
    emit(out, "        #block(below: " .. below .. ")[#header_contact_item(" .. q(item.icon) .. ", " .. q(item.label) .. ", " .. q(item.url) .. ")]")
  end
  emit(out, "      ]]")
end

local function sorted_highlights(highlights)
  local result = {}
  for _, highlight in ipairs(list(highlights)) do
    local text = value_text(highlight)
    if text ~= "" then
      table.insert(result, text)
    end
  end

  table.sort(result, function(a, b)
    return #a > #b
  end)

  return result
end

local function highlighted_text(text, highlights, size)
  local source = value_text(text)
  local markers = sorted_highlights(highlights)
  local parts = {}
  local pos = 1

  while pos <= #source do
    local best_start = nil
    local best_marker = nil

    for _, marker in ipairs(markers) do
      local start_at = string.find(source, marker, pos, true)
      if start_at and (best_start == nil or start_at < best_start) then
        best_start = start_at
        best_marker = marker
      end
    end

    if best_start == nil then
      table.insert(parts, text_call(source:sub(pos), size))
      break
    end

    if best_start > pos then
      table.insert(parts, text_call(source:sub(pos, best_start - 1), size))
    end

    table.insert(parts, text_call(best_marker, size, { weight = "bold" }))
    pos = best_start + #best_marker
  end

  return table.concat(parts, "")
end

local function render_bullets(out, bullets, size, below)
  local items = list(bullets)
  if #items == 0 then
    return
  end

  emit(out, "#block(below: " .. below .. ")[")
  emit(out, "  #list(marker: [#text(size: bullet_size, fill: accent)[#sym.bullet]], tight: true, indent: bullet_indent, body-indent: bullet_body_indent, spacing: list_item_gap,")
  for _, bullet in ipairs(items) do
    emit(out, "    [" .. text_call(bullet, size) .. "],")
  end
  emit(out, "  )")
  emit(out, "]")
end

local function render_job_header(out, job)
  emit(out, "#block(below: job_role_gap)[")
  emit(out, "  #grid(columns: (1fr, auto), align: horizon,")
  emit(out, "    [" .. text_call(job.role, "role_size", { weight = "bold" }) .. "],")
  emit(out, "    [" .. text_call(job.dates, "meta_size", { weight = "bold", fill = "accent" }) .. "],")
  emit(out, "  )")
  emit(out, "]")
  block_line(out, job.organization, "meta_size", "job_org_gap", { fill = "muted" })
end

local function render_sidebar_section(out, section)
  emit(out, "#sidebar_title(" .. q(section.title) .. ")")

  local section_type = value_text(section.type)
  if section_type == "timeline" then
    for _, entry in ipairs(list(section.entries)) do
      block_line(out, entry.title, "side_label_size", "timeline_title_gap", { weight = "bold" })
      block_line(out, entry.detail, "side_meta_size", "timeline_entry_gap", { fill = "muted" })
    end
  elseif section_type == "skills" then
    for _, group in ipairs(list(section.groups)) do
      block_line(out, group.title, "side_label_size", "skill_title_gap", { weight = "bold" })
      render_skill_items(out, group.items)
    end
  elseif section_type == "text" then
    block_line(out, section.text, "side_meta_size", "0.85mm", { fill = "muted" })
  elseif section_type == "tags" then
    render_tags(out, section.items)
  end

  emit(out, "#v(sidebar_section_after)")
end

local function render_experience(out, cv)
  emit(out, "#section_title(\"Research Experience\")")
  local jobs = list(cv.experience)
  for index, job in ipairs(jobs) do
    render_job_header(out, job)

    for _, project in ipairs(list(job.projects)) do
      block_line(out, project.title, "project_size", "project_title_gap", { weight = "semibold" })
      render_bullets(out, project.bullets, "bullet_size", "project_after")
    end

    if index < #jobs then
      emit(out, "#v(entry_after)")
    end
  end
  emit(out, "#v(section_after)")
end

local function render_education(out, cv)
  local entries = list(cv.education)
  if #entries == 0 then
    return
  end

  emit(out, "#section_title(\"Education\")")
  for index, entry in ipairs(entries) do
    emit(out, "#block(below: job_role_gap)[")
    emit(out, "  #grid(columns: (1fr, auto), align: horizon,")
    emit(out, "    [" .. text_call(entry.role, "role_size", { weight = "bold" }) .. "],")
    emit(out, "    [" .. text_call(entry.dates, "meta_size", { weight = "bold", fill = "accent" }) .. "],")
    emit(out, "  )")
    emit(out, "]")
    local below = index < #entries and "education_entry_after" or "0mm"
    block_line(out, entry.organization, "meta_size", below, { fill = "muted" })
  end
  emit(out, "#v(section_after)")
end

local function render_publication_entry(out, pub, highlights, index)
  emit(out, "#block(below: publication_entry_gap)[")
  emit(out, "  #grid(columns: (4.5mm, 1fr), gutter: 1.1mm, align: top,")
  emit(out, "    [#text(size: pub_size, " .. q(tostring(index) .. ".") .. ")],")
  emit(out, "    [")
  emit(out, "      #set par(leading: publication_leading)")
  emit(out, "      " .. highlighted_text(pub.authors, highlights, "pub_size") .. text_call(". " .. value_text(pub.title) .. ". ", "pub_size"))

  if value_text(pub.status) ~= "" then
    emit(out, "      " .. text_call("(", "pub_size") .. text_call(pub.venue, "pub_size", { style = "italic" }) .. text_call(" ", "pub_size") .. text_call(pub.status, "pub_size", { weight = "bold", style = "italic" }) .. text_call(").", "pub_size"))
  else
    emit(out, "      " .. text_call(pub.venue, "pub_size", { style = "italic" }) .. text_call(". " .. value_text(pub.details) .. ".", "pub_size"))
  end

  emit(out, "    ],")
  emit(out, "  )")
  emit(out, "]")
end

local function render_publications(out, cv)
  local pubs = cv.publications or {}
  local highlights = pubs.highlight_authors

  emit(out, "#section_title(\"Publications\")")

  for _, section in ipairs(list(pubs.sections)) do
    block_line(out, section.title, "subsection_size", "publication_section_gap", { weight = "bold" })

    for index, pub in ipairs(list(section.entries)) do
      render_publication_entry(out, pub, highlights, index)
    end

    emit(out, "#v(0.9mm)")
  end

  for _, note in ipairs(list(pubs.notes)) do
    block_line(out, note, "note_size", "0.45mm", { weight = "bold" })
  end
end

local function render_additional_sections(out, cv)
  for _, section in ipairs(list(cv.additional_sections)) do
    emit(out, "#section_title(" .. q(section.title) .. ")")

    for _, entry in ipairs(list(section.entries)) do
      block_line(out, entry.title, "role_size", "additional_title_gap", { weight = "bold" })
      render_bullets(out, entry.bullets, "bullet_size", "additional_entry_gap")
    end

    emit(out, "#v(additional_section_after)")
  end
end

local function preamble(out, cv, theme)
  local colors = theme.colors or {}
  local typography = theme.typography or {}
  local page = theme.page or {}
  local header = theme.header or {}
  local photo = header.photo or {}
  local identity = header.identity or {}
  local profile = header.profile or {}
  local headings = theme.section_headings or {}
  local main = theme.main_column or {}
  local bullets = main.bullets or {}
  local sidebar = theme.sidebar or {}
  local chips = sidebar.chips or {}
  local second_page = theme.second_page or {}
  local publications = theme.publications or {}
  local additional = theme.additional_sections or {}
  local footer = theme.footer or {}

  local function color_expr(value, fallback)
    local color = value_text(value)
    if color == "" then
      return fallback
    end
    if color:match("^#%x%x%x%x%x%x$") or color:match("^#%x%x%x$") then
      return "rgb(" .. q(color) .. ")"
    end
    return color
  end

  emit(out, "#set document(title: " .. q((cv.person or {}).name) .. ")")
  emit(out, "#let page_w = " .. raw_value(page.width, "210mm"))
  emit(out, "#let page_h = " .. raw_value(page.height, "297mm"))
  emit(out, "#let header_h = " .. raw_value(header.height, "56mm"))
  emit(out, "#let sidebar_w = " .. raw_value(sidebar.panel_width, "76.9mm"))
  emit(out, "#let photo_x = " .. raw_value(photo.x, "2.4mm"))
  emit(out, "#let photo_y = " .. raw_value(photo.y, "6.9mm"))
  emit(out, "#let photo_w = " .. raw_value(photo.width, "51.3mm"))
  emit(out, "#let photo_h = " .. raw_value(photo.height, "42mm"))
  emit(out, "#let name_x = " .. raw_value(identity.name_x, "55mm"))
  emit(out, "#let name_y = " .. raw_value(identity.name_y, "16mm"))
  emit(out, "#let name_w = " .. raw_value(identity.name_width, "70mm"))
  emit(out, "#let contact_x = " .. raw_value(identity.contacts_x, "132.5mm"))
  emit(out, "#let contact_y = " .. raw_value(identity.contacts_y, "13.5mm"))
  emit(out, "#let contact_w = " .. raw_value(identity.contacts_width, "70mm"))
  emit(out, "#let contact_content_w = " .. raw_value(identity.contacts_content_width, "48mm"))
  emit(out, "#let header_profile_x = " .. raw_value(profile.x, "56.5mm"))
  emit(out, "#let header_profile_y = " .. raw_value(profile.y, "34mm"))
  emit(out, "#let header_profile_w = " .. raw_value(profile.width, "143.5mm"))
  emit(out, "#let sidebar_x = " .. raw_value(sidebar.content_x, "5.8mm"))
  emit(out, "#let sidebar_y = " .. raw_value(sidebar.content_y, "61mm"))
  emit(out, "#let sidebar_content_w = " .. raw_value(sidebar.content_width, "66.2mm"))
  emit(out, "#let main_x = " .. raw_value(main.x, "81.8mm"))
  emit(out, "#let main_y = " .. raw_value(main.y, "61mm"))
  emit(out, "#let main_w = " .. raw_value(main.width, "122.2mm"))
  emit(out, "#let page2_x = " .. raw_value(second_page.content_x, "11.5mm"))
  emit(out, "#let page2_top_y = " .. raw_value(second_page.content_y, "8mm"))
  emit(out, "#let page2_w = " .. raw_value(second_page.content_width, "187mm"))
  emit(out, "#set page(width: page_w, height: page_h, margin: 0mm)")
  emit(out, "#let theme_color = " .. color_expr(colors.theme, "rgb(\"#6F777A\")"))
  emit(out, "#let text_color = " .. color_expr(colors.text, "rgb(\"#101010\")"))
  emit(out, "#let muted = " .. color_expr(colors.muted, "theme_color.darken(18%)"))
  emit(out, "#let accent = " .. color_expr(colors.accent, "theme_color.darken(10%)"))
  emit(out, "#let panel = " .. color_expr(colors.panel, "theme_color.lighten(84%)"))
  emit(out, "#let white = " .. color_expr(colors.white, "rgb(\"#FFFFFF\")"))
  emit(out, "#let rule = " .. color_expr(colors.rule, "theme_color.lighten(62%)"))
  emit(out, "#let chip_fill = " .. color_expr(colors.chip_fill, "theme_color.lighten(94%)"))
  emit(out, "#let chip_border = " .. color_expr(colors.chip_border, "theme_color.lighten(58%)"))
  emit(out, "#let chip_text = " .. color_expr(colors.chip_text, "theme_color.darken(28%)"))
  emit(out, "#let tag_fill = " .. color_expr(colors.tag_fill, "theme_color.lighten(94%)"))
  emit(out, "#let tag_border = " .. color_expr(colors.tag_border, "theme_color.lighten(58%)"))
  emit(out, "#let tag_text = " .. color_expr(colors.tag_text, "theme_color.darken(28%)"))
  emit(out, "#let section_rule_width = " .. raw_value(headings.divider_width, "100%"))
  emit(out, "#let section_rule_thickness = " .. raw_value(headings.divider_thickness, "0.35pt"))
  emit(out, "#let section_rule_gap = " .. raw_value(headings.space_between_text_and_divider, "0.8mm"))
  emit(out, "#let section_size = " .. raw_value(headings.font_size, "12.4pt"))
  emit(out, "#let subsection_size = " .. raw_value(publications.subsection_font_size, "9.4pt"))
  emit(out, "#let role_size = " .. raw_value(main.role_font_size, "9.2pt"))
  emit(out, "#let meta_size = " .. raw_value(main.metadata_font_size, "8.1pt"))
  emit(out, "#let project_size = " .. raw_value(main.project_title_font_size, "8.35pt"))
  emit(out, "#let bullet_size = " .. raw_value(main.bullet_font_size, "7.8pt"))
  emit(out, "#let side_label_size = " .. raw_value(sidebar.label_font_size, "8.0pt"))
  emit(out, "#let side_meta_size = " .. raw_value(sidebar.detail_font_size, "7.2pt"))
  emit(out, "#let skill_size = " .. raw_value(chips.font_size, "8pt"))
  emit(out, "#let contact_size = " .. raw_value(identity.contacts_font_size, "7.9pt"))
  emit(out, "#let contact_row_after = " .. raw_value(identity.contact_row_space_after, "0.75mm"))
  emit(out, "#let header_profile_size = " .. raw_value(profile.font_size, "8.6pt"))
  emit(out, "#let pub_size = " .. raw_value(publications.entry_font_size, "8.0pt"))
  emit(out, "#let note_size = " .. raw_value(publications.note_font_size, "7.2pt"))
  emit(out, "#let footer_size = " .. raw_value(footer.font_size, "7.4pt"))
  emit(out, "#let footer_right_margin = " .. raw_value(footer.right_margin, "8mm"))
  emit(out, "#let footer_bottom_margin = " .. raw_value(footer.bottom_margin, "6mm"))
  emit(out, "#let name_size = " .. raw_value(identity.name_font_size, "17.5pt"))
  emit(out, "#let section_title_after = " .. raw_value(headings.space_after_heading, "2.5mm"))
  emit(out, "#let section_after = " .. raw_value(headings.space_between_sections, "4mm"))
  emit(out, "#let entry_after = " .. raw_value(main.entry_space_after, "2.6mm"))
  emit(out, "#let line_after = " .. raw_value(main.role_space_after, "0.85mm"))
  emit(out, "#let profile_leading = " .. raw_value(profile.line_spacing, "0.90em"))
  emit(out, "#let publication_leading = " .. raw_value(publications.line_spacing, "0.56em"))
  emit(out, "#let sidebar_section_after = " .. raw_value(sidebar.space_between_sections, "4mm"))
  emit(out, "#let timeline_title_gap = " .. raw_value(sidebar.timeline_title_space_after, "0.95mm"))
  emit(out, "#let timeline_entry_gap = " .. raw_value(sidebar.timeline_entry_space_after, "2.25mm"))
  emit(out, "#let skill_title_gap = " .. raw_value(sidebar.skill_group_title_space_after, "0.55mm"))
  emit(out, "#let skill_group_gap = " .. raw_value(sidebar.skill_group_space_after, "1.15mm"))
  emit(out, "#let list_item_gap = " .. raw_value(bullets.item_spacing, "1.15mm"))
  emit(out, "#let bullet_indent = " .. raw_value(bullets.marker_indent, "2.9mm"))
  emit(out, "#let bullet_body_indent = " .. raw_value(bullets.text_indent, "1.9mm"))
  emit(out, "#let job_role_gap = line_after")
  emit(out, "#let job_org_gap = " .. raw_value(main.organization_space_after, "2mm"))
  emit(out, "#let project_title_gap = " .. raw_value(main.project_title_space_after, "1.1mm"))
  emit(out, "#let project_after = " .. raw_value(main.project_space_after, "2.25mm"))
  emit(out, "#let education_entry_after = " .. raw_value(main.education_entry_space_after, "entry_after"))
  emit(out, "#let skill_chip_gap = " .. raw_value(chips.horizontal_gap, "0.8mm"))
  emit(out, "#let skill_chip_x = " .. raw_value(chips.padding_x, "0.8mm"))
  emit(out, "#let skill_chip_y = " .. raw_value(chips.padding_y, "0.22mm"))
  emit(out, "#let skill_chip_radius = " .. raw_value(chips.corner_radius, "0.7mm"))
  emit(out, "#let publication_section_gap = " .. raw_value(publications.subsection_space_after, "0.9mm"))
  emit(out, "#let publication_entry_gap = " .. raw_value(publications.entry_space_after, "1.2mm"))
  emit(out, "#let page2_content_gap = " .. raw_value(second_page.space_after_publications, "6mm"))
  emit(out, "#let additional_title_gap = " .. raw_value(additional.title_space_after, "0.55mm"))
  emit(out, "#let additional_entry_gap = " .. raw_value(additional.entry_space_after, "1.5mm"))
  emit(out, "#let additional_section_after = " .. raw_value(additional.section_space_after, "1.6mm"))
  emit(out, "#set text(font: " .. font_expr(typography.font, "Calibri") .. ", fill: text_color)")
  emit(out, "#set par(leading: " .. raw_value(typography.body_line_spacing, "0.80em") .. ", spacing: 0.0em)")
  emit(out, "#let section_title(title) = block(below: section_title_after)[")
  emit(out, "  #text(size: section_size, weight: \"bold\", fill: text_color, title)")
  emit(out, "  #v(section_rule_gap)")
  emit(out, "  #line(length: section_rule_width, stroke: rule + section_rule_thickness)")
  emit(out, "]")
  emit(out, "#let sidebar_title(title) = block(below: section_title_after)[")
  emit(out, "  #text(size: section_size, weight: \"bold\", fill: text_color, title)")
  emit(out, "  #v(section_rule_gap)")
  emit(out, "  #line(length: section_rule_width, stroke: rule + section_rule_thickness)")
  emit(out, "]")
  emit(out, "#let skill_item(label) = box(inset: (x: skill_chip_x, y: skill_chip_y), radius: skill_chip_radius, fill: chip_fill, stroke: chip_border + 0.2pt)[")
  emit(out, "  #text(size: skill_size, weight: \"regular\", fill: chip_text, label)")
  emit(out, "]")
  emit(out, "#let language_tag(label) = box(inset: (x: skill_chip_x, y: skill_chip_y), radius: skill_chip_radius, fill: tag_fill, stroke: tag_border + 0.2pt)[")
  emit(out, "  #text(size: skill_size, weight: \"regular\", fill: tag_text, label)")
  emit(out, "]")
  emit(out, "#let header_contact_item(icon_path, label, url) = grid(columns: (5.6mm, 1.8mm, 1fr), align: left + horizon,")
  emit(out, "  [#box(width: 5.6mm, height: 5.6mm, radius: 1.3mm, fill: white, stroke: rule + 0.3pt)[#align(center + horizon)[#image(icon_path, width: 3.5mm)]]],")
  emit(out, "  [],")
  emit(out, "  [#align(horizon)[#if url == \"\" {")
  emit(out, "    text(size: contact_size, fill: muted, label)")
  emit(out, "  } else {")
  emit(out, "    link(url)[#text(size: contact_size, fill: accent, label)]")
  emit(out, "  }]],")
  emit(out, ")")
  emit(out, "#let page_footer(label, right_margin: footer_right_margin) = place(top + left, dx: 0mm, dy: page_h - footer_bottom_margin - footer_size)[")
  emit(out, "  #box(width: page_w - right_margin)[#align(right)[#text(size: footer_size, fill: muted, label)]]")
  emit(out, "]")
end

local function render_first_page(out, cv)
  local person = cv.person or {}
  local assets = cv.assets or {}

  emit(out, "#page()[")
  emit(out, "  #place(top + left)[#rect(width: page_w, height: header_h, fill: panel, stroke: none)]")
  emit(out, "  #place(top + left)[#rect(width: sidebar_w, height: page_h, fill: panel, stroke: none)]")
  emit(out, "  #place(top + left, dx: sidebar_w, dy: header_h)[#rect(width: page_w - sidebar_w, height: page_h - header_h, fill: white, stroke: none)]")
  emit(out, "  #place(top + left, dx: photo_x, dy: photo_y)[")
  emit(out, "    #box(width: photo_w, height: photo_h, radius: 50%, clip: true)[")
  emit(out, "      #image(" .. q(assets.photo) .. ", width: photo_w, height: photo_h, fit: \"cover\")")
  emit(out, "    ]")
  emit(out, "  ]")

  emit(out, "  #place(top + left, dx: name_x, dy: name_y)[")
  emit(out, "    #box(width: name_w)[")
  emit(out, "      #align(left)[#text(size: name_size, weight: \"bold\", " .. q(person.name) .. ")]")
  emit(out, "    ]")
  emit(out, "  ]")

  emit(out, "  #place(top + left, dx: contact_x, dy: contact_y)[")
  emit(out, "    #box(width: contact_w)[")
  render_header_contact_row(out, cv.contact)
  emit(out, "    ]")
  emit(out, "  ]")

  emit(out, "  #place(top + left, dx: header_profile_x, dy: header_profile_y)[")
  emit(out, "    #box(width: header_profile_w)[")
  emit(out, "      #set par(justify: false, leading: profile_leading)")
  emit(out, "      #set text(hyphenate: false)")
  emit(out, "      #text(size: header_profile_size, fill: muted, " .. q(cv.profile) .. ")")
  emit(out, "    ]")
  emit(out, "  ]")

  emit(out, "  #place(top + left, dx: sidebar_x, dy: sidebar_y)[")
  emit(out, "    #box(width: sidebar_content_w)[")
  for _, section in ipairs(list(cv.sidebar)) do
    render_sidebar_section(out, section)
  end
  emit(out, "    ]")
  emit(out, "  ]")

  emit(out, "  #place(top + left, dx: main_x, dy: main_y)[")
  emit(out, "    #box(width: main_w)[")
  render_education(out, cv)
  render_experience(out, cv)
  emit(out, "    ]")
  emit(out, "  ]")
  emit(out, "  #page_footer(" .. q(value_text(person.name) .. " · 1 / 2") .. ")")
  emit(out, "]")
end

local function render_second_page(out, cv)
  emit(out, "#page()[")
  emit(out, "  #page_footer(" .. q(value_text((cv.person or {}).name) .. " · 2 / 2") .. ", right_margin: page_w - page2_x - page2_w)")
  emit(out, "  #place(top + left, dx: page2_x, dy: page2_top_y)[")
  emit(out, "    #box(width: page2_w)[")
  render_publications(out, cv)
  emit(out, "      #v(page2_content_gap)")
  render_additional_sections(out, cv)
  emit(out, "    ]")
  emit(out, "  ]")
  emit(out, "]")
end

function Pandoc(doc)
  local cv = doc.meta.cv
  local theme = doc.meta.cv_theme or {}
  if cv == nil then
    error("Missing `cv` data. Edit cv.yml or set metadata-files to a file containing a top-level `cv:` key.")
  end

  local out = {}
  preamble(out, cv, theme)
  render_first_page(out, cv)
  render_second_page(out, cv)

  doc.blocks = { pandoc.RawBlock("typst", table.concat(out, "\n")) }
  return doc
end
