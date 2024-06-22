local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local actionsState = require("telescope.actions.state")
local telescopeUtils = require("telescope.previewers.utils")
local config = require("telescope.config").values

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

local function splitStringToTable(myString, sep)
  if sep == nil then
    sep = ", "
  end

  local t = {}
  local iter = 0
  for str in string.gmatch(myString, "([^"..sep.."]+)") do
    table.insert(t, "- " .. str)
    iter = iter + 1
  end

  if iter == 0 then
    table.insert(t, "- " .. myString)
  end

  return t
end

local function GetServiceArgs(node, serviceFileAsString)
  for serviceNode in node:iter_children() do
    if serviceNode:type() == "block_mapping" then
      for potentialArgsNode in serviceNode:iter_children() do
        if potentialArgsNode:type() == "block_mapping_pair" then
          local potentialArgsField = potentialArgsNode:field("key")[1]
          local field = vim.treesitter.get_node_text(potentialArgsField, serviceFileAsString, {})
          if field == "arguments" then
            local argsNode = potentialArgsNode:field("value")[1]
            if argsNode:type() == "flow_node" then
              local argsString = vim.treesitter.get_node_text(argsNode, serviceFileAsString, {})
              argsStringWithoutSquareBrackets = string.sub(argsString, 2, string.len(argsString) - 1)
              return splitStringToTable(argsStringWithoutSquareBrackets)
            end
            local t = {}
            if argsNode:type() == "block_node" then
              local argsNodeInListFormat = argsNode:child(0)
              for argInListNode in argsNodeInListFormat:iter_children() do
                local argInListStrippedNode = argInListNode:child(1)
                local argsString = vim.treesitter.get_node_text(argInListStrippedNode, serviceFileAsString, {})
                table.insert(t, "- " .. argsString)
              end
            end
            return t
          end
        end
      end
    end
  end
  return {"No Arguments"}
end

local function createListOfCoreServices()
	local ymlQuery = queries.StandardServices
	local serviceFileAsString = helpers.readAll(
		"/var/www/html/" .. vim.env.PROJECT_NAME .. "/web/core/core.services.yml")
	local ymlParser = vim.treesitter.get_string_parser(serviceFileAsString, "yaml", {})
	local ymlTree = ymlParser:parse()
	local ymlRoot = ymlTree[1]:root()
	local matches = vim.treesitter.query.parse("yaml", ymlQuery)
	local res = {}
  local additional = {}
	for _, capture, _ in matches:iter_matches(ymlRoot, serviceFileAsString, ymlRoot:start(), ymlRoot:end_(), {}) do
		local classNameSpace = vim.treesitter.get_node_text(capture[4], serviceFileAsString)
		res[vim.treesitter.get_node_text(capture[2], serviceFileAsString, {})] = classNameSpace
    local args = GetServiceArgs(capture[5], serviceFileAsString)
    additional[vim.treesitter.get_node_text(capture[2], serviceFileAsString, {})] = args
	end
	return res, additional
end

local function createPreviewTable(data)
  local previewTable = {}
  table.insert(previewTable, "Service: ")
  table.insert(previewTable, "  " .. data.value.name)
  table.insert(previewTable, "Variable Name: ")
  table.insert(previewTable, "  " .. data.value.varName)
  table.insert(previewTable, "Type Name: ")
  table.insert(previewTable, "  " .. data.value.typeName)
  table.insert(previewTable, "Namespace: ")
  table.insert(previewTable, "  " .. data.value.className)
  table.insert(previewTable, "Args: ")
  for _, val in pairs(data.value.args) do
    table.insert(previewTable, "  " .. val)
  end
  return previewTable
end

function M.showAndPick(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	local coreServicesTable, additional = createListOfCoreServices()
	local formattedServicesTable = {}
	for key, val in pairs(coreServicesTable) do
		local _, typeName = utils.GetTypeName(val)
		local service = {
			name = key,
			varName = utils.getVarName(key),
			typeName = typeName,
			className = val,
      args = additional[key]
		}
		table.insert(formattedServicesTable, service)
	end
	pickers.new(
	opts,
	{
		finder = finders.new_table({
		results = formattedServicesTable,
		entry_maker = function (entry)
			return {
				value = entry,
				display = entry.name,
				ordinal = entry.name
			}
		end
	}),
		sorter = config.generic_sorter(opts),
	previewer = previewers.new_buffer_previewer({
		title = "Service Details",
		define_preview = function (self, entry)
			vim.api.nvim_buf_set_lines(
				self.state.bufnr,
				0,
				0,
				true,
        createPreviewTable(entry)
			)
			telescopeUtils.highlighter(self.state.bufnr, "yaml")
		end
	}),
	attach_mappings = function (promptBufnr)
		actions.select_default:replace(function ()
			local selection = actionsState.get_selected_entry()
			actions.close(promptBufnr)
      if selection == nil then
        return true
      end
			utils.createConstructorAndStaticCreateForBuf(bufnr)
			utils.HandleServicePick(bufnr, selection.value.name, selection.value.varName, selection.value.className, selection.value.typeName)
		end)
		return true
	end
	}
	):find()
end

return M
