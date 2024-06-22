local status_W, wk = pcall(require, 'which-key')
if not status_W then
  print("Which-key not found.")
  return
end

wk.register({
  ["<leader>i"] = { name = "+inject" },
  ["<leader>ii"] = { "<cmd>lua require'nvim-drupal-sh'.showAndPick()<cr>", "Show And Pick Service" },
})
