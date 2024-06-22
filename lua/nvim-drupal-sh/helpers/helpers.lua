local status_Q, queries = pcall(require, "nvim-drupal-sh.helpers.queries")
if not status_Q then
  print("Could not load queries.")
  return
end

local status_S, scaffolding = pcall(require, "nvim-drupal-sh.helpers.scaffolding")
if not status_S then
  print("Could not load scaffolding.")
  return
end

local M = {}

function M.StringSet(val, minLength)
  if val == nil or type(val) ~= "string" or string.len(val) < minLength then
    return false
  end
  return true
end

function M.GetPhpRoot(bufnr)
  local phpLines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local phpString = ""
  for _, v in ipairs(phpLines) do
    phpString = phpString .. v .. "\n"
  end
  local phpParser = vim.treesitter.get_string_parser(phpString, "php", {})
  local phpTree = phpParser:parse()
  return phpString, phpTree[1]:root()
end

function M.CreateParamExists(bufnr, serviceName)
  local queryString = queries.CreateParamExists
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", queryString)
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "name" then
      if vim.treesitter.get_node_text(capture, phpFile, {}) .. "," == serviceName then
        return true
      end
    end
  end
  return false
end

function M.ConstructorParamsExists(bufnr, param)
  local queryString = queries.ConstructorParamExists
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", queryString)
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "param" then
      if vim.treesitter.get_node_text(capture, phpFile, {}) .. "," == param then
        return true
      end
    end
  end
  return false
end

function M.NamespaceNameExists(bufnr, import)
  local queryString = queries.NamespaceName
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", queryString)
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "name" then
      if vim.treesitter.get_node_text(capture, phpFile, {}) == import then
        return true
      end
    end
  end
  return false
end

function M.InterfaceExists(bufnr)
  local myQuery = queries.InterfaceExists
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  for id, _, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "interface" then
      return true
    end
  end
  return false
end

function M.ConstructorExists(bufnr)
  local myQuery = queries.ConstructorExists
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  for _, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = vim.treesitter.get_node_text(capture, phpFile)
    if name == "__construct" then
      return true
    end
  end
  return false
end

function M.constructorParamsCount(bufnr)
  local myQuery = queries.ConstructorParamsCount
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local count = 0
  for id, _, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "param" then
      count = count + 1
    end
  end
  return count
end

function M.StaticCreateParamCount(bufnr)
  local myQuery = queries.StaticCreateParamCount
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local count = 0
  for id, _, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "param" then
      count = count + 1
    end
  end
  return count
end

function M.StaticCreateExists(bufnr)
  local myQuery = queries.StaticCreateExists
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  for id, _, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "name" then
      return true
    end
  end
  return false
end

function M.ClassBaseRange(bufnr)
  local myQuery = queries.GetBaseRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "baseClause" then
      node = capture
    end
  end
  return node:range()
end

function M.StaticCreateReturnParamsRange(bufnr)
  local myQuery = queries.StaticCreateReturnRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "args" then
      node = capture
    end
  end
  return node:range()
end

function M.addConstructorForControllerOrFormOrService(bufnr)
  local myQuery = queries.ClassRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "declList" then
      node = capture
    end
  end
  local r1, _, _, _ = node:range()
  vim.api.nvim_buf_set_lines(bufnr, r1 + 1, r1 + 1, false, scaffolding.ServiceAndFormConstructor)
end

function M.addConstructorForBlock(bufnr)
  local myQuery = queries.ClassRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "declList" then
      node = capture
    end
  end
  local r1, _, _, _ = node:range()
  vim.api.nvim_buf_set_lines(bufnr, r1 + 1, r1 + 1, false, scaffolding.BlockConstructor)
end

function M.addStaticCreateForControllerOrForm(bufnr)
  local myQuery = queries.ConstructorRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "constructor" then
      node = capture
    end
  end
  local _, _, r2, _ = node:range()
  vim.api.nvim_buf_set_lines(bufnr, r2 + 1, r2 + 1, false, scaffolding.ControllerOrFormStaticCreate)
end

function M.addStaticCreateForBlock(bufnr)
  local myQuery = queries.ConstructorRange
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "constructor" then
      node = capture
    end
  end
  local _, _, r2, _ = node:range()
  vim.api.nvim_buf_set_lines(bufnr, r2 + 1, r2 + 1, false, scaffolding.BlockStaticCreate)
end

function M.addParam(bufnr, param, row)
  if M.ConstructorParamsExists(bufnr, param[1]) then
    return false
  end
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, param)
  return true
end

function M.addCreateInj(bufnr, serviceName, row)
  if M.CreateParamExists(bufnr, serviceName[1]) then
    return false
  end
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, serviceName)
  return true
end

function M.addImport(bufnr, import)
  if M.NamespaceNameExists(bufnr, import[1]) then
    return false
  end
  local myQuery = queries.Namespace
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node = nil
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "namespace" then
      node = capture
    end
  end
  if node == nil then
    return false
  end
  local _, _, r2, _ = node:range()
  vim.api.nvim_buf_set_lines(bufnr, r2 + 2, r2 + 2, false, import)
  return true
end

function M.ConstructorParamsRange(bufnr)
  local myQuery = queries.ServiceInjectionLocation
  local phpFile, phpRoot = M.GetPhpRoot(bufnr)
  local query = vim.treesitter.query.parse("php", myQuery)
  local node
  for id, capture, _ in query:iter_captures(phpRoot, phpFile, phpRoot:start(), phpRoot:end_()) do
    local name = query.captures[id]
    if name == "formParam" then
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

function M.GetFilenameWithoutExtension(bufnr)
  -- Filename without extension
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return string.match(filename, "([^\\/]+)%p%w+$")
end

return M
