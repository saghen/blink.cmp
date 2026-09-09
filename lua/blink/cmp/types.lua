--- Client-side extensions carried on a completion item. In-process servers may set them directly;
--- `convert` sets them for out-of-process servers. Stripped before `completionItem/resolve`.
--- @class blink.cmp.ItemExt
--- @field kind_icon? string
--- @field kind_hl? string
--- @field kind_name? string
--- @field score_offset? integer

--- @class blink.cmp.CompletionItem : lsp.CompletionItem
--- @field documentation? string | blink.cmp.CompletionDocumentationMarkupContent
--- @field blink? blink.cmp.ItemExt
--- @field client_id? integer
--- @field client_name? string
--- @field pos? vim.Pos Cursor position when the item was requested, for compensating text edits
--- @field exact? boolean Set by the fuzzy matcher
--- @field score? integer Set by the fuzzy matcher

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
