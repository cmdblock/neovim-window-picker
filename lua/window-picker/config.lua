local M = {}

M.defaults = {
  labels = "asdfghjkl;qwertyuiopzxcvbnm",
  float = {
    border = "rounded",
    style = "minimal",
    highlight = "WindowPickerFloat",
  },
  filter = function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    return buftype == "" or buftype == "help"
  end,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.get()
  return M.options
end

return M
