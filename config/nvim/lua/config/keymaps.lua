local map = vim.keymap.set

map("n", "<C-q>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Sidebar" })

map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })

map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })

map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

map({ "n", "i", "v" }, "<M-Left>", "<Home>", { desc = "Go to Start of Line" })
map({ "n", "i", "v" }, "<M-Right>", "<End>", { desc = "Go to End of Line" })

map({ "n", "v" }, "<M-h>", "^", { desc = "Go to Start of Line (Non-blank)" }) -- Use "0" for absolute start
map({ "n", "v" }, "<M-l>", "$", { desc = "Go to End of Line" })

map("i", "<M-h>", "<C-o>^", { desc = "Go to Start of Line (Non-blank)" })
map("i", "<M-l>", "<C-o>$", { desc = "Go to End of Line" })

map({ "n", "t" }, "<C-`>", function()
  Snacks.terminal()
end, { desc = "Toggle Terminal" })
