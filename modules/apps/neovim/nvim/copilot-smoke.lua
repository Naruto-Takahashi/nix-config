-- Copilot smoke test
-- Open this file, move to one of the TODO blocks, enter Insert mode, then run:
--   :Copilot suggestion next
-- If a suggestion appears, accept it with <M-l>.

local M = {}

local function normalize(text)
  -- TODO: lowercase, replace non-alphanumeric runs with "-", trim edge "-"
  return text
end

function M.slugify(text)
  return normalize(text)
end

function M.retry(fn, attempts)
  -- TODO: call fn up to attempts times and return the first non-nil result
  return fn(), attempts
end

function M.status_message(ok, message)
  if ok then
    -- TODO: return "ready"
    return message
  end

  -- TODO: return "failed: <message>"
  return message
end

return M
