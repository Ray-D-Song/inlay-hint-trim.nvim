local M = {}

local handler = require("inlay-hint-trim.handler")

-- Setup function to be called by users
function M.setup(opts)
  handler.setup(opts)
end

-- Disable the plugin
function M.disable()
  handler.disable()
end

return M
