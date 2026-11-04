--[[
affiliation-blocks – generate title components

Copyright © 2017–2021 Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
]]
local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local stringify = utils.stringify

local default_marks
local default_marks = {
  equal_contributor = FORMAT == 'latex'
    and {pandoc.RawInline('latex', '$\\dagger{}$')}
    or {pandoc.Str '*'},
  study_group = FORMAT == 'latex'
    and {pandoc.RawInline('latex', '\\#')}
    or {pandoc.Str '#'},
}

local function intercalate(lists, elem)
  local result = List:new{}
  for i = 1, (#lists - 1) do
    result:extend(lists[i])
    result:extend(elem)
  end
  if #lists > 0 then
    result:extend(lists[#lists])
  end
  return result
end

--- Check whether the given author is a corresponding author
local function is_corresponding_author(author)
  return author.correspondence and author.email
end

--- Create the superscript with all notes (affiliations etc.) of an author
local function author_marks_superscript (author, get_mark)
  local author_marks = List:new{}
  if author.equal_contributor then
    author_marks[#author_marks + 1] = get_mark 'equal_contributor'
  end
  local idx_str
  for _, idx in ipairs(author.institute) do
    if type(idx) ~= 'table' then
      idx_str = tostring(idx)
    else
      idx_str = stringify(idx)
    end
    author_marks[#author_marks + 1] = {pandoc.Str(idx_str)}
  end
  return pandoc.Superscript(intercalate(author_marks, {pandoc.Str ','}))
end

local function is_equal_contributor (author)
  return author.equal_contributor
end

--- Create equal contributors note.
local function create_equal_contributors_block(authors, mark)
  local has_equal_contribs = List:new(authors):find_if(is_equal_contributor)
  if not has_equal_contribs then
    return nil
  end
  local contributors = {
    pandoc.Superscript(mark'equal_contributor'),
    pandoc.Space(),
    pandoc.Str 'These authors contributed equally to this work.'
  }
  return List:new{pandoc.Para(contributors)}
end

--- Generate a block list all affiliations, marked with arabic numbers.
local function create_affiliations_blocks(affiliations)
  local affil_lines = List:new(affiliations):map(
    function (affil, i)
      local num_inlines = List:new{
        pandoc.Superscript{pandoc.Str(tostring(i))},
        pandoc.Space()
      }
      return num_inlines .. affil.name
    end
                                                )
  return {pandoc.Para(intercalate(affil_lines, {pandoc.LineBreak()}))}
end

--- Generate the address block of the corresponding author(s):
--- name, affiliation(s) and email, one item per line.
local function create_correspondence_blocks(authors, institutes)
  local blocks = List:new{}
  for _, author in ipairs(authors) do
    if is_corresponding_author(author) then
      local lines = List:new{List.clone(author.name)}
      for _, idx in ipairs(author.institute) do
        local i = tonumber(stringify(idx))
        lines:insert(List.clone(institutes[i].name))
      end
      local email = stringify(author.email)
      lines:insert(List:new{pandoc.Str 'Email:', pandoc.Space(),
                            pandoc.Link(email, 'mailto:' .. email)})
      blocks:insert(pandoc.Para(intercalate(lines, {pandoc.LineBreak()})))
    end
  end
  if #blocks == 0 then
    return nil
  end
  return blocks
end

--- Return the study group name; `study_group` is either the name itself
--- or a map with `name` (and `members`, which are rendered elsewhere).
local function study_group_name(study_group)
  if study_group and study_group.name then
    return study_group.name
  end
  return study_group
end

--- Generate a block element noting where the study group members are listed.
local function create_study_group_block(study_group, mark)
  if not study_group then
    return nil
  end
  local note = List:new{
    pandoc.Superscript(mark 'study_group'),
    pandoc.Space(),
    pandoc.Str 'The members of the',
    pandoc.Space(),
  }
  note:extend(study_group)
  note:extend(List:new{pandoc.Space(), pandoc.Str 'are listed in the Appendix.'})
  return {pandoc.Para(note)}
end

--- Generate a list of inlines containing all authors (and the study group),
--- formatted as "A,1 B2 and C3": the comma precedes the superscript and
--- there is no comma before "and".
local function create_authors_inlines(authors, mark, study_group)
  local items = List:new(authors):map(function (author)
    return {name = author.name, marks = author_marks_superscript(author, mark)}
  end)
  if study_group then
    items:insert{
      name = List:new{pandoc.Str 'the', pandoc.Space()} .. study_group,
      marks = pandoc.Superscript(mark 'study_group')
    }
  end

  local result = List:new{}
  for i, item in ipairs(items) do
    result:extend(item.name)
    if i < #items - 1 then
      result:extend{pandoc.Str ',', item.marks, pandoc.Space()}
    elseif i == #items - 1 then
      result:extend{item.marks, pandoc.Space(), pandoc.Str 'and', pandoc.Space()}
    else
      result:insert(item.marks)
    end
  end
  return result
end

--- Level-1 sections that do not belong to the main text
--- (journals count words excluding summary, declarations, references and
--- supplementary material).
local non_main_sections = {
  ['summary'] = true,
  ['declarations'] = true,
  ['references'] = true,
  ['online supplementary material'] = true,
}

--- Count words, tables and figures of the main text. Tables and figures are
--- identified by their bookdown labels "(#tab:...)" and "(#fig:...)";
--- table and figure blocks (incl. captions) are not counted as words.
local function count_main_text(blocks)
  local counts = {words = 0, tables = 0, figures = 0}
  local in_main = false
  local count_labels = {
    Str = function (el)
      if el.text:match '^%(#tab:' then counts.tables = counts.tables + 1 end
      if el.text:match '^%(#fig:' then counts.figures = counts.figures + 1 end
    end
  }
  local count_words = {
    Str = function (el)
      -- we don't count a word if it's entirely punctuation:
      if el.text:match '%P' then counts.words = counts.words + 1 end
    end
  }
  for _, blk in ipairs(blocks) do
    if blk.t == 'Header' and blk.level == 1 then
      in_main = not non_main_sections[stringify(blk.content):lower()]
    end
    if in_main then
      pandoc.walk_block(blk, count_labels)
      local is_float = blk.t == 'Table' or blk.t == 'Figure' or
        (blk.t == 'Para' and #blk.content == 1 and blk.content[1].t == 'Image')
      if not is_float then
        pandoc.walk_block(blk, count_words)
      end
    end
  end
  return counts
end

--- Return metadata as inlines; folded YAML scalars (`>`) arrive as blocks.
local function meta_inlines(value)
  if value[1] and (value[1].t == 'Para' or value[1].t == 'Plain') then
    return utils.blocks_to_inlines(value)
  end
  return List.clone(value)
end

--- Create a paragraph "<label>: <inlines>" with a bold label.
local function labelled_para(label, inlines)
  return pandoc.Para(
    List:new{pandoc.Strong{pandoc.Str(label .. ':')}, pandoc.Space()} .. inlines
  )
end

--- Generate the title page (layout as in our earlier submissions):
--- labelled fields for title, short title, authors with affiliations,
--- corresponding author, counts of the main text and keywords.
local function create_title_page(doc, mark)
  local meta = doc.meta
  local study_group = study_group_name(meta.study_group)
  local counts = count_main_text(doc.blocks)
  local blocks = List:new{
    pandoc.Header(1, 'Title page', pandoc.Attr('title-page', {'unnumbered'}))
  }

  blocks:insert(labelled_para('Title', meta_inlines(meta.title)))
  if meta.shorttitle then
    blocks:insert(labelled_para('Short title', meta_inlines(meta.shorttitle)))
  end
  blocks:insert(labelled_para(
    'Authors', create_authors_inlines(meta.author, mark, study_group)
  ))
  local affiliations = List:new{}
  affiliations:extend(create_equal_contributors_block(meta.author, mark) or {})
  affiliations:extend(create_affiliations_blocks(meta.institute) or {})
  affiliations:extend(create_study_group_block(study_group, mark) or {})
  blocks:insert(pandoc.BlockQuote(affiliations))

  local correspondence = create_correspondence_blocks(meta.author, meta.institute)
  if correspondence then
    blocks:insert(pandoc.Para{pandoc.Strong{pandoc.Str 'Address of corresponding author:'}})
    blocks:insert(pandoc.BlockQuote(correspondence))
  end

  blocks:insert(labelled_para('Article Word Count', {pandoc.Str(tostring(counts.words))}))
  blocks:insert(labelled_para('Tables', {pandoc.Str(tostring(counts.tables))}))
  blocks:insert(labelled_para('Figures', {pandoc.Str(tostring(counts.figures))}))
  if meta.keywords then
    local kw = List:new(meta.keywords):map(stringify)
    blocks:insert(labelled_para('Keywords', {pandoc.Str(table.concat(kw, '; '))}))
  end
  return blocks
end

return {
  {
    Pandoc = function (doc)
      local meta = doc.meta
      local mark = function (mark_name) return default_marks[mark_name] end

      local body = create_title_page(doc, mark)
      body:extend(doc.blocks)

      -- The title page replaces the title block of the output template.
      meta.pagetitle = stringify(meta.title)
      meta['title-meta'] = stringify(meta.title)
      meta.title = nil
      meta.author = nil
      meta.study_group = nil
      meta.institute = nil

      return pandoc.Pandoc(body, meta)
    end
  }
}
