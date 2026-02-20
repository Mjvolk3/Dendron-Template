-- Remove syntax highlighting from code blocks that contain very long lines.
--
-- fvextra's breakanywhere cannot insert break points inside command arguments
-- (e.g., \StringTok{MIRTML...protein_sequence...}). With commandchars enabled,
-- the entire token argument is non-breakable regardless of length.
--
-- Removing the language class makes pandoc emit plain Verbatim text where
-- fvextra can break at any character. Only affects blocks that would overflow.

local MAX_LINE_LENGTH = 100

function CodeBlock(el)
  for line in el.text:gmatch("[^\n]*") do
    if #line > MAX_LINE_LENGTH then
      el.classes = {}
      el.attributes = {}
      return el
    end
  end
end
