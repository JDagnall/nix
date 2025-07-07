-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add LazyVim and import its plugins
		-- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- import/override with your plugins
		{ import = "plugins" },
		-- required for lazy.nvim and image.nvim
		{
			"vhyrro/luarocks.nvim",
			priority = 1001, -- this plugin needs to run before anything else
			opts = {
				rocks = { "magick" },
			},
			config = true,
		},
		-- surround text, Visual: s[char], Normal: cs[char][char], S[char]
		{ "tpope/vim-surround" },
		-- Game
		-- { 'ThePrimeagen/vim-be-good' }
		-- Makes transparent
		{ "xiyaowong/transparent.nvim" },
		-- Comments blocks: gbc, lines: gcc
		{ "numToStr/Comment.nvim" },
		{ "nvim-tree/nvim-web-devicons", lazy = true },
		-- tmux pane navigation integration (ctrl-[hjkl])
		{ "christoomey/vim-tmux-navigator" },
		-- Wezterm image provider
		{ "willothy/wezterm.nvim", config = true, enabled = false },
		-- netrw glow up
		{
			"prichrd/netrw.nvim",
			opts = {},
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"RRethy/vim-illuminate",
			config = function()
				require("illuminate").configure({
					modes_allowlist = { "n" },
					providers = { "lsp" },
				})
			end,
			enabled = true,
		},
		-- { "vuciv/golf", enabled = false },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true, notify = false },
	change_detection = { enabled = true, notify = false },
	performance = {
		rtp = {
			disabled_plugins = {},
		},
	},
})
