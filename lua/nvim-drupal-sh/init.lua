local status_SS, showServices = pcall(require, "nvim-drupal-sh.services.showServices")
if not status_SS then
  print("Show-services not found");
  return
end

local M = {}

M.getStandardServices = showServices.getStandardServices
M.serviceExists = showServices.serviceExists
M.chooseService = showServices.chooseService
M.createDependencyInjectionMethods = showServices.createDependencyInjectionMethods

return M
