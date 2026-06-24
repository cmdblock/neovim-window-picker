local config = require("window-picker.config")
local picker = require("window-picker.picker")

local M = {}

--- 初始化插件
-- @param opts table 用户自定义配置（可选）
-- 配置项说明：
--   labels: 字母序列，用于标识窗口（默认 "asdfghjkl;qwertyuiopzxcvbnm"）
--   float: 浮动窗口样式配置
--     border: 边框样式（"rounded", "single", "double", "solid", "shadow"）
--     style: 窗口样式（默认 "minimal"）
--     highlight: 高亮组名称（默认 "WindowPickerFloat"）
--   filter: 窗口过滤函数，返回 true 表示参与跳转
function M.setup(opts)
  config.setup(opts)
end

--- 触发窗口选择
-- 显示每个窗口的字母提示，等待用户按键后跳转到对应窗口
function M.pick()
  picker.pick()
end

return M
