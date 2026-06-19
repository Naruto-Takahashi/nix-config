-- Copilot smoke test
-- Open this file in Neovim and press <M-l> while editing a TODO block.

local M = {}

--- Normalize a label into a slug.
--- TODO: lowercase the string, replace non-alphanumeric runs with "-", and trim leading/trailing "-"
---@param text string
---@return string
function M.slugify(text)
end

--- Retry a callback until it returns a non-nil value.
--- TODO: stop after `attempts` tries and return the last error if all attempts fail
---@param fn fun(): any
---@param attempts integer
---@return any
function M.retry(fn, attempts)
end

--- Render a one-line status message.
--- TODO: return "ready" when ok is true, otherwise return "failed: <message>"
---@param ok boolean
---@param message string
---@return string
function M.status_message(ok, message)
end

return M
