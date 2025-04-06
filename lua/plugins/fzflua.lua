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





	},
}
