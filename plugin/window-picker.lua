-- Neovim 启动时自动加载此文件
-- 作用：设置高亮组、定义 <Plug> 映射、绑定默认快捷键

-- 尝试加载 window-picker 主模块
local ok, window_picker = pcall(require, "window-picker")

-- 如果加载失败（例如用户未安装或配置有误），直接返回，避免报错
if not ok then
  return
end

-- 设置浮动窗口的高亮样式
-- default = true 表示如果用户已定义同名高亮组，则不覆盖
vim.api.nvim_set_hl(0, "WindowPickerFloat", {
  fg = "#ffffff",        -- 前景色：白色
  bg = "#ff0000",        -- 背景色：红色
  ctermfg = "white",     -- 终端前景色
  ctermbg = "red",       -- 终端背景色
  default = true,
})

-- 定义 <Plug> 映射（供用户自定义快捷键使用）
-- 用户可以通过 nmap <leader>w <Plug>(WindowPickerPick) 来绑定
vim.keymap.set("n", "<Plug>(WindowPickerPick)", function()
  window_picker.pick()
end, { silent = true })

-- 检查用户是否已经绑定了 <leader>w
-- 如果没有绑定，则自动绑定为默认快捷键
local has_map = false
for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
  if map.rhs == "<Plug>(WindowPickerPick)" or string.find(map.lhs or "", "<leader>w", 1, true) then
    has_map = true
    break
  end
end

-- 如果用户没有自定义 <leader>w 映射，则设置默认映射
if not has_map then
  vim.keymap.set("n", "<leader>w", "<Plug>(WindowPickerPick)", {})
end
