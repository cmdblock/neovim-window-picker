local M = {}

-- 默认配置项
M.defaults = {
  -- 用于窗口标识的字母序列，按顺序分配给各个窗口
  labels = "asdfghjkl;qwertyuiopzxcvbnm",
  -- 浮动窗口外观配置
  float = {
    -- 边框样式："single", "double", "rounded", "solid", "shadow"
    border = "rounded",
    -- 窗口样式
    style = "minimal",
    -- 高亮组名称
    highlight = "WindowPickerFloat",
  },
  -- 窗口过滤函数，返回 true 表示该窗口参与跳转
  -- 默认不过滤，包含所有窗口
  filter = function(win)
    return true
  end,
}

-- 用户实际配置（setup 后生效）
M.options = {}

--- 初始化配置
-- @param opts table 用户自定义配置（可选）
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

--- 获取当前配置
-- @return table 当前生效的配置
function M.get()
  return M.options
end

return M
