local function str(value)
  return value == nil and "" or pandoc.utils.stringify(value)
end

local function esc(value)
  return (str(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&#39;"))
end

local function items(value)
  return type(value) == "table" and value or {}
end

local function tag(name, content, attrs)
  return "<" .. name .. (attrs or "") .. ">" .. content .. "</" .. name .. ">"
end

local function text(name, value, attrs)
  return tag(name, esc(value), attrs)
end

local function bullets(values)
  local out = {}
  for _, value in ipairs(items(values)) do
    table.insert(out, text("li", value))
  end
  return #out > 0 and tag("ul", table.concat(out)) or ""
end

local function chips(values)
  local out = {}
  for _, value in ipairs(items(values)) do
    table.insert(out, text("li", value))
  end
  return tag("ul", table.concat(out), ' class="cv-chips"')
end

local function section(title, content)
  return tag("section", text("h2", title) .. content, ' class="cv-section"')
end

local function entry_header(entry)
  return tag("div", text("h3", entry.role) .. text("span", entry.dates, ' class="cv-dates"'), ' class="cv-entry-heading"')
    .. text("p", entry.organization, ' class="cv-meta"')
end

local function authors(value, highlights)
  local source = str(value)
  local result, pos = {}, 1
  while pos <= #source do
    local first, marker
    for _, highlight in ipairs(items(highlights)) do
      local candidate = str(highlight)
      local at = candidate ~= "" and source:find(candidate, pos, true) or nil
      if at and (not first or at < first or (at == first and #candidate > #marker)) then
        first, marker = at, candidate
      end
    end
    if not first then
      table.insert(result, esc(source:sub(pos)))
      break
    end
    table.insert(result, esc(source:sub(pos, first - 1)))
    table.insert(result, text("strong", marker))
    pos = first + #marker
  end
  return table.concat(result)
end

function Pandoc(doc)
  local cv = doc.meta.cv
  if not cv then error("Missing `cv` data. Add cv.yml to metadata-files.") end
  local theme = doc.meta.cv_theme or {}
  local colors = theme.colors or {}
  local styles = {}
  -- Only accept literal hex colors in inline CSS; Typst formulas use CSS defaults.
  for _, pair in ipairs({{"theme", "--cv-theme"}, {"text", "--cv-text"}, {"panel", "--cv-panel"}, {"muted", "--cv-muted"}, {"rule", "--cv-rule"}}) do
    local value = str(colors[pair[1]])
    if value:match("^#%x%x%x%x%x%x$") or value:match("^#%x%x%x$") then
      table.insert(styles, pair[2] .. ":" .. value)
    end
  end
  local person = cv.person or {}
  local header = {}
  if str((cv.assets or {}).photo) ~= "" then
    table.insert(header, '<img class="cv-photo" src="' .. esc(cv.assets.photo) .. '" alt="Portrait of ' .. esc(person.name) .. '">')
  end
  local identity = text("h1", person.name)
  local contacts = {}
  for _, contact in ipairs(items(cv.contact)) do
    local label = esc(contact.label)
    if str(contact.url) ~= "" then
      label = tag("a", label, ' href="' .. esc(contact.url) .. '"')
    end
    local icon = str(contact.icon) ~= "" and '<img src="' .. esc(contact.icon) .. '" alt="" aria-hidden="true">' or ""
    table.insert(contacts, tag("li", icon .. label))
  end
  identity = identity .. tag("ul", table.concat(contacts), ' class="cv-contacts"')
  table.insert(header, tag("div", identity, ' class="cv-identity"'))
  table.insert(header, text("p", cv.profile, ' class="cv-profile"'))

  local sidebar = {}
  for _, s in ipairs(items(cv.sidebar)) do
    local content = {}
    if str(s.type) == "skills" then
      for _, group in ipairs(items(s.groups)) do
        table.insert(content, text("h3", group.title) .. chips(group.items))
      end
    elseif str(s.type) == "tags" then
      table.insert(content, chips(s.items))
    elseif str(s.type) == "text" then
      table.insert(content, text("p", s.text))
    elseif str(s.type) == "timeline" then
      for _, entry in ipairs(items(s.entries)) do
        table.insert(content, tag("div", text("h3", entry.title) .. text("p", entry.detail, ' class="cv-meta"'), ' class="cv-entry"'))
      end
    end
    table.insert(sidebar, section(s.title, table.concat(content)))
  end

  local main = {}
  local education = {}
  for _, entry in ipairs(items(cv.education)) do
    table.insert(education, tag("div", entry_header(entry), ' class="cv-entry"'))
  end
  if #education > 0 then table.insert(main, section("Education", table.concat(education))) end
  local experience = {}
  for _, job in ipairs(items(cv.experience)) do
    local content = entry_header(job)
    for _, project in ipairs(items(job.projects)) do
      content = content .. tag("div", text("h4", project.title) .. bullets(project.bullets), ' class="cv-project"')
    end
    table.insert(experience, tag("article", content, ' class="cv-entry"'))
  end
  if #experience > 0 then table.insert(main, section("Research Experience", table.concat(experience))) end

  local lower, pubs_content = {}, {}
  local pubs = cv.publications or {}
  for _, s in ipairs(items(pubs.sections)) do
    local entries = {}
    for _, pub in ipairs(items(s.entries)) do
      local content = authors(pub.authors, pubs.highlight_authors) .. ". " .. esc(pub.title) .. ". "
      if str(pub.status) ~= "" then
        content = content .. "(" .. text("em", pub.venue) .. " " .. tag("strong", text("em", pub.status)) .. ")."
      else
        content = content .. text("em", pub.venue) .. ". " .. esc(pub.details) .. "."
      end
      table.insert(entries, tag("li", content))
    end
    table.insert(pubs_content, text("h3", s.title) .. tag("ol", table.concat(entries), ' class="cv-publications"'))
  end
  for _, note in ipairs(items(pubs.notes)) do
    table.insert(pubs_content, text("p", note, ' class="cv-note"'))
  end
  if #pubs_content > 0 then table.insert(lower, section("Publications", table.concat(pubs_content))) end
  for _, s in ipairs(items(cv.additional_sections)) do
    local entries = {}
    for _, entry in ipairs(items(s.entries)) do
      table.insert(entries, tag("div", text("h3", entry.title) .. bullets(entry.bullets), ' class="cv-entry"'))
    end
    table.insert(lower, section(s.title, table.concat(entries)))
  end

  local content = tag("header", table.concat(header), ' class="cv-header"')
    .. tag("div", tag("aside", table.concat(sidebar), ' class="cv-sidebar" aria-label="Skills and additional information"')
    .. tag("div", table.concat(main), ' class="cv-main"'), ' class="cv-columns"')
    .. tag("div", table.concat(lower), ' class="cv-lower"')
  doc.blocks = {pandoc.RawBlock("html", tag("article", content, ' class="research-cv" style="' .. table.concat(styles, ";") .. '"'))}
  doc.meta.pagetitle = person.name
  doc.meta.title = nil
  return doc
end
