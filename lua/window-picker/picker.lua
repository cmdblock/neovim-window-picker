local config = require("window-picker.config")

local M = {}

function M.pick()
  local opts = config.get()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  local current = vim.api.nvim_get_current_win()

  local filtered = {}
  for _, win in ipairs(wins) do
    if opts.filter(win) then
      table.insert(filtered, win)
    end
  end

  -- 调试信息
  vim.notify("WindowPicker: total=" .. #wins .. " filtered=" .. #filtered, vim.log.levels.INFO)

  if #filtered <= 1 then
    vim.notify("WindowPicker: only " .. #filtered .. " window(s), skipping", vim.log.levels.INFO)
    return
  end

  table.sort(filtered, function(a, b)
    local pos_a = vim.api.nvim_win_get_position(a)
    local pos_b = vim.api.nvim_win_get_position(b)
    if pos_a[1] == pos_b[1] then
      return pos_a[2] < pos_b[2]
    end
    return pos_a[1] < pos_b[1]
  end)

  local labels = {}
  local label_map = {}
  for i = 1, math.min(#filtered, #opts.labels) do
    local label = opts.labels:sub(i, i)
    labels[filtered[i]] = label
    label_map[label] = filtered[i]
  end

  local float_wins = {}
  for _, win in ipairs(filtered) do
    if labels[win] then
      local ok, fw = pcall(M._create_float, win, labels[win], opts)
      if ok then
        table.insert(float_wins, fw)
        vim.notify("WindowPicker: created float for win " .. win .. " with label '" .. labels[win] .. "'", vim.log.levels.INFO)
      else
        vim.notify("WindowPicker: failed to create float for win " .. win, vim.log.levels.ERROR)
      end
    end
  end

  vim.cmd("redraw")

  local char = vim.fn.getchar()
  local ch = type(char) == "number" and vim.fn.nr2char(char) or char

  vim.notify("WindowPicker: pressed '" .. ch .. "'", vim.log.levels.INFO)

  for _, fw in ipairs(float_wins) do
    if vim.api.nvim_win_is_valid(fw) then
      vim.api.nvim_win_close(fw, true)
    end
  end

  local target = label_map[ch]
  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
    vim.notify("WindowPicker: jumped to win " .. target, vim.log.levels.INFO)
  else
    vim.notify("WindowPicker: no target for '" .. ch .. "'", vim.log.levels.WARN)
  end
end

function M._create_float(win, label, opts)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. label .. " " })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  -- 计算居中位置，确保不为负数
  local float_width = 3
  local float_height = 1
  local row = math.max(0, math.floor((height - float_height) / 2))
  local col = math.max(0, math.floor((width - float_width) / 2))

  local float_opts = {
    relative = "win",
    win = win,
    row = row,
    col = col,
    width = float_width,
    height = float_height,
    style = opts.float.style,
    border = opts.float.border,
    focusable = false,
    noautocmd = true,
  }

  local fw = vim.api.nvim_open_win(buf, false, float_opts)
  vim.api.nvim_set_option_value("winhl", "Normal:" .. opts.float.highlight, { win = fw })
  return fw
end

return M
