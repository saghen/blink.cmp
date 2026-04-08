local auto_wrap = {}

--- Disables auto text wrapping by removing formatoptions 't' and 'c'.
--- Records which options were active in buffer variables so they can be
--- restored later by restore_auto_wrap(). Should be paired with restore_auto_wrap().
function auto_wrap.disable()
  local formatoptions = vim.opt.formatoptions:get()
  if formatoptions.t then
    vim.b.blink_cmp_restore_formatoptions_t = true
    vim.opt.formatoptions:remove('t')
  end
  if formatoptions.c then
    vim.b.blink_cmp_restore_formatoptions_c = true
    vim.opt.formatoptions:remove('c')
  end
  if formatoptions.a then
    vim.b.blink_cmp_restore_formatoptions_a = true
    vim.opt.formatoptions:remove('a')
  end
end

--- Restores auto text wrapping (formatoptions 't' and 'c') previously disabled
--- by disable_auto_wrap(). Uses pcall to ensure formatoptions are restored even
--- if an error occurs. If text exceeded textwidth while wrapping was disabled,
--- schedules a reformat of the current line.
function auto_wrap.restore()
  local restore_t = vim.b.blink_cmp_restore_formatoptions_t
  local restore_c = vim.b.blink_cmp_restore_formatoptions_c
  local restore_a = vim.b.blink_cmp_restore_formatoptions_a

  local success, err = pcall(function()
    if restore_t then
      vim.opt.formatoptions:append('t')
      vim.b.blink_cmp_restore_formatoptions_t = nil
    end
    if restore_c then
      vim.opt.formatoptions:append('c')
      vim.b.blink_cmp_restore_formatoptions_c = nil
    end
    if restore_a then
      vim.opt.formatoptions:append('a')
      vim.b.blink_cmp_restore_formatoptions_a = nil
    end
  end)

  if not success then error(err) end
end

return auto_wrap
