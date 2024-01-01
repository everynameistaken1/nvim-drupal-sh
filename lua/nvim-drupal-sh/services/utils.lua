local status_Q, queries = pcall(require, "nvim-drupal-sh.helpers.queries")
if not status_Q then
  return
end

local status_H, helpers = pcall(require, "nvim-drupal-sh.helpers.helpers")
if not status_Q then
  return
end

local function createParamDecl(varName, namespace, type)
  local paramDecl = {}
  table.insert(paramDecl, "* @param " .. namespace .. " $" .. varName)
  table.insert(paramDecl, type .. " $" .. varName)
  return paramDecl
end


local function createVarDecl(varName, namespace, type)
  local varDecl = {}
  table.insert(varDecl, "/**")
  table.insert(varDecl, "* " .. varName)
  table.insert(varDecl, "* @var " .. namespace .. " " .. type)
  table.insert(varDecl, "*/")
  table.insert(varDecl, "private $" .. varName)
  return varDecl
end

local F = {}

function F.getVarName(service)
  local iter = 1
  local varName = ""
  for m in string.gmatch(service, "(%w+)") do
    if iter == 1 then
      varName = varName .. m
    else
      local first = string.upper(m.sub(m, 1, 1))
      local rest = m.sub(m, 2, -1)
      local firstCap = first .. rest
      varName = varName .. firstCap
    end
    iter = iter + 1
  end
  return varName
end

function F.addService(serviceName, serviceNamespace, typeName, bufnr)
  local import = "use " .. serviceNamespace .. ";"
  local param = createParamDecl(serviceName, serviceNamespace, typeName)
  local declareVar = createVarDecl(serviceName, serviceNamespace, typeName)
  local initializeVar = "$this->" .. serviceName .. " = $" .. serviceName
  local infoTable = { import, param, declareVar, initializeVar }
  for _, value in pairs(infoTable) do
    print(vim.inspect(value))
  end
end


function F.testFunc(serviceName, serviceNamespace, typeName, bufnr)
  local import = "use " .. serviceNamespace .. ";"
  local param = createParamDecl(serviceName, serviceNamespace, typeName)
  local declareVar = createVarDecl(serviceName, serviceNamespace, typeName)
  local initializeVar = "$this->" .. serviceName .. " = $" .. serviceName
  local res = helpers.ConstructorExists(bufnr)
  print(vim.inspect(res))
  -- vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { import })
  -- for _, v in pairs(param) do
  --   vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { v })
  -- end
  -- for _, v in pairs(declareVar) do
  --   vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { v })
  -- end
  -- vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { initializeVar })
  -- vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { queries.test })
end

return F
