-- spellchecker:off
return {
  ex_search_commands = {
    substitute = true,
    global = true,
    vglobal = true,
    vimgrep = true,
    vimgrepadd = true,
    grep = true,
    grepadd = true,
    lvimgrep = true,
    lvimgrepadd = true,
  },
  modifiers = {
    p = 'full path',
    h = 'directory (head)',
    t = 'filename (tail)',
    r = 'basename (root, no ext)',
    e = 'extension',
    s = 'substitute first occurrence',
    gs = 'substitute all occurrences',
    S = 'escape for shell',
    ['~'] = 'relative to home directory',
    ['.'] = 'relative to current directory',
  },
  completion_types = {
    buffer = { 'buffer', 'diff_buffer' },
    path = { 'dir', 'dir_in_path', 'file', 'file_in_path', 'runtime' },
  },
  range_address_patterns = {
    -- Numeric/offsets
    '%d+[+-]?%d*', -- 1, 5+4, 5-4
    '[+-]%d+', -- +5, -5
    -- Special
    '[.$][+-]?%d*', -- ., $, .+2, $-1
    -- Marks
    "'[a-zA-Z0-9][+-]?%d*",
    "'%[[+-]?%d*",
    "'%][+-]?%d*",
    "''[+-]?%d*",
    '\'"[+-]?%d*',
    "'%^[+-]?%d*",
    "'%.[+-]?%d*",
    "'%([+-]?%d*",
    "'%)[+-]?%d*",
    "'{[+-]?%d*",
    "'}[+-]?%d*",
    "'<[+-]?%d*",
    "'>[+-]?%d*",
    -- Previous search/substitute
    '\\/[+-]?%d*',
    '\\%?[+-]?%d*',
    '\\&[+-]?%d*',
    -- Forward/backward search
    '/[^/]*/[+-]?%d*',
    '%?[^%?]*%?[+-]?%d*',
  },
}
-- spellchecker:on
