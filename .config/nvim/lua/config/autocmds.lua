-- ============================================================================
-- ✨ Autocommands
-- ============================================================================

-- ============================================================================
-- 📋 Highlight copied text
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),

  callback = function()
    vim.highlight.on_yank({
      timeout = 180,
    })
  end,
})
-- ============================================================================
-- 🔙 Return to last editing position
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last-location", { clear = true }),

  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================================
-- 📝 Enable wrapping for text files
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
    "text",
    "gitcommit",
  },

  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})
