--- Gets the capabilities to pass to the LSP client
--- @param override? lsp.ClientCapabilities Overrides blink.cmp's default capabilities
--- @param include_nvim_defaults? boolean Whether to include nvim's default capabilities
--- @return lsp.ClientCapabilities
return function(override, include_nvim_defaults)
  return vim.tbl_deep_extend('force', include_nvim_defaults and vim.lsp.protocol.make_client_capabilities() or {}, {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false, -- TODO:
          documentationFormat = { 'markdown', 'plaintext' },
          deprecatedSupport = true,
          preselectSupport = false, -- TODO:
          tagSupport = { valueSet = { 1 } }, -- deprecated
          insertReplaceSupport = true, -- TODO:
          resolveSupport = {
            properties = {
              'documentation',
              'detail',
              'additionalTextEdits',
              'command',
              'data',
              -- TODO: support more properties? should test if it improves latency
            },
          },
          insertTextModeSupport = {
            -- TODO: support adjustIndentation
            valueSet = { 1 }, -- asIs
          },
          labelDetailsSupport = true,
        },
        completionList = {
          itemDefaults = {
            'commitCharacters',
            'editRange',
            'insertTextFormat',
            'insertTextMode',
            'data',
          },
        },

        contextSupport = true,
        insertTextMode = 1, -- asIs
      },
    },
  }, override or {})
end
