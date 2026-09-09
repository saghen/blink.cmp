--- Ex commands, their arguments and `input()` prompts, from nvim's own completion (`getcompletion()`).
---
--- Credit goes to @hrsh7th for the code that this was based on
--- https://github.com/hrsh7th/cmp-cmdline
--- License: MIT
local lsp = require('blink.lib.lsp')
local lib = require('blink.lib')
local constants = require('blink.cmp.servers.cmdline.constants')
local utils = require('blink.cmp.servers.cmdline.utils')
local path_lib = require('blink.cmp.servers.path.lib')

local kind_property = require('blink.cmp.types').CompletionItemKind.Property
local unique_suffixes_limit = 2000

--- @type table<string, vim.api.keyset.get_option_info?>
local options
local function option_info(name)
  if options == nil then options = vim.api.nvim_get_all_options_info() end
  return options[name]
end

--- @class blink.cmp.CmdlineRequest
--- @field bufnr integer
--- @field is_cmdline boolean Whether the command line itself is being edited, through its mirror buffer
--- @field cmdtype string `getcmdtype()` while editing the command line, `':'` otherwise
--- @field line string
--- @field row integer 0-indexed
--- @field col integer 0-indexed byte column of the cursor
--- @field keyword_start integer 0-indexed byte column where the keyword before the cursor starts, per blink's `completion.keyword`
--- @field keyword_end integer 0-indexed byte column where the keyword under the cursor ends

--- @param params lsp.CompletionParams
--- @return blink.cmp.CmdlineRequest?
local function to_request(params)
  local bufnr = lsp.util.bufnr(params.textDocument)
  if bufnr == nil then return end
  local row, col = lsp.util.position(params.position)

  local is_cmdline = vim.b[bufnr].blink_cmp_mirror == 'cmdline' and vim.api.nvim_get_mode().mode == 'c'
  local line = is_cmdline and vim.fn.getcmdline() or (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or '')

  -- the keyword as the client will match it, so that the prefix before it ends up in the edits
  local fuzzy = require('blink.cmp.fuzzy')
  local keyword_start = fuzzy.get_keyword_range(line, col, require('blink.cmp.config').completion.keyword.range)
  local _, keyword_end = fuzzy.get_keyword_range(line, col, 'full')

  return {
    bufnr = bufnr,
    is_cmdline = is_cmdline,
    cmdtype = is_cmdline and vim.fn.getcmdtype() or ':',
    line = line,
    row = row,
    col = col,
    keyword_start = keyword_start,
    keyword_end = keyword_end,
  }
end

--- @async
--- @param req blink.cmp.CmdlineRequest
--- @return lsp.CompletionList
local function complete(req)
  local line = req.line
  local completion_type = utils.get_completion_type(req.is_cmdline, line)

  -- `:set no<opt>` / `:set inv<opt>`: nvim reports no completion type and completes the option
  -- without its `no`, so the negated boolean options are built here
  local negation --- @type string?
  if completion_type == '' then
    negation = line:match('^%s*se[tl]?%a*%s+(no)%a*$') or line:match('^%s*se[tl]?%a*%s+(inv)%a*$')
    if negation ~= nil then completion_type = 'option' end
  end

  local is_path_completion = utils.is_path_completion(completion_type, line)
  local is_buffer_completion = vim.tbl_contains(constants.completion_types.buffer, completion_type)
  local is_filename_modifier_completion = utils.contains_filename_modifiers(line, completion_type)
  local is_wildcard_completion = utils.contains_wildcard(line)
  local is_man_completion = completion_type == '' and line:match('^Man ') ~= nil

  local should_split_path = (is_path_completion or is_buffer_completion)
    and not is_filename_modifier_completion
    and not is_wildcard_completion
  local _, arguments = utils.smart_split(line, should_split_path)
  local before_cursor = line:sub(1, req.col)
  local _, args_before_cursor = utils.smart_split(before_cursor, should_split_path)
  local arg_number = #args_before_cursor

  local leading_spaces = line:match('^(%s*)') -- leading spaces in the original query
  local text_before_argument = table.concat(lib.list.slice(arguments, 1, arg_number - 1), ' ')
    .. (arg_number > 1 and ' ' or '')

  local current_arg = arguments[arg_number] or ''
  local current_arg_prefix = current_arg:sub(1, req.keyword_start - #text_before_argument)

  local start_pos = #text_before_argument + #leading_spaces

  -- Skip leading command range when computing start_pos
  local range_prefix --- @type string?
  if arg_number == 1 and completion_type == 'command' then
    range_prefix = utils.get_range_prefix(current_arg)
    if range_prefix then
      start_pos = start_pos + #range_prefix
      current_arg_prefix = range_prefix
    end
  end
  local replace_end_pos = math.min(start_pos + #current_arg, req.keyword_end)

  local unique_suffixes = {} --- @type table<string, string>
  ---@type string?, string?
  local special_char, vim_expr
  -- custom completion functions get the argument up to the cursor (`ArgLead`) and may depend on
  -- it, so they're called again on every keystroke
  local is_custom = req.cmdtype == '@' and vim.startswith(completion_type, 'custom')
  local arg_lead = line:sub(start_pos + 1, req.col)

  --- @async
  --- @return string[]
  local function get_raw_completions()
    -- Special case for help where we read all the tags ourselves
    if completion_type == 'help' then
      return require('blink.cmp.servers.cmdline.help').get_completions(current_arg_prefix)
    end
    -- Special case for :Man, builtin completion is lazy and only becomes meaningful
    -- once there is at least one character after the space.
    if is_man_completion and current_arg ~= '' then
      return require('blink.cmp.servers.cmdline.man').get_completions(current_arg, line)
    end

    local completions = {}

    -- Input mode (vim.fn.input())
    if req.cmdtype == '@' then
      local completion_args = vim.split(completion_type, ',', { plain = true })
      local custom_type = completion_args[1] or ''
      local completion_func = completion_args[2] or ''

      -- Handle custom completions
      if vim.startswith(custom_type, 'custom') then
        local custom_func = completion_func:lower()

        -- Missing function or script-local functions cannot be resolved safely
        if not completion_func or vim.startswith(custom_func, 's:') or vim.startswith(custom_func, '<sid>') then
          return completions
        end

        local success, fn_completions

        -- Handle v:lua functions (:h v:lua-call)
        if vim.startswith(custom_func, 'v:lua') then
          success, fn_completions = utils.call_vlua(completion_func, arg_lead, line, req.col + 1)
        else
          -- Regular vimscript/Lua functions
          success, fn_completions = pcall(vim.fn.call, completion_func, { arg_lead, line, req.col + 1 })
        end

        -- Forward any error caught by pcall
        if not success then return error(fn_completions) end

        if fn_completions then
          if type(fn_completions) == 'table' then
            completions = fn_completions
          -- `custom,` type returns a string, delimited by newlines
          elseif type(fn_completions) == 'string' then
            completions = vim.split(fn_completions, '\n')
          end
        end

      -- Regular input completions, use the type defined by the input
      else
        local query = (text_before_argument .. current_arg_prefix):gsub([[\\]], [[\\\\]])
        -- Custom types aren't supported by getcompletion(), fallback to 'cmdline'
        local compl_type = vim.startswith(custom_type, 'custom') and 'cmdline' or custom_type
        if compl_type ~= '' then
          -- path completions uniquely expect only the current path
          query = is_path_completion and current_arg_prefix or query

          completions = utils.get_completions(query, compl_type, completion_type)
          if type(completions) ~= 'table' then completions = {} end
        end
      end
    elseif is_filename_modifier_completion then
      vim_expr = utils.extract_quoted_part(current_arg) or current_arg
      special_char = vim_expr:sub(-1)

      -- Alternate files
      if special_char == '#' then
        local alt_buf = vim.fn.bufnr('#')
        if alt_buf ~= -1 then
          local buffers = {
            [''] = vim.fn.expand('#') --[[@as string]],
          } -- Keep the '#' prefix as a completion option
          local curr_buf = vim.api.nvim_get_current_buf()
          for _, buf in ipairs(vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })) do
            if buf.bufnr ~= curr_buf and buf.bufnr ~= alt_buf then
              buffers[tostring(buf.bufnr)] = vim.fn.expand('#' .. buf.bufnr) --[[@as string]]
            end
          end
          completions = vim.tbl_keys(buffers)
          if #completions < unique_suffixes_limit then
            unique_suffixes = path_lib:compute_unique_suffixes(vim.tbl_values(buffers))
          end
        end
      -- Current file
      elseif special_char == '%' then
        completions = { '' }
      -- Modifiers
      elseif special_char == ':' then
        completions = vim.tbl_keys(constants.modifiers)
      elseif vim.tbl_contains({ '~', '.' }, special_char) then
        completions = { special_char }
      end

    -- Cmdline mode
    else
      local query = (text_before_argument .. current_arg_prefix):gsub([[\\]], [[\\\\]])
      if query == '=' then query = '= ' end
      completions = utils.get_completions(query, 'cmdline', completion_type)
    end

    return completions
  end

  --- @param completions string[]
  --- @return lsp.CompletionList
  local function to_response(completions)
    -- The getcompletion() api is inconsistent in whether it returns the prefix or not.
    --
    -- E.g. :set shiftwidth=| will return '2'
    -- E.g. :Neogit kind=| will return 'kind=commit'
    --
    -- For simplicity, excluding the first argument, we always replace the entire command argument,
    -- so we want to ensure the prefix is always in the new_text.
    --
    -- In the case of file/buffer completion, we use the basename for display
    -- but insert the full path for insertion.
    -- In all other cases, we want to check for the prefix and remove it from the filter text
    -- and add it to the newText

    if is_buffer_completion and #completions < unique_suffixes_limit then
      unique_suffixes = path_lib:compute_unique_suffixes(completions)
    end

    ---@type lsp.CompletionItem[]
    local items = {}
    for _, completion in ipairs(completions) do
      local filter_text, new_text = completion, completion
      local label, label_details
      local info

      -- current (%) or alternate (#) filename with optional modifiers (:)
      if is_filename_modifier_completion then
        ---@cast vim_expr string
        local expanded = vim.fn.expand(vim_expr .. completion) --[[@as string]]
        -- expand in command (e.g. :edit %) but don't in expression (e.g. =vim.fn.expand("%"))
        new_text = vim_expr:sub(1, 1) == current_arg_prefix:sub(1, 1) and expanded or current_arg_prefix .. completion

        if special_char == '#' then
          -- special case: we need to display # along with #n
          if completion == '' then filter_text = special_char end
          label_details = { description = unique_suffixes[new_text] or expanded }
        elseif special_char == '%' then
          label_details = { description = expanded }
        elseif vim.tbl_contains({ ':', '~', '.' }, special_char) then
          label_details = { description = constants.modifiers[completion] or expanded }
        end

      -- path completion in commands, e.g. `chdir <path>` and options, e.g. `:set directory=<path>`
      elseif is_path_completion then
        if current_arg == '~' then label = completion end
        filter_text = path_lib.basename_with_sep(completion)
        new_text = vim.fn.fnameescape(completion)
        if completion_type == 'shellcmd' and current_arg_prefix:sub(1, 1) == '!' then
          new_text = '!' .. new_text
        elseif arguments[1] == 'set' then
          new_text = current_arg_prefix:sub(1, current_arg_prefix:find('=') or #current_arg_prefix) .. new_text
        end

      -- buffer commands
      elseif is_buffer_completion then
        label = unique_suffixes[completion] or completion
        if unique_suffixes[completion] then
          label_details = { description = completion:sub(1, -#unique_suffixes[completion] - 2) }
        end
        new_text = vim.fn.fnameescape(completion)

      -- negated boolean options
      elseif negation ~= nil then
        info = option_info(completion)
        if not info or info.type ~= 'boolean' then goto continue end
        filter_text, new_text = negation .. completion, negation .. completion
        label_details = { description = negation .. info.shortname }

      -- options
      elseif completion_type == 'option' then
        new_text = current_arg_prefix .. completion
        info = option_info(completion)
        if info then label_details = { description = info.shortname } end

      -- mappings
      elseif completion_type == 'mapping' then
        completion = completion:gsub('\22', '') -- remove control characters
        completion = vim.fn.keytrans(completion):gsub('<lt>', '<')
        filter_text, new_text = completion, completion

      -- env variables
      elseif completion_type == 'environment' then
        filter_text = '$' .. completion
        new_text = '$' .. completion

      -- expressions
      elseif completion_type == 'expression' then
        if not vim.startswith(completion, current_arg_prefix) then new_text = current_arg_prefix .. completion end

      -- for other completions, prepend the prefix
      elseif vim.tbl_contains({ 'filetype', 'lua', 'shellcmd' }, completion_type) then
        new_text = current_arg_prefix .. completion

      -- treat custom and empty completion '' as special case, this can be:
      -- args (usually from user-defined commands): :Cmd [arg=]value
      -- values (from vim/user-defined commands), :set option=[value], :Cmd arg=[value]
      elseif completion_type == '' or vim.startswith(completion_type, 'custom') then
        if completion:sub(1, #current_arg_prefix) == current_arg_prefix then
          -- same prefix, only need to sanitize the value for filtering
          filter_text = completion:sub(#current_arg_prefix + 1)
        else
          -- different, prepend the prefix for new_text
          new_text = current_arg_prefix .. completion
        end
      end

      ---@type lsp.CompletionItem
      local item = {
        label = label or filter_text,
        filterText = filter_text,
        labelDetails = label_details,
        -- move items starting with special characters to the end of the list
        sortText = filter_text:lower():gsub('^([!-@\\[-`])', '~%1'),
        textEdit = {
          newText = new_text,
          insert = {
            start = { line = req.row, character = start_pos },
            ['end'] = { line = req.row, character = req.col },
          },
          replace = {
            start = { line = req.row, character = start_pos },
            ['end'] = { line = req.row, character = replace_end_pos },
          },
        } --[[@as lsp.InsertReplaceEdit]],
        kind = kind_property,
      }
      items[#items + 1] = item

      if completion_type == 'option' and negation == nil and info and info.type == 'boolean' then
        filter_text = 'no' .. filter_text
        items[#items + 1] = vim.tbl_deep_extend('force', {}, item, {
          label = filter_text,
          filterText = filter_text,
          labelDetails = { description = 'no' .. info.shortname },
          sortText = filter_text,
          textEdit = { newText = 'no' .. new_text },
        }) --[[@as lsp.CompletionItem]]
      end
      ::continue::
    end

    return {
      -- the `:Man` argument and command ranges are completed once there's text after them
      isIncomplete = (is_man_completion and current_arg == '') or range_prefix ~= nil or is_custom,
      items = items,
    }
  end

  local ok, completions = pcall(get_raw_completions)
  if not ok then
    -- nvim errors on partial input (`E220: Missing }`, `E114: Missing quote`) while typing
    if utils.is_vim_error(completions) then return { isIncomplete = false, items = {} } end
    error(completions)
  end
  -- build the items off the keystroke
  require('blink.lib.async').await(vim.schedule)
  return to_response(completions)
end

return lsp.server({
  name = 'blink_cmp_cmdline',
  capabilities = {
    completionProvider = { triggerCharacters = { ' ', '.', '#', '&', '-', '=', '/', ':', '!', '%', '~' } },
  },

  handlers = {
    ['textDocument/completion'] = function(params)
      local req = to_request(params)
      if req == nil then return { isIncomplete = false, items = {} } end
      return complete(req)
    end,
  },
})
