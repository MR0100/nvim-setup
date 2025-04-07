return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	dependencies = { "echasnovski/mini.icons" },
	opts = {},
	keys = {
		{ "<leader>fff", function() require('fzf-lua').files() end, desc = "Find Files in Project Directory."},
		{ "<leader>ffg", function() require('fzf-lua').live_grep() end, desc = "Fing by Grepping in Project Directory.", },
		{ "<leader>fdesk", function() require('fzf-lua').files({ cwd = "/Users/mitulvaghasiya/Desktop" }) end, desc = "Find Files in the Desktop." },
		{ "<leader>ffp", function() require('fzf-lua').files({ cwd = "../" }) end, desc = "Find Files in the Parent Directory." },
		{ "<leader>ffb", function() require('fzf-lua').builtin() end, desc = "f:decorator [f]ind [b]uiltins" },
		{ "<leader>fcfg", function() require('fzf-lua').files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Files in the ~/.config/nvim Directory." },
		{ "<leader>ffh", function() require('fzf-lua').helptags() end, desc = "f:decorator [f]ind [h]elp" },
		{ "<leader>ffk", function() require('fzf-lua').keymaps() end, desc = "f:decorator [f]ind [k]eymaps" },
		{ "<leader>fcw", function() require('fzf-lua').grep_cword() end, desc = "[f]ind [c]urrent [w]ord" },
		{ "<leader>fdg", function() require('fzf-lua').diagnostics_document() end, desc = "[f]ind [d]ia[g]nostics" },
		{ "<leader>ffr", function() require('fzf-lua').resume() end, desc = "f:decorator [f]ind [r]esume" }, 
		{ "<leader>fof", function() require('fzf-lua').old_files() end, desc = "[f]ind [o]ld [f]iles" },
	},
}
