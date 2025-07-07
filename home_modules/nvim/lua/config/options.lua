vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.g.transparent_enabled = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- line wrap
vim.opt.wrap = false

-- using undotree for backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- Unrecognised extensions should go here
vim.filetype.add({
	extension = {
		jinja = "jinja",
		jinja2 = "jinja",
		j2 = "htmldjango",
	},
})

-- netrw options '%' creates a file 'R' renames / moves a file,
-- 'd' creates a dir, 'D' deletes a file, 'gn' steps into a dir,
-- 'c' changes the cwd to the root dir of the tree
vim.g.netrw_keepdir = 1 -- moving into a dir in netrw doesnt change the cwd
vim.g.netrw_hide = 0 -- show hidden files
vim.g.netrw_banner = 0 -- dont show banner
vim.g.netrw_liststyle = 3 -- tree view 'gn' to step into directory
vim.g.netrw_list_hide = "\\.git"
vim.g.netrw_sizestyle = "h" -- human readable size info
vim.g.netrw_usetab = 0 -- nope
vim.g.netrw_winsize = 30 -- 30%
-- vim.g.netrw_wiw = 1

-- stops annoying "hit-enter messages"
-- vim.opt.messagesopt = "wait:1000,history:500"
vim.opt.cmdheight = 1
-- disable deprecated messages
vim.deprecate = function() end
