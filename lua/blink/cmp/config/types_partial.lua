--- @class (exact) blink.cmp.Config : blink.cmp.ConfigStrict
--- @field enabled? fun(): boolean
--- @field keymap? blink.cmp.KeymapConfig
--- @field completion? blink.cmp.CompletionConfigPartial
--- @field fuzzy? blink.cmp.FuzzyConfigPartial
--- @field sources? blink.cmp.SourceConfigPartial
--- @field signature? blink.cmp.SignatureConfigPartial
--- @field snippets? blink.cmp.SnippetsConfigPartial
--- @field appearance? blink.cmp.AppearanceConfigPartial
--- @field cmdline? blink.cmp.CmdlineConfigPartial
--- @field term? blink.cmp.TermConfigPartial

--- @class (exact) blink.cmp.CompletionConfigPartial : blink.cmp.CompletionConfig
--- @field keyword? blink.cmp.CompletionKeywordConfigPartial
--- @field trigger? blink.cmp.CompletionTriggerConfigPartial
--- @field list? blink.cmp.CompletionListConfigPartial
--- @field accept? blink.cmp.CompletionAcceptConfigPartial
--- @field menu? blink.cmp.CompletionMenuConfigPartial
--- @field documentation? blink.cmp.CompletionDocumentationConfigPartial
--- @field ghost_text? blink.cmp.CompletionGhostTextConfigPartial

--- @class (exact) blink.cmp.CompletionKeywordConfigPartial : blink.cmp.CompletionKeywordConfig, {}

--- @class (exact) blink.cmp.CompletionTriggerConfigPartial : blink.cmp.CompletionTriggerConfig, {}

--- @class (exact) blink.cmp.CompletionListConfigPartial : blink.cmp.CompletionListConfig, {}
--- @field selection? blink.cmp.CompletionListSelectionConfigPartial
--- @field cycle? blink.cmp.CompletionListCycleConfigPartial

--- @class (exact) blink.cmp.CompletionListSelectionConfigPartial : blink.cmp.CompletionListSelectionConfig, {}

--- @class (exact) blink.cmp.CompletionListCycleConfigPartial : blink.cmp.CompletionListCycleConfig, {}

--- @class (exact) blink.cmp.CompletionAcceptConfigPartial : blink.cmp.CompletionAcceptConfig, {}
--- @field auto_brackets? blink.cmp.AutoBracketsConfigPartial

--- @class (exact) blink.cmp.AutoBracketsConfigPartial : blink.cmp.AutoBracketsConfig, {}
--- @field kind_resolution? blink.cmp.AutoBracketResolutionConfigPartial Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution? blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial Asynchronously use semantic token to determine if brackets should be added

--- @class (exact) blink.cmp.AutoBracketResolutionConfigPartial : blink.cmp.AutoBracketResolutionConfig, {}

--- @class (exact) blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial : blink.cmp.AutoBracketSemanticTokenResolutionConfig, {}

--- @class (exact) blink.cmp.CompletionMenuConfigPartial : blink.cmp.CompletionMenuConfig, {}
--- @field order? blink.cmp.CompletionMenuOrderConfigPartial TODO: implement

--- @class (exact) blink.cmp.CompletionMenuOrderConfigPartial : blink.cmp.CompletionMenuOrderConfig, {}

--- @class (exact) blink.cmp.CompletionDocumentationConfigPartial : blink.cmp.CompletionDocumentationConfig, {}
--- @field window? blink.cmp.CompletionDocumentationWindowConfigPartial

--- @class (exact) blink.cmp.CompletionDocumentationWindowConfigPartial : blink.cmp.CompletionDocumentationWindowConfig, {}
--- @field direction_priority? blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact) blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial : blink.cmp.CompletionDocumentationDirectionPriorityConfig, {}

--- @class (exact) blink.cmp.CompletionGhostTextConfigPartial : blink.cmp.CompletionGhostTextConfig, {}

--- @class (exact) blink.cmp.FuzzyConfigPartial : blink.cmp.FuzzyConfig, {}

--- @class (exact) blink.cmp.PrebuiltBinariesProxyConfigPartial : blink.cmp.PrebuiltBinariesProxyConfig, {}

--- @class blink.cmp.SourceConfigPartial : blink.cmp.SourceConfig, {}
--- @field providers? table<string, blink.cmp.SourceProviderConfigPartial>

--- @class blink.cmp.SourceProviderConfigPartial : blink.cmp.SourceProviderConfig, {}

--- @class (exact) blink.cmp.SignatureConfigPartial : blink.cmp.SignatureConfig, {}
--- @field trigger? blink.cmp.SignatureTriggerConfigPartial
--- @field window? blink.cmp.SignatureWindowConfigPartial

--- @class (exact) blink.cmp.SignatureTriggerConfigPartial : blink.cmp.SignatureTriggerConfig, {}

--- @class (exact) blink.cmp.SignatureWindowConfigPartial : blink.cmp.SignatureWindowConfig, {}

--- @class (exact) blink.cmp.SnippetsConfigPartial : blink.cmp.SnippetsConfig, {}

--- @class (exact) blink.cmp.AppearanceConfigPartial : blink.cmp.AppearanceConfig, {}

--- @class (exact) blink.cmp.CmdlineConfigPartial : blink.cmp.CmdlineConfig, {}

--- @class (exact) blink.cmp.TermConfigPartial : blink.cmp.TermConfig, {}
