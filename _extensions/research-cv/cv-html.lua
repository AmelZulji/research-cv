-- The web page displays the PDF produced by the same renderer as the PDF format.
local renderer = dofile(pandoc.path.join({pandoc.path.directory(PANDOC_SCRIPT_FILE), "cv.lua"}))
local render_typst = renderer[1].Pandoc

local function esc(value)
  return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

function Pandoc(doc)
  local input = quarto.doc.input_file
  local stem = input:gsub("%.[^./]+$", "")
  local typst_path, pdf_path = stem .. ".typ", stem .. ".pdf"
  local rendered = render_typst(doc)
  local file = assert(io.open(typst_path, "w"))
  file:write(rendered.blocks[1].text)
  file:close()
  -- Compile directly rather than starting another Quarto render. This also
  -- uses the current document metadata, including command-line overrides.
  local ok, result = pcall(pandoc.pipe, "quarto", {
    "typst", "compile", typst_path, pdf_path,
    "--root", quarto.project.directory or pandoc.path.directory(input),
  }, "")
  if not ok then error("Could not build the CV PDF: " .. tostring(result)) end
  quarto.doc.add_resource(pdf_path)

  local filename = pandoc.path.filename(pdf_path)
  local url = filename:gsub("([^%w%-._~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  local person = (doc.meta.cv or {}).person or {}
  local name = pandoc.utils.stringify(person.name or "Curriculum Vitae")
  doc.meta.pagetitle = name
  doc.meta.title = nil
  doc.blocks = {pandoc.RawBlock("html", [[
<main class="cv-viewer">
  <nav aria-label="Document actions"><span>]] .. esc(name) .. [[</span>
    <a href="]] .. esc(url) .. [[" target="_blank" rel="noopener">Open PDF</a>
    <a href="]] .. esc(url) .. [[" download>Download PDF</a>
  </nav>
  <object data-external="1" data="]] .. esc(url) .. [[#view=FitH" type="application/pdf" aria-label="]] .. esc(name) .. [[ CV">
    <p>Your browser cannot display this PDF inline. <a href="]] .. esc(url) .. [[">Open the CV PDF</a>.</p>
  </object>
</main>]])}
  return doc
end
