--- @class (exact) blink.cmp.Config : blink.cmp.ConfigStrict
--- @field enabled? fun(): boolean
--- @field keymap? blink.cmp.KeymapConfig
--- @field completion? blink.cmp.DeepPartial<blink.cmp.CompletionConfigPartial>
--- @field fuzzy? blink.cmp.DeepPartial<blink.cmp.FuzzyConfigPartial>
--- @field signature? blink.cmp.DeepPartial<blink.cmp.SignatureConfigPartial>
--- @field snippets? blink.cmp.DeepPartial<blink.cmp.SnippetsConfigPartial>
--- @field appearance? blink.cmp.DeepPartial<blink.cmp.AppearanceConfigPartial>
--- @field cmdline? blink.cmp.DeepPartial<blink.cmp.CmdlineConfigPartial>
--- @field lsp? table<string, blink.cmp.LspSetupConfig>

--- @alias blink.cmp.DeepPartial<T> T extends any[] and T or (T extends table and { [K in keyof T]?: blink.cmp.DeepPartial<T[K]>? } or T)
--- @field completion? blink.cmp.CompletionConfigPartial
--- @field fuzzy? blink.cmp.FuzzyConfigPartial
--- @field signature? blink.cmp.SignatureConfigPartial
--- @field snippets? blink.cmp.SnippetsConfigPartial
--- @field appearance? blink.cmp.AppearanceConfigPartial
--- @field cmdline? blink.cmp.CmdlineConfigPartial
--- @field lsp? table<string, blink.cmp.LspSetupConfig> Client-side policy per server (or `'*'`), forwarded to `cmp.lsp.config` and `cmp.lsp.enable`

--- @class blink.cmp.LspSetupConfig : blink.cmp.LspConfig
--- @field enabled? boolean | fun(ctx: blink.cmp.Context): boolean Whether blink queries the server, see `cmp.lsp.enable`

--- @class (exact) blink.cmp.CompletionConfigPartial : blink.cmp.CompletionConfig
--- @field keyword? blink.cmp.CompletionKeywordConfigPartial
--- @field trigger? blink.cmp.CompletionTriggerConfigPartial
--- @field list? blink.cmp.CompletionListConfigPartial
--- @field accept? blink.cmp.CompletionAcceptConfigPartial
--- @field menu? blink.cmp.CompletionMenuConfigPartial
--- @field documentation? blink.cmp.CompletionDocumentationConfigPartial
--- @field ghost_text? blink.cmp.CompletionGhostTextConfigPartial

--- @class (exact, partial) blink.cmp.CompletionKeywordConfigPartial : blink.cmp.CompletionKeywordConfig

--- @class (exact, partial) blink.cmp.CompletionTriggerConfigPartial : blink.cmp.CompletionTriggerConfig

--- @class (exact, partial) blink.cmp.CompletionListConfigPartial : blink.cmp.CompletionListConfig
--- @field selection? blink.cmp.CompletionListSelectionConfigPartial
--- @field cycle? blink.cmp.CompletionListCycleConfigPartial

--- @class (exact, partial) blink.cmp.CompletionListSelectionConfigPartial : blink.cmp.CompletionListSelectionConfig

--- @class (exact, partial) blink.cmp.CompletionListCycleConfigPartial : blink.cmp.CompletionListCycleConfig

--- @class (exact, partial) blink.cmp.CompletionAcceptConfigPartial : blink.cmp.CompletionAcceptConfig
--- @field auto_brackets? blink.cmp.AutoBracketsConfigPartial

--- @class (exact, partial) blink.cmp.AutoBracketsConfigPartial : blink.cmp.AutoBracketsConfig
--- @field kind_resolution? blink.cmp.AutoBracketResolutionConfigPartial Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution? blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial Asynchronously use semantic token to determine if brackets should be added

--- @class (exact, partial) blink.cmp.AutoBracketResolutionConfigPartial : blink.cmp.AutoBracketResolutionConfig

--- @class (exact, partial) blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial : blink.cmp.AutoBracketSemanticTokenResolutionConfig

--- @class (exact, partial) blink.cmp.CompletionMenuConfigPartial : blink.cmp.CompletionMenuConfig
--- @field order? blink.cmp.CompletionMenuOrderConfigPartial TODO: implement

--- @class (exact, partial) blink.cmp.CompletionMenuOrderConfigPartial : blink.cmp.CompletionMenuOrderConfig

--- @class (exact, partial) blink.cmp.CompletionDocumentationConfigPartial : blink.cmp.CompletionDocumentationConfig
--- @field window? blink.cmp.CompletionDocumentationWindowConfigPartial

--- @class (exact, partial) blink.cmp.CompletionDocumentationWindowConfigPartial : blink.cmp.CompletionDocumentationWindowConfig
--- @field direction_priority? blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact, partial) blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial : blink.cmp.CompletionDocumentationDirectionPriorityConfig

--- @class (exact, partial) blink.cmp.CompletionGhostTextConfigPartial : blink.cmp.CompletionGhostTextConfig

--- @class (exact, partial) blink.cmp.FuzzyConfigPartial : blink.cmp.FuzzyConfig

--- @class (exact) blink.cmp.SignatureConfigPartial : blink.cmp.SignatureConfig, {}
--- @field trigger? blink.cmp.SignatureTriggerConfigPartial
--- @field window? blink.cmp.SignatureWindowConfigPartial

--- @class (exact, partial) blink.cmp.SignatureTriggerConfigPartial : blink.cmp.SignatureTriggerConfig

--- @class (exact, partial) blink.cmp.SignatureWindowConfigPartial : blink.cmp.SignatureWindowConfig

--- @class (exact, partial) blink.cmp.SnippetsConfigPartial : blink.cmp.SnippetsConfig

--- @class (exact, partial) blink.cmp.AppearanceConfigPartial : blink.cmp.AppearanceConfig

--- @class (exact) blink.cmp.CmdlineConfigPartial : blink.cmp.CmdlineConfig, {}
