-- Theme defaults for the single Typst CV renderer.
local M = {}
local function str(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end
local settings = {
  {"page_w", "page.width", "210mm"},
  {"page_h", "page.height", "297mm"},
  {"header_h", "header.height", "56mm"},
  {"sidebar_w", "sidebar.panel_width", "76.9mm"},
  {"photo_x", "header.photo.x", "2.4mm"},
  {"photo_y", "header.photo.y", "6.9mm"},
  {"photo_w", "header.photo.width", "51.3mm"},
  {"photo_h", "header.photo.height", "42mm"},
  {"name_x", "header.identity.name_x", "55mm"},
  {"name_y", "header.identity.name_y", "16mm"},
  {"name_w", "header.identity.name_width", "70mm"},
  {"contact_x", "header.identity.contacts_x", "132.5mm"},
  {"contact_y", "header.identity.contacts_y", "13.5mm"},
  {"contact_w", "header.identity.contacts_width", "70mm"},
  {"contact_content_w", "header.identity.contacts_content_width", "48mm"},
  {"header_profile_x", "header.profile.x", "56.5mm"},
  {"header_profile_y", "header.profile.y", "34mm"},
  {"header_profile_w", "header.profile.width", "143.5mm"},
  {"sidebar_x", "sidebar.content_x", "5.8mm"},
  {"sidebar_y", "sidebar.content_y", "61mm"},
  {"sidebar_content_w", "sidebar.content_width", "66.2mm"},
  {"main_x", "main_column.x", "81.8mm"},
  {"main_y", "main_column.y", "61mm"},
  {"main_w", "main_column.width", "122.2mm"},
  {"page2_x", "second_page.content_x", "11.5mm"},
  {"page2_top_y", "second_page.content_y", "8mm"},
  {"page2_w", "second_page.content_width", "187mm"},
  {"section_rule_width", "section_headings.divider_width", "100%"},
  {"section_rule_thickness", "section_headings.divider_thickness", "0.35pt"},
  {"section_rule_gap", "section_headings.space_between_text_and_divider", "0.8mm"},
  {"section_size", "section_headings.font_size", "12.4pt"},
  {"subsection_size", "publications.subsection_font_size", "9.4pt"},
  {"role_size", "main_column.role_font_size", "9.2pt"},
  {"meta_size", "main_column.metadata_font_size", "8.1pt"},
  {"project_size", "main_column.project_title_font_size", "8.35pt"},
  {"bullet_size", "main_column.bullet_font_size", "7.8pt"},
  {"side_label_size", "sidebar.label_font_size", "8.0pt"},
  {"side_meta_size", "sidebar.detail_font_size", "7.2pt"},
  {"skill_size", "sidebar.chips.font_size", "8pt"},
  {"contact_size", "header.identity.contacts_font_size", "7.9pt"},
  {"contact_row_after", "header.identity.contact_row_space_after", "0.75mm"},
  {"header_profile_size", "header.profile.font_size", "8.6pt"},
  {"pub_size", "publications.entry_font_size", "8.0pt"},
  {"note_size", "publications.note_font_size", "7.2pt"},
  {"footer_size", "footer.font_size", "7.4pt"},
  {"footer_right_margin", "footer.right_margin", "8mm"},
  {"footer_bottom_margin", "footer.bottom_margin", "6mm"},
  {"name_size", "header.identity.name_font_size", "17.5pt"},
  {"section_title_after", "section_headings.space_after_heading", "2.5mm"},
  {"section_after", "section_headings.space_between_sections", "4mm"},
  {"entry_after", "main_column.entry_space_after", "2.6mm"},
  {"line_after", "main_column.role_space_after", "0.85mm"},
  {"profile_leading", "header.profile.line_spacing", "0.90em"},
  {"publication_leading", "publications.line_spacing", "0.56em"},
  {"sidebar_section_after", "sidebar.space_between_sections", "4mm"},
  {"timeline_title_gap", "sidebar.timeline_title_space_after", "0.95mm"},
  {"timeline_entry_gap", "sidebar.timeline_entry_space_after", "2.25mm"},
  {"skill_title_gap", "sidebar.skill_group_title_space_after", "0.55mm"},
  {"skill_group_gap", "sidebar.skill_group_space_after", "1.15mm"},
  {"list_item_gap", "main_column.bullets.item_spacing", "1.15mm"},
  {"bullet_indent", "main_column.bullets.marker_indent", "2.9mm"},
  {"bullet_body_indent", "main_column.bullets.text_indent", "1.9mm"},
  {"job_org_gap", "main_column.organization_space_after", "2mm"},
  {"project_title_gap", "main_column.project_title_space_after", "1.1mm"},
  {"project_after", "main_column.project_space_after", "2.25mm"},
  {"education_entry_after", "main_column.education_entry_space_after", "entry_after"},
  {"skill_chip_gap", "sidebar.chips.horizontal_gap", "0.8mm"},
  {"skill_chip_x", "sidebar.chips.padding_x", "0.8mm"},
  {"skill_chip_y", "sidebar.chips.padding_y", "0.22mm"},
  {"skill_chip_radius", "sidebar.chips.corner_radius", "0.7mm"},
  {"publication_section_gap", "publications.subsection_space_after", "0.9mm"},
  {"publication_entry_gap", "publications.entry_space_after", "1.2mm"},
  {"page2_content_gap", "second_page.space_after_publications", "6mm"},
  {"additional_title_gap", "additional_sections.title_space_after", "0.55mm"},
  {"additional_entry_gap", "additional_sections.entry_space_after", "1.5mm"},
  {"additional_section_after", "additional_sections.section_space_after", "1.6mm"},
  {"body_leading", "typography.body_line_spacing", "0.80em"},
}
function M.values(theme)
  local result = {}
  for _, setting in ipairs(settings) do
    local value = theme
    for key in setting[2]:gmatch("[^.]+") do
      value = type(value) == "table" and value[key] or nil
    end
    result[setting[1]] = str(value) ~= "" and str(value) or setting[3]
  end
  return result
end
local palette = {
  theme = "#6F777A", text = "#101010", white = "#FFFFFF",
  muted = "theme_color.darken(18%)", accent = "theme_color.darken(10%)",
  panel = "theme_color.lighten(84%)", rule = "theme_color.lighten(62%)",
  chip_fill = "theme_color.lighten(94%)", chip_border = "theme_color.lighten(58%)",
  chip_text = "theme_color.darken(28%)", tag_fill = "theme_color.lighten(94%)",
  tag_border = "theme_color.lighten(58%)", tag_text = "theme_color.darken(28%)",
}
function M.colors(theme)
  local result = {}
  for key, fallback in pairs(palette) do
    local value = str((theme.colors or {})[key])
    result[key] = value ~= "" and value or fallback
  end
  return result
end
function M.fonts(theme)
  return (theme.typography or {}).font or {"Calibri"}
end
return M
