local M = {}

local function readAll(file)
  local f = assert(io.open(file, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local function createListOfCoreServices()
  local ymlQuery = [[
    (block_mapping_pair
      key: (flow_node
        (plain_scalar
          (string_scalar) @serviceColl (#eq? @serviceColl "services")
        )
      )
      value: (block_node
        (block_mapping
          (block_mapping_pair
            key: (flow_node
              (plain_scalar
                (string_scalar) @serviceName (#offset! @serviceName)
              )
            )
            value: (block_node
              (block_mapping
                (block_mapping_pair
                  key: (flow_node
                    (plain_scalar
                      (string_scalar) @classField (#eq? @classField "class")
                    )
                  )
                  value: (flow_node
                    (plain_scalar
                      (string_scalar) @classValue (#offset! @classValue)
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  ]]

  local serviceFileAsString = readAll("/root/.config/nvim-drupal-sh/lua/nvim-drupal-sh/services/core.services.yml")
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
  local services = createListOfCoreServices()
  local ui = vim.api.nvim_list_uis()[1]
  local size = { width = math.floor(ui.width / 2), height = math.floor(ui.height / 2) }
  local bufnr = vim.api.nvim_create_buf(false, true)
  local opts = {
    relative = "editor",
    width = size.width,
    height = size.height,
    col = (ui.width / 2) - (size.width / 2),
    row = (ui.height / 2) - (size.height / 2),
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
    vim.api.nvim_buf_set_lines(0, 1, 1, false, serviceList)
  end
  vim.api.nvim_win_call(winnr, printServices)
end
local function getVarName(service)
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
function M.chooseService()
  local cursorText = vim.api.nvim_get_current_line()
  local service = cursorText.match(cursorText, "([^ ]+ )")
  if type(service) == "string" and service ~= "" then
    local varName = getVarName(service)
    local namespace = cursorText.sub(cursorText, string.len(service) + 1, -1)
    local typeName = ""
    for m in string.gmatch(namespace, "([^\\]+)") do
      typeName = m
    end
    print(varName)
    print(typeName)
    print(namespace .. " " .. service)
  else
    print("Not found")
  end
end

return M
