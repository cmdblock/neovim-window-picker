local config = require("window-picker.config")
local picker = require("window-picker.picker")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

function M.pick()
  picker.pick()
end

return M
