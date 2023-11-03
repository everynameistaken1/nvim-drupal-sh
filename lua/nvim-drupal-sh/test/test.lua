local status_T, ts = pcall(require, "nvim-treesitter")
if not status_T then
  print("Ts_utils not found")
  return
end

local status_TU, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
if not status_TU then
  print("Ts_utils not found")
  return
end

local M = {}

function M.getStandardServices()
  local services = {
    "current_user",
    "database"
  }

  local ui = vim.api.nvim_list_uis()[1]
  local size = { width = math.floor(ui.width / 2), height = math.floor(ui.height / 2) }
  local bufnr = vim.api.nvim_create_buf(false, true)
  local opts = {
    relative = "editor",
    width = size.width,
    height = size.height,
    col = (ui.width/2)-(size.width/2),
    row = (ui.height/2)-(size.height/2),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = "Standard Services"
  }
  local winnr = vim.api.nvim_open_win(bufnr, 1, opts)
  local printServices = function()
      vim.api.nvim_buf_set_lines(0, 1, 1, nil, services)
  end
  vim.api.nvim_win_call(winnr, printServices)
end

function M.CloseAllFloatingWindows()
  local closed_windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then  -- is_floating_window?
      vim.api.nvim_win_close(win, false)  -- do not force
      table.insert(closed_windows, win)
    end
  end
  local closedBufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bufInfo = vim.fn.getbufinfo(buf)
    if bufInfo[1].hidden == 1 and bufInfo[1].changed == 0 then  -- Not loaded?
      table.insert(closedBufs, buf)
      vim.api.nvim_buf_delete(buf, {force = false, unload = false})
    end
  end
  print(string.format('Closed %d windows: %s', #closed_windows, vim.inspect(closed_windows)))
  print(string.format('Closed %d buffers: %s', #closedBufs, vim.inspect(closedBufs)))
end
function M.getCustomServices()

end
function M.ServiceServiceInjectorExists()

end
function M.FormServiceInjectorExists()

end
function M.ControllerServiceInjectorExists()

end
function M.BlockServiceInjectorExists()

end

function M.test1()
  local node = vim.treesitter.get_node()
  -- local node = vim.treesitter.get_node_at_cursor(vim.api.nvim_get_current_buf())
  -- local node = ts_utils.get_node_at_cursor()
  local parent = node:parent()
  local nameRange = ""
  local iter = 0
  while (parent ~= nil and parent:type() ~= "function_definition" and iter < 100) do
    -- if (parent:parent():type() == "function_definition")
    -- then

    -- end
    parent = parent:parent()
    iter = iter + 1
  end
  if (parent ~= nil)
  then
    local bufnr = vim.api.nvim_get_current_buf()
    local start_row, start_col, end_row, end_col = parent:range()
    local rowDiff = end_row - start_row + 1
    local child = parent:child(1)
    local c_startR, c_startC, c_endR, c_endC = child:range(false)
    local f_def = parent:field("name")[1]
    local function_text = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, {})

    vim.api.nvim_buf_set_lines(
      bufnr,
      start_row + rowDiff,
      end_row + rowDiff,
      nil,
      function_text
    )
    local winnr = 999 + vim.api.nvim_win_get_number(0)
    vim.api.nvim_win_set_cursor(
      winnr,
      {end_row + rowDiff - 1, c_endC}
    )
    return
  end
  print("Not function_definition descendent")

end

function M.test_func()
  local node = ts_utils.get_node_at_cursor()
  local nextNode = ts_utils.get_next_node(node, true, true)
  if nextNode == nil then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  if node == nil then
    error("No treesitter.")
  end


  local startRow, startColumn, startBytes, _, _, _ = node:range()
  local _, _, _, nendRow, nendColumn, nendBytes = nextNode:range()
  ts_utils.highlight_range({
    startRow,
    startColumn,
    startBytes,
    nendRow,
    nendColumn,
    nendBytes
  },
  bufnr,
  1,
  1
)
  -- ts_utils.update_selection(bufnr, node)
end

return M