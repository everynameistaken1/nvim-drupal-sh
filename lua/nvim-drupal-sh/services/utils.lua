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

return F
