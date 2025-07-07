return {
	"folke/snacks.nvim",
	enabled = true,
	lazy = false,
	priority = 999,
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = [[
███╗   ███╗ ██████╗  ██████╗██╗  ██╗ █████╗ 
████╗ ████║██╔═══██╗██╔════╝██║  ██║██╔══██╗
██╔████╔██║██║   ██║██║     ███████║███████║
██║╚██╔╝██║██║   ██║██║     ██╔══██║██╔══██║
██║ ╚═╝ ██║╚██████╔╝╚██████╗██║  ██║██║  ██║
                ]],
				keys = {
					{
						icon = "󰭎  ",
						desc = "Find Files",
						key = "a",
						action = ":Telescope find_files",
					},
					{
						icon = "  ",
						desc = "File Browser",
						key = "s",
						action = ":Ex",
					},
					{
						icon = "  ",
						desc = "Search CWD",
						key = "d",
						action = ":Telescope live_grep",
					},
					{
						icon = "  ",
						desc = "Recent Files",
						key = "f",
						action = ":Telescope oldfiles",
					},
					{
						icon = "󰒲  ",
						desc = "Lazy",
						key = "l",
						action = ":Lazy",
					},
					{
						icon = "󰈆  ",
						desc = "Quit",
						key = "q",
						action = ":q",
					},
				},
			},
			sections = {
				{
					section = "terminal",
					cmd = "chafa -C true --symbols vhalf -f symbols -s 60x30 -O 9 ~/.config/nvim/img/catppuccin_square.png; sleep .1",
					height = 30,
					padding = 1,
				},
				{
					pane = 2,
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
		},
		bigfile = { enabled = true },
		quickfile = { enabled = true },
		words = { enabled = false },
		scope = {
			enabled = true,
			keys = {
				jump = {
					["{"] = {
						min_size = 1, -- allow single line scopes
						bottom = false,
						cursor = true,
						edge = true,
						treesitter = { blocks = { enabled = false } },
						desc = "jump to top edge of scope",
					},
					["}"] = {
						min_size = 1, -- allow single line scopes
						bottom = true,
						cursor = true,
						edge = true,
						treesitter = { blocks = { enabled = false } },
						desc = "jump to bottom edge of scope",
					},
				},
			},
		},
	},
}
