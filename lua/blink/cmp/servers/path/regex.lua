-- somehow less readable than normal regexes

-- we allow spaces in previous path segments, but not in the current one
-- Allowed: ~/example foo/
-- Not allowed: ~/example foo
local NAME_WITH_SPACE_REGEX = '\\%([^/\\\\:\\*?<>\'"`\\|]\\)'
local NAME_REGEX = '\\%([^/\\\\:\\*?<>\'"`\\| ]\\)'
local IS_WIN = vim.uv.os_uname().sysname == 'Windows_NT'
local PATH_REGEX

if IS_WIN then
  PATH_REGEX = assert(
    vim.regex(
      ([[\%(\%([/\\]PAT1*[^/\\\\:\\*?<>\'"`\\| .~]\)\|\%(/\.\.\)\)*[/\\]\zePAT2*$]])
        :gsub('PAT1', NAME_WITH_SPACE_REGEX)
        :gsub('PAT2', NAME_REGEX)
    )
  )
else
  PATH_REGEX = assert(
    vim.regex(
      ([[\%(\%(/PAT1*[^/\\\\:\\*?<>\'"`\\| .~]\)\|\%(/\.\.\)\)*/\zePAT2*$]])
        :gsub('PAT1', NAME_WITH_SPACE_REGEX)
        :gsub('PAT2', NAME_REGEX)
    )
  )
end

return {
  --- Lua pattern for matching file names
  NAME = '[^/\\:*?<>\'"`|]',
  --- Vim regex for matching file paths
  PATH = PATH_REGEX,
}
