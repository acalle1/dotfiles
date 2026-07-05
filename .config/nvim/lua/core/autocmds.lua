local augroup = vim.api.nvim_create_augroup("user", {})

-- open quickfix list automatically after :grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = augroup,
  pattern = "*grep*",
  command = "cwindow",
})

-- reload buffers changed outside nvim (e.g. git checkout in another tmux pane)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup,
  command = "checktime",
})
