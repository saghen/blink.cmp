--- @class (exact) blink.cmp.CompletionConfig
--- @field keyword blink.cmp.CompletionKeywordConfig
--- @field trigger blink.cmp.CompletionTriggerConfig
--- @field list blink.cmp.CompletionListConfig
--- @field accept blink.cmp.CompletionAcceptConfig
--- @field menu blink.cmp.CompletionMenuConfig
--- @field documentation blink.cmp.CompletionDocumentationConfig
--- @field ghost_text blink.cmp.CompletionGhostTextConfig

return {
  keyword = require('blink.cmp.config.completion.keyword'),
  trigger = require('blink.cmp.config.completion.trigger'),
  list = require('blink.cmp.config.completion.list'),
  accept = require('blink.cmp.config.completion.accept'),
  menu = require('blink.cmp.config.completion.menu'),
  documentation = require('blink.cmp.config.completion.documentation'),
  ghost_text = require('blink.cmp.config.completion.ghost_text'),
}
