local M = {}

M.defaults = {
  labels = "asdfghjkl;qwertyuiopzxcvbnm",
  float = {
    border = "rounded",
    style = "minimal",
    highlight = "WindowPickerFloat",
  },
  filter = function(win)
    return true
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
