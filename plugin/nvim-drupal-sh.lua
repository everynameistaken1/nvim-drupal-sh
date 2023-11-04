local status_W, wk = pcall(require, 'which-key')
if not status_W then
  print("Which-key not found.")
  return
end

wk.register({
  ["<leader>t"] = { name = "+test" },
  ["<leader>tgc"] = { "<cmd>lua require'nvim-drupal-sh'.CloseAllFloatingWindows()<cr>", "Close All Floating Windows" },
  ["<leader>tgs"] = { "<cmd>lua require'nvim-drupal-sh'.getStandardServices()<cr>", "Show Standard Services" },
  ["<leader>tge"] = { ":lua require'nvim-drupal-sh'.serviceExists('')", "If Service Exists" },
  ["<leader>tgp"] = { "<cmd>lua require'nvim-drupal-sh'.chooseService()<cr>", "Pick Service" },
})
