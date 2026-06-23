local ok, window_picker = pcall(require, "window-picker")

if not ok then
  return
end

vim.api.nvim_set_hl(0, "WindowPickerFloat", {
  fg = "#ffffff",
  bg = "#ff0000",
  ctermfg = "white",
  ctermbg = "red",
  default = true,
})

vim.keymap.set("n", "<Plug>(WindowPickerPick)", function()
  window_picker.pick()
end, { silent = true })

local has_map = false
for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
  if map.rhs == "<Plug>(WindowPickerPick)" or string.find(map.lhs or "", "<leader>w", 1, true) then
    has_map = true
    break
  end
end

if not has_map then
  vim.keymap.set("n", "<leader>w", "<Plug>(WindowPickerPick)", {})
end
