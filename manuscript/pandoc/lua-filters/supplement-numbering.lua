-- Number the figures and tables of the online supplement as S1, S2, ...
--
-- bookdown (word_document2) writes consecutive numbers into the markdown
-- ("Figure 3: ...", `<a href="#fig:id">3</a>`). Everything after the
-- heading "Online Supplementary Material" is renumbered here instead,
-- separately for figures and tables, and cross-references to these
-- captions follow. Captions before the supplement are left alone.
--
-- Only useful for docx output: bookdown's HTML output resolves its
-- numbers after pandoc, so the filter finds nothing to change there.

local SUPPLEMENT_ID = "online-supplementary-material"

local in_supplement = false
local counter = { fig = 0, tab = 0 }
local number = {} -- caption id ("fig:x") -> "S1"

-- inlines: Span(id = "fig:x"), Str "Figure", Space, Str "3:", ...
local function renumber(inlines)
  local span, word, num = inlines[1], inlines[2], inlines[4]
  if not (span and span.t == "Span" and word and word.t == "Str"
      and num and num.t == "Str") then
    return
  end
  local kind = span.identifier:match("^(%a+):")
  if not counter[kind] or not num.text:match("^%d+:$") then
    return
  end
  counter[kind] = counter[kind] + 1
  number[span.identifier] = "S" .. counter[kind]
  inlines[4] = pandoc.Str(number[span.identifier] .. ":")
end

local function number_captions()
  return {
    traverse = "topdown",
    Header = function(h)
      if h.identifier == SUPPLEMENT_ID then
        in_supplement = true
      end
    end,
    Image = function(img)
      if in_supplement then
        renumber(img.caption)
        return img
      end
    end,
    Table = function(tbl)
      local long = tbl.caption.long
      if in_supplement and #long > 0 and long[1].content then
        renumber(long[1].content)
        return tbl
      end
    end,
  }
end

local function follow_references()
  return {
    -- bookdown writes references as raw html: <a href="#fig:x">7</a>
    Inlines = function(inlines)
      local changed = false
      for i = 1, #inlines - 2 do
        local open, num, close = inlines[i], inlines[i + 1], inlines[i + 2]
        if open.t == "RawInline" and open.format == "html"
            and num.t == "Str"
            and close.t == "RawInline" and close.text == "</a>" then
          local id = open.text:match('^<a href="#([^"]+)">$')
          if id and number[id] then
            inlines[i + 1] = pandoc.Str(number[id])
            changed = true
          end
        end
      end
      if changed then
        return inlines
      end
    end,
    -- ... or a proper link, should the reader ever produce one
    Link = function(link)
      local id = link.target:match("^#(.+)$")
      if id and number[id] then
        link.content = { pandoc.Str(number[id]) }
        return link
      end
    end,
  }
end

-- the filters run one after the other: first number all captions,
-- then rewrite the links that point to them
return { number_captions(), follow_references() }
