vim.g.mapleader = " "
-- go to file explore
vim.keymap.set("n", "<leader>pv", vim.cmd.Lex)
-- exit insert
vim.keymap.set("i", "<C-c>", "<Esc>")
-- run packer.lua
-- vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.config/nvim/lua/james/packer.lua<CR>");
-- source the file
-- vim.keymap.set("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end)
-- close buffer
vim.keymap.set("n", "<leader>q", "<C-w>q")
-- buffer managment shortcut
vim.keymap.set("n", "<leader>w", "<C-w>")
-- nope
vim.keymap.set("n", "Q", "<nop>")
-- move highlighted text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- half page jumping tweak
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- paste without changing clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])
-- yank into the system clipboard
vim.keymap.set("v", "<leader>y", '"+y')
-- yank whole line into the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y')
-- paste from the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
-- yank into ~/.local/share/nvim/.vimbuffer
vim.keymap.set("v", "ty", ":w! ~/.local/share/nvim/.vimbuffer<CR>")
-- paste from ~/.local/share/nvim/.vimbuffer
vim.keymap.set("n", "tp", ":r ~/.local/share/nvim/.vimbuffer<CR>")
-- deleting to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
-- exit terminal
vim.api.nvim_set_keymap("t", "<ESC>", [[<C-\><C-n>]], { noremap = true })
vim.api.nvim_set_keymap("t", "<C-d>", [[<C-\><C-d>]], { noremap = true })
-- alias cmd's
vim.cmd("command! W w")
vim.cmd("command! Q q")
vim.cmd("command! Wq wq")
vim.cmd("command! WQ wq")
vim.cmd("command! Wa wa")
vim.cmd("command! WA wa")
-- insert newline above and below while in N mode
vim.keymap.set("n", "nl", "o<Esc>")
vim.keymap.set("n", "Nl", "O<Esc>")
vim.keymap.set("n", "NL", "O<Esc>")
-- dont cancel visual mode when indenting blocks
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
-- tmux nav remaps
-- vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>")
-- vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>")
-- vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>")
-- vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>")
-- potentially useful for clearing notifications
-- vim.keymap.set("", "<ESC>", "<ESC>:noh<CR>")
