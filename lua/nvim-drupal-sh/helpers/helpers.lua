local M = {}

function M.GetFileExtension(bufnr)
  -- return vim.api.nvim_buf_get_name(bufnr)
  return vim.fn.getbufvar(bufnr, '&filetype')
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
  -- print(string.format('Closed %d windows: %s', #closed_windows, vim.inspect(closed_windows)))
  -- print(string.format('Closed %d buffers: %s', #closedBufs, vim.inspect(closedBufs)))
end

return M
