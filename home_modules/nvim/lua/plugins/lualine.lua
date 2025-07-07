local colors = require("catppuccin.palettes")

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

local gitsigns_diff = {
	"diff",
	source = diff_source(),
	symbols = {
		added = " ",
		modified = "󱗜 ",
		removed = " ",
	},
}

local gitsigns_branch = { "b:gitsigns_head", icon = " " }

local EOL_format = {
	"fileformat",
	icons_enabled = true,
	symbols = {
		unix = "LF",
		dos = "CRLF",
		mac = "CR",
	},
}

local filename = {
	"filename",
	path = 1,
	file_status = true,
	newfile_status = true,
	shorting_target = 40,
	symbols = {
		modified = " ",
		readonly = "󱀰 ",
		unnamed = "[No Name]",
		newfile = "[New]",
	},
}

local harpoon = {
	"harpoon2",
	icon = "󰀱 ",
	no_harpoon = "",
}

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn", "info", "hint" },
	symbols = { error = "󰅙 ", warn = " ", info = " ", hint = " " },
	colored = true,
	update_in_insert = false,
	always_visible = false,
}

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		{
			"letieu/harpoon-lualine",
			dependencies = {
				{
					"ThePrimeagen/harpoon",
					branch = "harpoon2",
				},
			},
		},
		{
			-- Allows displaying git blames among other things
			"lewis6991/gitsigns.nvim",
			opts = {
				signs_staged_enable = true,
				signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
				numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
				linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			},
		},
	},
	enabled = true,
	opts = {
		options = {
			theme = "catppuccin",
			component_separators = { left = "", right = "" },
			section_separators = { right = "", left = "" },
			globalstatus = true,
		},
		sections = {
			lualine_a = {
				{ "mode" },
			},
			lualine_b = {
				gitsigns_branch,
				gitsigns_diff,
			},
			lualine_c = {
				filename,
				diagnostics,
			},
			lualine_x = {
				harpoon,
			},
			lualine_y = {
				{ "lsp_status" },
				{ "filetype" },
				{ "encoding" },
				EOL_format,
			},
			lualine_z = {
				{ "location" },
				{ "progress" },
			},
		},
	},
}
