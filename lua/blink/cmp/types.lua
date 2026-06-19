--- @alias blink.cmp.Mode 'cmdline' | 'cmdwin' | 'term' | 'default'

--- @alias blink.cmp.CursorPos { [1]: integer, [2]: integer }

--- @class blink.cmp.CompletionItem : lsp.CompletionItem
--- @field documentation? string | { kind: lsp.MarkupKind, value: string, draw?: fun(opts?: blink.cmp.CompletionDocumentationDrawOpts) }
--- @field score_offset? integer
--- @field source_id string
--- @field source_name string
--- @field cursor_column integer
--- @field client_id? integer
--- @field client_name? string
--- @field kind_name? string
--- @field kind_icon? string
--- @field kind_hl? string
--- @field exact? boolean
--- @field score? integer

return {
  -- some plugins mutate the vim.lsp.protocol.CompletionItemKind table
  -- so we use our own copy
  CompletionItemKind = {
    'Text',
    'Method',
    'Function',
    'Constructor',
    'Field',
    'Variable',
    'Class',
    'Interface',
    'Module',
    'Property',
    'Unit',
    'Value',
    'Enum',
    'Keyword',
    'Snippet',
    'Color',
    'File',
    'Reference',
    'Folder',
    'EnumMember',
    'Constant',
    'Struct',
    'Event',
    'Operator',
    'TypeParameter',

    Text = 1,
    Method = 2,
    Function = 3,
    Constructor = 4,
    Field = 5,
    Variable = 6,
    Class = 7,
    Interface = 8,
    Module = 9,
    Property = 10,
    Unit = 11,
    Value = 12,
    Enum = 13,
    Keyword = 14,
    Snippet = 15,
    Color = 16,
    File = 17,
    Reference = 18,
    Folder = 19,
    EnumMember = 20,
    Constant = 21,
    Struct = 22,
    Event = 23,
    Operator = 24,
    TypeParameter = 25,
  },
}
