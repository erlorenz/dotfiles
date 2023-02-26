--Map leader and esc
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<Esc>")

--Move selected line up and down
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv") 
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv") 

--Better paste (without swap)
vim.keymap.set("v", "p", '"_dP')

--Delete to void register
vim.keymap.set("v", "<leader>d", '"_d')
vim.keymap.set("n", "<leader>dd", '"_dd')
vim.keymap.set("n", "x", '"_dl')

--When scrolling center cursor on page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")


