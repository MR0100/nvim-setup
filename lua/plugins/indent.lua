-- indent-blankline.nvim
-- ---------------------
-- Vertical guides on each indentation level, with the level your cursor is
-- inside highlighted differently.
--
-- This matters more in this config than in most: `lua/config/options.lua` sets
-- `shiftwidth = 4` and `listchars` shows tabs as `▸ `, but neither tells you
-- which `end` or `}` closes the block you are looking at once it scrolls off
-- screen. The scope highlight does.
--
-- The plugin's Lua module is called `ibl`, not `indent_blankline`, which is why
-- `main` has to be set explicitly.

return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				-- A thin line, not a dotted one -- reads as structure rather
				-- than as content.
				char = "│",
				tab_char = "│",
			},

			scope = {
				-- Highlight the block the cursor is currently in, and underline
				-- its first and last line.
				enabled = true,
				show_start = true,
				show_end = true,
				-- Use Treesitter to decide what "the current scope" means, so it
				-- follows functions and blocks rather than raw indentation.
				injected_languages = true,
			},

			-- Buffers where guides are noise rather than help.
			exclude = {
				filetypes = {
					"help",
					"checkhealth",
					"lspinfo",
					"man",
					"qf",
					"starter",
					"oil",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"dap-repl",
					"dapui_scopes",
					"dapui_breakpoints",
					"dapui_stacks",
					"dapui_watches",
					"dapui_console",
					"NeogitStatus",
					"neotest-summary",
					"gitcommit",
					"fugitive",
				},
				buftypes = { "terminal", "nofile", "quickfix", "prompt" },
			},
		},
	},
}
