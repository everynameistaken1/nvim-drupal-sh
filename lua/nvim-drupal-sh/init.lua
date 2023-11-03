local status_SS, showServices = pcall(require, "nvim-drupal-sh.services.showServices")
if not status_SS then
  print("Show-services not found");
  return
end

local status_H, helpers = pcall(require, "nvim-drupal-sh.helpers.helpers")
if not status_H then
  print("Show-services not found");
  return
end

local M = {}

M.getStandardServices = showServices.getStandardServices
M.serviceExists = showServices.serviceExists
M.CloseAllFloatingWindows = helpers.CloseAllFloatingWindows
M.chooseService = showServices.chooseService

return M
