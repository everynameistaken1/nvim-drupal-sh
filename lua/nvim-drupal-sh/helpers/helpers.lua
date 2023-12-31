local queries = require "nvim-drupal-sh.helpers.queries"
local M = {}

function M.ConstructorExists(bufnr)
  local myQuery = queries.ConstructorExists
  local phpFile = M.readAll(M.GetFilePath(bufnr))
  local phpParser = vim.treesitter.get_string_parser(phpFile, "php", {})
  local phpTree = phpParser:parse()
  local phpRoot = phpTree[1]:root()
  local matches = vim.treesitter.query.parse("php", myQuery)
  local res = false
  for _, capture, _ in matches:iter_matches(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    for _, node in pairs(capture) do
      if node:parent():type() == "method_declaration" then
        if vim.treesitter.get_node_text(node, phpFile) == "__construct" then
          res = true
        end
      end
    end
  end
  return res
end

function M.ConstructorArity(bufnr)
  local myQuery = queries.CapturePromotingParamsInConstructor
  local phpFile = M.readAll(M.GetFilePath(bufnr))
  local phpParser = vim.treesitter.get_string_parser(phpFile, "php", {})
  local phpTree = phpParser:parse()
  local phpRoot = phpTree[1]:root()
  local query = vim.treesitter.query.parse("php", myQuery)
  local paramCount = 0
  for id, _, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "promParam" then
      paramCount = paramCount + 1
    end
  end
  return paramCount
end

function M.InsertDependencyLocation(bufnr)
local myQuery = [[
(
 (method_declaration
  name: (name) @methodName (#eq? @methodName "__construct")
  parameters: (formal_parameters) @formParam
 )
) @res
]]
  local phpFile = M.readAll(M.GetFilePath(bufnr))
  local phpParser = vim.treesitter.get_string_parser(phpFile, "php", {})
  local phpTree = phpParser:parse()
  local phpRoot = phpTree[1]:root()
  local query = vim.treesitter.query.parse("php", myQuery)
  -- local rowS, colS, rowE, colE = 0, 0, 0, 0
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "formParam" then
      -- rangeTable = { capture:range() }
      node = capture
    end
  end
  return node:range()
end

function M.readAll(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

-- Functions work
function M.GetFileExtension(bufnr)
  -- File extension only
  -- local filename = vim.api.nvim_buf_get_name(bufnr)
  -- return string.match(filename, "[^%p]+$")
  return vim.fn.getbufvar(bufnr, '&filetype')
end

function M.GetFilenameWithoutExtension(bufnr)
  -- Filename without extension
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return string.match(filename, "([^\\/]+)%p%w+$")
end

function M.GetFilePath(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

function M.CloseAllFloatingWindows()
  local closed_windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then        -- is_floating_window?
      vim.api.nvim_win_close(win, false) -- do not force
      table.insert(closed_windows, win)
    end
  end
  local closedBufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bufInfo = vim.fn.getbufinfo(buf)
    if bufInfo[1].hidden == 1 and bufInfo[1].changed == 0 then -- Not loaded?
      table.insert(closedBufs, buf)
      vim.api.nvim_buf_delete(buf, { force = false, unload = false })
    end
  end
  -- print(string.format('Closed %d windows: %s', #closed_windows, vim.inspect(closed_windows)))
  -- print(string.format('Closed %d buffers: %s', #closedBufs, vim.inspect(closedBufs)))
end

return M
