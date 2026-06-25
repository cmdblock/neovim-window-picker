local config = require("window-picker.config")

-- 模块表，用于导出本模块的公共函数
local M = {}

--- 判断窗口是否为普通窗口（非浮动窗口）
-- @param win number 窗口 ID
-- @return boolean 如果是普通窗口返回 true，否则返回 false
local function is_normal_window(win)
	-- 检查窗口是否有效，无效则返回 false
	if not vim.api.nvim_win_is_valid(win) then
		return false
	end

	-- 获取窗口的配置信息
	local cfg = vim.api.nvim_win_get_config(win)

	-- 排除浮动窗口（浮动窗口的 relative 字段不为空字符串）
	if cfg.relative ~= "" then
		return false
	end

	-- 是普通窗口，返回 true
	return true
end

--- 主入口：显示窗口字母提示并等待用户选择
-- 无参数
-- 无返回值
function M.pick()
	-- 从配置模块获取当前生效的配置选项
	local opts = config.get()

	-- 获取当前标签页的句柄
	local tabpage = vim.api.nvim_get_current_tabpage()
	-- 获取当前标签页中所有的窗口列表
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)

	-- 过滤出参与跳转的普通窗口
	local filtered = {}
	for _, win in ipairs(wins) do
		-- 只保留普通窗口且通过用户自定义过滤条件的窗口
		if is_normal_window(win) and opts.filter(win) then
			table.insert(filtered, win)
		end
	end

	-- 输出调试信息：总窗口数和过滤后的窗口数
	vim.notify(string.format("WindowPicker: total=%d filtered=%d", #wins, #filtered), vim.log.levels.INFO)

	-- 如果只有一个或更少的窗口，直接返回（无需跳转）
	if #filtered <= 1 then
		vim.notify("WindowPicker: only " .. #filtered .. " window(s)", vim.log.levels.INFO)
		return
	end

	-- 按窗口位置排序：先按行（从上到下），同行按列（从左到右）
	table.sort(filtered, function(a, b)
		-- 获取窗口 a 的位置（行, 列）
		local pa = vim.api.nvim_win_get_position(a)
		-- 获取窗口 b 的位置（行, 列）
		local pb = vim.api.nvim_win_get_position(b)

		-- 如果行相同，按列排序（从左到右）
		if pa[1] == pb[1] then
			return pa[2] < pb[2]
		end

		-- 按行排序（从上到下）
		return pa[1] < pb[1]
	end)

	-- 为每个窗口分配字母标签
	local labels = {}
	local label_map = {}
	-- 遍历过滤后的窗口，分配字母（不超过字母序列长度）
	for i = 1, math.min(#filtered, #opts.labels) do
		-- 从字母序列中取第 i 个字母
		local label = opts.labels:sub(i, i)

		-- 记录窗口对应的字母
		labels[filtered[i]] = label
		-- 记录字母对应的窗口
		label_map[label] = filtered[i]
	end

	-- 在每个窗口上创建浮动窗口显示字母
	local float_wins = {}
	for _, win in ipairs(filtered) do
		-- 获取当前窗口分配的字母
		local label = labels[win]

		-- 如果有分配字母，创建浮动窗口
		if label then
			-- 使用 pcall 捕获可能的错误
			local ok, result = pcall(M._create_float, win, label, opts)

			-- 如果创建成功，记录浮动窗口 ID
			if ok then
				table.insert(float_wins, result)
				print("create float window seucced")
			else
				-- 创建失败，输出错误信息
				vim.notify("WindowPicker create float failed:\n" .. tostring(result), vim.log.levels.ERROR)
			end
		end
	end

	-- 强制重绘屏幕，确保浮动窗口显示
	vim.cmd("redraw")

	-- 等待用户输入字母
	local ok, char = pcall(vim.fn.getchar)

	-- 如果用户按了 Esc 或中断，清理浮动窗口后返回
	if not ok then
		-- 关闭所有浮动窗口
		for _, fw in ipairs(float_wins) do
			if vim.api.nvim_win_is_valid(fw) then
				vim.api.nvim_win_close(fw, true)
			end
		end
		return
	end

	-- 将输入转换为字符（getchar 返回的是数字编码）
	local ch = type(char) == "number" and vim.fn.nr2char(char) or char

	-- 清理所有浮动窗口
	for _, fw in ipairs(float_wins) do
		if vim.api.nvim_win_is_valid(fw) then
			vim.api.nvim_win_close(fw, true)
		end
	end

	-- 跳转到用户选择的窗口
	local target = label_map[ch]

	-- 如果目标窗口有效，执行跳转
	if target and vim.api.nvim_win_is_valid(target) then
		vim.api.nvim_set_current_win(target)
	end
end

--- 在指定窗口上创建浮动窗口显示字母
-- @param win number 目标窗口 ID
-- @param label string 要显示的字母
-- @param opts table 配置选项（包含 float 样式配置）
-- @return number 浮动窗口 ID
function M._create_float(win, label, opts)
	-- 创建临时缓冲区（不绑定文件，可编辑）
	local buf = vim.api.nvim_create_buf(false, true)

	-- 写入字母内容（两侧加空格使其居中显示）
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. label .. " " })

	-- 设置缓冲区属性：关闭后自动销毁
	vim.bo[buf].bufhidden = "wipe"

	-- 获取目标窗口的尺寸（宽度和高度）
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)

	-- 浮动窗口尺寸（固定为 3x1，刚好容纳 " a "）
	local float_width = 3
	local float_height = 1

	-- 计算居中位置，确保不为负数
	local row = math.max(0, math.floor((height - float_height) / 2))
	local col = math.max(0, math.floor((width - float_width) / 2))

	-- 创建浮动窗口
	local fw = vim.api.nvim_open_win(buf, false, {
		relative = "win", -- 相对于目标窗口定位
		win = win, -- 目标窗口 ID
		row = row, -- 行偏移（居中）
		col = col, -- 列偏移（居中）
		width = float_width, -- 浮动窗口宽度
		height = float_height, -- 浮动窗口高度
		style = opts.float.style, -- 窗口样式（如 "minimal"）
		border = opts.float.border, -- 边框样式（如 "rounded"）
		focusable = false, -- 不可聚焦
		noautocmd = true, -- 不触发自动命令
		zindex = 300, -- 层级，确保显示在最上层
	})

	-- 应用高亮样式（将 Normal 高亮映射到 WindowPickerFloat）
	vim.wo[fw].winhl = "Normal:" .. opts.float.highlight

	-- 返回浮动窗口 ID
	return fw
end

-- 返回模块表，供外部调用
return M
