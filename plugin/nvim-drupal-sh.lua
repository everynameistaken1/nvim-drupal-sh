local status_W, wk = pcall(require, 'which-key')
if not status_W then
  print("Which-key not found.")
  return
end

wk.register({
  ["<leader>i"] = { name = "+inject" },
  ["<leader>is"] = { "<cmd>lua require'nvim-drupal-sh'.getStandardServices()<cr>", "Show Standard Services" },
  ["<leader>ie"] = { ":lua require'nvim-drupal-sh'.serviceExists('')", "If Service Exists" },
  ["<leader>ip"] = { "<cmd>lua require'nvim-drupal-sh'.chooseService()<cr>", "Pick Service" },
  ["<leader>ii"] = { "<cmd>lua require'nvim-drupal-sh'.createDependencyInjectionMethods()<cr>", "Create Dependency Inj Methods" },
})
