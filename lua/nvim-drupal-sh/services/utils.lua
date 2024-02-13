local status_Q, queries = pcall(require, "nvim-drupal-sh.helpers.queries")
local scaffolding       = require("nvim-drupal-sh.helpers.scaffolding")
if not status_Q then
  return
end

local status_H, helpers = pcall(require, "nvim-drupal-sh.helpers.helpers")
if not status_H then
  return
end

local function createPromotedParamDecl(varName, type)
  return "private readonly " .. type .. " $" .. varName .. ","
end


local F = {}

function F.GetServiceInfo()
  local status_CursorText, cursorText = F.GetCursorText()
  if not status_CursorText or cursorText == nil then
    return false
  end
  local status_Service, service = F.GetService(cursorText)
  if not status_Service or service == nil then
    return false
  end
  local status_VarName, varName = F.GetVarName(service)
  if not status_VarName or varName == nil then
    return false
  end
  service = string.sub(service, 1, service:len() - 1)
  local status_Namespace, namespace = F.GetNamespace(cursorText, service)
  if not status_Namespace or namespace == nil then
    return false
  end
  local status_TypeName, typeName = F.GetTypeName(namespace)
  if not status_TypeName or typeName == nil then
    return false
  end
  return true, service, varName, namespace, typeName
end

function F.HandleServicePick(bufnr, service, varName, namespace, typeName)
  local file = helpers.GetFilenameWithoutExtension(bufnr)
  if string.len(file) > 4 and string.sub(file, string.len(file) - 3, string.len(file)) == "Form" then
    if not F.addServiceIntoFormOrController(service, varName, namespace, typeName, bufnr) then
      return false
    end
  elseif string.len(file) > 5 and string.sub(file, string.len(file) - 4, string.len(file)) == "Block" then
    if not F.addServiceIntoBlock(service, varName, namespace, typeName, bufnr) then
      return false
    end
  elseif string.len(file) > 10 and string.sub(file, string.len(file) - 9, string.len(file)) == "Controller" then
    if not F.addServiceIntoFormOrController(service, varName, namespace, typeName, bufnr) then
      return false
    end
  else
    if not F.addServiceIntoService(varName, namespace, typeName, bufnr) then
      return false
    end
  end

  return true
end

function F.GetCursorText()
  local cursorText = vim.api.nvim_get_current_line()
  if not helpers.StringSet(cursorText, 2) then
    vim.notify("Error: Couldn't find service", vim.log.levels.ERROR, {})
    return false
  end
  return true, cursorText
end

function F.GetService(cursorText)
  local service = cursorText.match(cursorText, "([^ ]+ )")
  if not helpers.StringSet(service, 2) then
    vim.notify("Error: Could not find service", vim.log.levels.ERROR, {})
    return false
  end
  return true, service
end

function F.GetVarName(service)
  local varName = F.getVarName(service)
  if not helpers.StringSet(varName, 2) then
    vim.notify("Error: Could not find service", vim.log.levels.ERROR, {})
    return false
  end
  return true, varName
end

function F.GetNamespace(cursorText, service)
  local namespace = cursorText.sub(cursorText, string.len(service) + 1, -1)
  if not helpers.StringSet(namespace, 2) then
    vim.notify("Error: Could not find service", vim.log.levels.ERROR, {})
    return false
  end
  return true, namespace
end

function F.GetTypeName(namespace)
  local typeName
  for m in string.gmatch(namespace, "([^\\]+)") do
    typeName = m
  end
  if not helpers.StringSet(typeName, 2) then
    vim.notify("Error: Could not find service", vim.log.levels.ERROR, {})
    return false
  end
  return true, typeName
end

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

local function createContainerInjection(serviceName)
  return "$container->get('" .. serviceName .. "'),"
end


function F.addServiceIntoBlock(serviceName, varName, serviceNamespace, typeName, bufnr)
  local staticCreateExists = helpers.StaticCreateExists(bufnr)
  local constructorExists = helpers.ConstructorExists(bufnr)
  if staticCreateExists == false or constructorExists == false then
    vim.notify("Error: Class needs constructor or static create method", vim.log.levels.ERROR, {})
    return false
  end
  local staticCreateParamsCount = helpers.StaticCreateParamCount(bufnr)
  if staticCreateParamsCount < 4 then
    vim.notify(
      "Error: You need to accept 'ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition' as params in Class::create",
      vim.log.levels.ERROR, {})
    return false
  end
  local constructorParamsCount = helpers.constructorParamsCount(bufnr)
  if constructorParamsCount < 3 then
    vim.notify(
      "Error: You need to accept 'array $configuration, $plugin_id, $plugin_definition,' as params in Class::__construct",
      vim.log.levels.ERROR, {})
    return false
  end
  local _, _, rowE, _ = helpers.StaticCreateReturnParamsRange(bufnr)
  if not helpers.addCreateInj(bufnr, { createContainerInjection(serviceName) }, rowE) then
    vim.notify("Warning: Create parameter already exists", vim.log.levels
      .WARN, {})
    return false
  end
  if not F.addServiceIntoService(varName, serviceNamespace, typeName, bufnr) then
    return false
  end
  return true
end

function F.addServiceIntoFormOrController(serviceName, varName, serviceNamespace, typeName, bufnr)
  local staticCreateExists = helpers.StaticCreateExists(bufnr)
  local constructorExists = helpers.ConstructorExists(bufnr)
  if staticCreateExists == false or constructorExists == false then
    vim.notify("Error: Class needs constructor or static create method", vim.log.levels.ERROR, {})
    return false
  end
  local _, _, rowE, _ = helpers.StaticCreateReturnParamsRange(bufnr)
  if not helpers.addCreateInj(bufnr, { createContainerInjection(serviceName) }, rowE) then
    vim.notify("Warning: Create parameter already exists", vim.log.levels
      .WARN, {})
    return false
  end
  if not F.addServiceIntoService(varName, serviceNamespace, typeName, bufnr) then
    return false
  end
  return true
end

function F.addServiceIntoService(serviceName, serviceNamespace, typeName, bufnr)
  local import = "use" .. serviceNamespace .. ";"
  local param = createPromotedParamDecl(serviceName, typeName)
  local CExists = helpers.ConstructorExists(bufnr)
  if not CExists then
    vim.notify("Error: Found no constructor", vim.log.levels.ERROR, {})
    return false
  end
  local rowS, _, rowE, _ = helpers.ConstructorParamsRange(bufnr)
  if rowS == rowE or rowS > rowE then
    vim.notify("Error: Command expects constructors parentheses to exist on different lines.", vim.log.levels.ERROR, {})
    return false
  end
  if not helpers.addParam(bufnr, { param }, rowE) then
    vim.notify("Warning: Constructor parameter already exists", vim.log.levels
      .WARN, {})
    return false
  end
  if not helpers.addImport(bufnr, { import }) then
    vim.notify("Warning: Either use statement already exists or couldn't find namespace declaration", vim.log.levels
      .WARN, {})
    return false
  end
  return true
end

local function addInterfaceIfNeeded(bufnr)
  local interfaceExists = helpers.InterfaceExists(bufnr)
  if interfaceExists then
    return
  end
  local _, _, r2, c2 = helpers.ClassBaseRange(bufnr)
  vim.api.nvim_buf_set_text(bufnr, r2, c2, r2, c2, scaffolding.ContainerFactoryPluginInterface)
end

local function createConstructorAndCreateForForm(bufnr)
    if helpers.ConstructorExists(bufnr) then
      vim.notify("Error: Constructor already exists", vim.log.levels.ERROR, {})
      return
    end
    if helpers.StaticCreateExists(bufnr) then
      vim.notify("Error: Static create already exists", vim.log.levels.ERROR, {})
      return
    end
    helpers.addConstructorForControllerOrFormOrService(bufnr)
    helpers.addStaticCreateForControllerOrForm(bufnr)
    if not helpers.addImport(bufnr, scaffolding.UseContainerInterface) then
      vim.notify("Warning: Either use statement already exists or couldn't find namespace declaration",
        vim.log.levels.WARN, {})
      return
    end
end

local function createConstructorAndCreateForBlock(bufnr)
    if helpers.ConstructorExists(bufnr) then
      vim.notify("Error: Constructor already exists", vim.log.levels.ERROR, {})
      return
    end
    if helpers.StaticCreateExists(bufnr) then
      vim.notify("Error: Static create already exists", vim.log.levels.ERROR, {})
      return
    end
    helpers.addConstructorForBlock(bufnr)
    helpers.addStaticCreateForBlock(bufnr)
    if not helpers.addImport(bufnr, scaffolding.UseContainerInterface) then
      vim.notify("Warning: Either use statement already exists or couldn't find namespace declaration",
        vim.log.levels.WARN, {})
      return
    end
    if not helpers.addImport(bufnr, scaffolding.UseContainerFactoryPluginInterface) then
      vim.notify("Warning: Either use statement already exists or couldn't find namespace declaration",
        vim.log.levels.WARN, {})
      return
    end
    addInterfaceIfNeeded(bufnr)
end

local function createConstructorAndCreateForController(bufnr)
    if helpers.ConstructorExists(bufnr) then
      vim.notify("Error: Constructor already exists", vim.log.levels.ERROR, {})
      return
    end
    if helpers.StaticCreateExists(bufnr) then
      vim.notify("Error: Static create already exists", vim.log.levels.ERROR, {})
      return
    end
    helpers.addConstructorForControllerOrFormOrService(bufnr)
    helpers.addStaticCreateForControllerOrForm(bufnr)
    if not helpers.addImport(bufnr, scaffolding.UseContainerInterface) then
      vim.notify("Warning: Either use statement already exists or couldn't find namespace declaration",
        vim.log.levels.WARN, {})
      return
    end
end

local function createConstructorForService(bufnr)
    if helpers.ConstructorExists(bufnr) then
      vim.notify("Error: Constructor already exists", vim.log.levels.ERROR, {})
      return
    end
    helpers.addConstructorForControllerOrFormOrService(bufnr)
end

function F.createConstructorAndStaticCreateForBuf(bufnr)
  local file = helpers.GetFilenameWithoutExtension(bufnr)
  if string.len(file) > 4 and string.sub(file, string.len(file) - 3, string.len(file)) == "Form" then
    createConstructorAndCreateForForm(bufnr)
  elseif string.len(file) > 5 and string.sub(file, string.len(file) - 4, string.len(file)) == "Block" then
    createConstructorAndCreateForBlock(bufnr)
  elseif string.len(file) > 10 and string.sub(file, string.len(file) - 9, string.len(file)) == "Controller" then
    createConstructorAndCreateForController(bufnr)
  else
    createConstructorForService(bufnr)
  end
end

return F
