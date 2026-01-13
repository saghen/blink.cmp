-- Credit goes to @hrsh7th for the code that this was based on
-- https://github.com/hrsh7th/cmp-cmdline
-- License: MIT

local async = require('blink.cmp.lib.async')
local constants = require('blink.cmp.sources.cmdline.constants')
local cmdline_utils = require('blink.cmp.sources.cmdline.utils')
local utils = require('blink.cmp.sources.lib.utils')
local path_lib = require('blink.cmp.sources.path.lib')

--- @class blink.cmp.Source
local cmdline = {
  ---@type table<string, vim.api.keyset.get_option_info?>
  options = vim.api.nvim_get_all_options_info(),
}

function cmdline.new()
  local self = setmetatable({}, { __index = cmdline })
  self.before_line = ''
  self.offset = -1
  self.ctype = ''
  self.items = {}
  return self --[[@as blink.cmp.Source]]
end

---@return boolean
function cmdline:enabled()
  return vim.bo.ft == 'vim'
    or (utils.is_command_line({ ':', '@' }) and not utils.in_ex_context(constants.ex_search_commands))
end

---@return table
function cmdline:get_trigger_characters() return { ' ', '.', '#', '-', '=', '/', ':', '!', '%', '~' } end

---@param context blink.cmp.Context
---@param callback fun(result?: blink.cmp.CompletionResponse)
---@return fun()
function cmdline:get_completions(context, callback)
  local completion_type = utils.get_completion_type(context.mode)

  local is_path_completion = cmdline_utils.is_path_completion(completion_type, context.line)
  local is_buffer_completion = vim.tbl_contains(constants.completion_types.buffer, completion_type)
  local is_filename_modifier_completion = cmdline_utils.contains_filename_modifiers(context.line, completion_type)
  local is_wildcard_completion = cmdline_utils.contains_wildcard(context.line)

  local should_split_path = (is_path_completion or is_buffer_completion)
    and not is_filename_modifier_completion
    and not is_wildcard_completion
  local context_line, arguments = cmdline_utils.smart_split(context.line, should_split_path)
  local before_cursor = context_line:sub(1, context.cursor[2])
  local _, args_before_cursor = cmdline_utils.smart_split(before_cursor, should_split_path)
  local arg_number = #args_before_cursor

  local leading_spaces = context.line:match('^(%s*)') -- leading spaces in the original query
  local text_before_argument = table.concat(require('blink.cmp.lib.utils').slice(arguments, 1, arg_number - 1), ' ')
    .. (arg_number > 1 and ' ' or '')

  local current_arg = arguments[arg_number]
  local keyword_config = require('blink.cmp.config').completion.keyword
  local keyword = context.get_bounds(keyword_config.range)
  local current_arg_prefix = current_arg:sub(1, keyword.start_col - #text_before_argument - 1)

  local unique_suffixes = {}
  local unique_suffixes_limit = 2000
  local special_char, vim_expr

  local task = async.task
    .empty()
    :map(function()
      -- Special case for help where we read all the tags ourselves
      if completion_type == 'help' then
        return require('blink.cmp.sources.cmdline.help').get_completions(current_arg_prefix)
      end

      local completions = {}

      -- Input mode (vim.fn.input())
      if utils.is_command_line({ '@' }) then
        local completion_args = vim.split(completion_type, ',', { plain = true })
        local custom_type = completion_args[1]
        local completion_func = completion_args[2]

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
            success, fn_completions =
              cmdline_utils.call_vlua(completion_func, current_arg_prefix, context.get_line(), context.cursor[2] + 1)
          else
            -- Regular vimscript/Lua functions
            success, fn_completions =
              pcall(vim.fn.call, completion_func, { current_arg_prefix, context.get_line(), context.cursor[2] + 1 })
          end

          if success and fn_completions then
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

            completions = cmdline_utils.get_completions(query, compl_type, completion_type)
            if type(completions) ~= 'table' then completions = {} end
          end
        end
      elseif is_filename_modifier_completion then
        vim_expr = cmdline_utils.extract_quoted_part(current_arg) or current_arg
        special_char = vim_expr:sub(-1)

        -- Alternate files
        if special_char == '#' then
          local alt_buf = vim.fn.bufnr('#')
          if alt_buf ~= -1 then
            local buffers = { [''] = vim.fn.expand('#') } -- Keep the '#' prefix as a completion option
            local curr_buf = vim.api.nvim_get_current_buf()
            for _, buf in ipairs(vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })) do
              if buf.bufnr ~= curr_buf and buf.bufnr ~= alt_buf then
                buffers[tostring(buf.bufnr)] = vim.fn.expand('#' .. buf.bufnr)
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
        completions = cmdline_utils.get_completions(query, 'cmdline', completion_type)
      end

      return completions
    end)
    :schedule()
    :map(function(completions)
      ---@cast completions string[]

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

      ---@type blink.cmp.CompletionItem[]
      local items = {}
      for _, completion in ipairs(completions) do
        local filter_text, new_text = completion, completion
        local label, label_details
        local option_info

        -- current (%) or alternate (#) filename with optional modifiers (:)
        if is_filename_modifier_completion then
          local expanded = vim.fn.expand(vim_expr .. completion)
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

        -- options
        elseif completion_type == 'option' then
          new_text = current_arg_prefix .. completion
          option_info = self.options[completion]
          if option_info then label_details = { description = option_info.shortname } end

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

        local start_pos = #text_before_argument + #leading_spaces
        local line = context.cursor[1] - 1

        -- exclude range for commands on the first argument
        if arg_number == 1 and completion_type == 'command' then
          local prefix = cmdline_utils.longest_match(current_arg, {
            "^%s*'<%s*,%s*'>%s*", -- Visual range, e.g. '<,>'
            '^%s*%d+%s*,%s*%d+%s*', -- Numeric range, e.g. 3,5
            '^%s*[%p]+%s*', -- One or more punctuation characters
          })
          start_pos = start_pos + #prefix
        end

        ---@type blink.cmp.CompletionItem
        local item = {
          label = label or filter_text,
          filterText = filter_text,
          labelDetails = label_details,
          -- move items starting with special characters to the end of the list
          sortText = filter_text:lower():gsub('^([!-@\\[-`])', '~%1'),
          textEdit = {
            newText = new_text,
            insert = {
              start = { line = line, character = start_pos },
              ['end'] = { line = line, character = context.cursor[2] },
            },
            replace = {
              start = { line = line, character = start_pos },
              ['end'] = {
                line = line,
                character = math.min(start_pos + #current_arg, context.bounds.start_col + context.bounds.length - 1),
              },
            },
          },
          kind = require('blink.cmp.types').CompletionItemKind.Property,
        }
        items[#items + 1] = item

        if option_info and option_info.type == 'boolean' then
          filter_text = 'no' .. filter_text
          items[#items + 1] = vim.tbl_deep_extend('force', {}, item, {
            label = filter_text,
            filterText = filter_text,
            labelDetails = { description = 'no' .. label_details.description },
            sortText = filter_text,
            textEdit = { newText = 'no' .. new_text },
          }) --[[@as blink.cmp.CompletionItem]]
        end
      end

      callback({
        is_incomplete_backward = completion_type ~= 'help',
        is_incomplete_forward = false,
        items = items,
        ---@diagnostic disable-next-line: missing-return
      })
    end)
    :catch(function(err)
      -- TODO: is there a way to avoid throwing this error?
      if type(err) ~= 'string' or not err:match('Vim:E433: No tags file') then
        vim.notify('Error while fetching completions: ' .. err, vim.log.levels.ERROR, { title = 'blink.cmp' })
      end
      ---@diagnostic disable-next-line: missing-return
      callback({ is_incomplete_backward = false, is_incomplete_forward = false, items = {} })
    end)

  return function() task:cancel() end
end

return cmdline
