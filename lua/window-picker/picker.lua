local config = require("window-picker.config")

local M = {}

local function is_normal_window(win)
	if not vim.api.nvim_win_is_valid(win) then
		return false
	end

	local cfg = vim.api.nvim_win_get_config(win)

	-- 排除浮动窗口
	if cfg.relative ~= "" then
		return false
	end

	return true
end

function M.pick()
	local opts = config.get()

	local tabpage = vim.api.nvim_get_current_tabpage()
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)

	local filtered = {}

	for _, win in ipairs(wins) do
		if is_normal_window(win) and opts.filter(win) then
			table.insert(filtered, win)
		end
	end

	vim.notify(string.format("WindowPicker: total=%d filtered=%d", #wins, #filtered), vim.log.levels.INFO)

	if #filtered <= 1 then
		vim.notify("WindowPicker: only " .. #filtered .. " window(s)", vim.log.levels.INFO)
		return
	end

	table.sort(filtered, function(a, b)
		local pa = vim.api.nvim_win_get_position(a)
		local pb = vim.api.nvim_win_get_position(b)

		if pa[1] == pb[1] then
			return pa[2] < pb[2]
		end

		return pa[1] < pb[1]
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
		local label = labels[win]

		if label then
			local ok, result = pcall(M._create_float, win, label, opts)

			if ok then
				table.insert(float_wins, result)
			else
				vim.notify("WindowPicker create float failed:\n" .. tostring(result), vim.log.levels.ERROR)
			end
		end
	end

	vim.cmd("redraw")

	local ok, char = pcall(vim.fn.getchar)

	if not ok then
		for _, fw in ipairs(float_wins) do
			if vim.api.nvim_win_is_valid(fw) then
				vim.api.nvim_win_close(fw, true)
			end
		end
		return
	end

	local ch = type(char) == "number" and vim.fn.nr2char(char) or char

	for _, fw in ipairs(float_wins) do
		if vim.api.nvim_win_is_valid(fw) then
			vim.api.nvim_win_close(fw, true)
		end
	end

	local target = label_map[ch]

	if target and vim.api.nvim_win_is_valid(target) then
		vim.api.nvim_set_current_win(target)
	end
end

function M._create_float(win, label, opts)
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. label .. " " })

	vim.bo[buf].bufhidden = "wipe"

	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)

	local float_width = 3
	local float_height = 1

	local row = math.max(0, math.floor((height - float_height) / 2))

	local col = math.max(0, math.floor((width - float_width) / 2))

	local fw = vim.api.nvim_open_win(buf, false, {
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
		zindex = 300,
	})

	vim.wo[fw].winhl = "Normal:" .. opts.float.highlight

	return fw
end

return M
