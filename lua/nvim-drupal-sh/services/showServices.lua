local status_H, helpers = pcall(require, "nvim-drupal-sh.helpers.helpers")
if not status_H then
  print("Could not load helpers")
  return
end
local status_Q, queries = pcall(require, "nvim-drupal-sh.helpers.queries")
if not status_Q then
  print("Could not load queries")
  return
end

local status_U, utils = pcall(require, "nvim-drupal-sh.services.utils")
if not status_U then
  return
end

local M = {}


local function createListOfCoreServices()
  local ymlQuery = queries.StandardServices
  local serviceFileAsString = helpers.readAll(
    "/var/www/html/" .. vim.env.PROJECT_NAME .. "/web/core/core.services.yml")
  local ymlParser = vim.treesitter.get_string_parser(serviceFileAsString, "yaml", {})
  local ymlTree = ymlParser:parse()
  local ymlRoot = ymlTree[1]:root()
  local matches = vim.treesitter.query.parse("yaml", ymlQuery)
  local res = {}
  for _, capture, _ in matches:iter_matches(ymlRoot, serviceFileAsString, ymlRoot:start(), ymlRoot:end_()) do
    local classNameSpace = vim.treesitter.get_node_text(capture[4], serviceFileAsString)
    res[vim.treesitter.get_node_text(capture[2], serviceFileAsString, {})] = classNameSpace
  end
  return res
end

local function coreServiceExists(service)
  local res = createListOfCoreServices()
  for k, _ in pairs(res) do
    if k == service then
      return true
    end
  end
  return false
end

function M.serviceExists(service)
  if service == nil or service == "" then
    print("Service name must be specified")
    return
  end
  local res = coreServiceExists(service)
  if res then
    print(service .. " exists")
    return
  end
  print("Service not found")
end

function M.getStandardServices()
  local affectedBufr = vim.api.nvim_get_current_buf()
  local services = createListOfCoreServices()
  local ui = vim.api.nvim_list_uis()[1]
  local size = { width = math.floor(ui.width / 4) * 3, height = math.floor(ui.height / 4) * 3 }
  local bufnr = vim.api.nvim_create_buf(false, true)
  local opts = {
    relative = "editor",
    width = size.width,
    height = size.height,
    col = math.floor(ui.width / 4 / 2),
    row = math.floor(ui.height / 4 / 2),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = "Standard Services"
  }
  local winnr = vim.api.nvim_open_win(bufnr, true, opts)
  local printServices = function()
    local serviceList = {}
    for k, v in pairs(services) do
      table.insert(serviceList, k .. " " .. v)
    end
    table.insert(serviceList, tostring(affectedBufr))
    vim.api.nvim_buf_set_lines(0, 1, 1, false, serviceList)
  end
  vim.api.nvim_win_call(winnr, printServices)
end

function M.chooseService()
  local bufnr = tonumber(vim.api.nvim_buf_get_lines(0, -2, -1, false)[1])
  if not bufnr then
    vim.notify("Error: Could not find bufnr, make sure to run 'Show Standard Services' first.", vim.log.levels.ERROR, {})
    return
  end
  local status_ServiceInfo, service, varName, namespace, typeName = utils.GetServiceInfo()
  if not status_ServiceInfo then
    return
  end
  if not utils.HandleServicePick(bufnr, service, varName, namespace, typeName) then
    return
  end
  helpers.CloseAllFloatingWindows()
  vim.api.nvim_win_call(0, vim.lsp.buf.format)
end

function M.createDependencyInjectionMethods()
  local bufnr = vim.api.nvim_win_get_buf(0)
  if not bufnr then
    return
  end
  utils.createConstructorAndStaticCreateForBuf(bufnr)
end

return M
