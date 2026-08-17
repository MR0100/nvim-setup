-- noice.nvim
-- ----------
-- Replaces Neovim's bottom-line message area, cmdline and search prompt with
-- proper floating UI, and routes messages through nvim-notify so they stack in
-- the corner instead of scrolling past or triggering "Press ENTER to continue".
--
-- Concretely, this fixes three everyday annoyances:
--   * long messages truncated to one line, needing `:messages` to read
--   * "Press ENTER or type command to continue" interrupting your flow
--   * the cmdline sitting at the very bottom of a tall terminal, far from where
--     you are looking
--
--
-- ON FIDGET
-- ---------
-- This config already runs fidget.nvim for LSP progress (declared as a
-- dependency in lua/plugins/lsp.lua). noice can also render LSP progress, and
-- if both are enabled you get every "indexing..." message twice. noice's
-- progress handler is therefore switched off below, leaving fidget in charge.

return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			-- UI component library noice is built on. Not optional.
			"MunifTanjim/nui.nvim",

			-- The notification backend. Without it, noice falls back to plain
			-- messages and you lose the stacked corner popups.
			{
				"rcarriga/nvim-notify",
				opts = {
					-- Fade out rather than sitting there; 3s is long enough to
					-- read a diagnostic but short enough not to cover code.
					timeout = 3000,
					max_height = function()
						return math.floor(vim.o.lines * 0.75)
					end,
					max_width = function()
						return math.floor(vim.o.columns * 0.5)
					end,
					render = "wrapped-compact",
					stages = "static",
					-- Transparent backgrounds look broken on some terminals;
					-- give notifications a real background colour.
					background_colour = "#1e2030", -- tokyonight-moon bg_dark
				},
			},
		},
		opts = {
			lsp = {
				-- Use Treesitter to highlight markdown in hover/signature
				-- popups, and let cmp's documentation window use the same
				-- renderer.
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},

				-- See the note at the top of this file: fidget.nvim owns LSP
				-- progress reporting.
				progress = { enabled = false },

				hover = { enabled = true },
				signature = { enabled = true },

				-- Show a small floating window with the current function
				-- signature as you type arguments.
				message = { enabled = true },
			},

			presets = {
				-- Search stays on the bottom line, where muscle memory expects
				-- it, rather than jumping to a float mid-screen.
				bottom_search = true,
				-- `:` opens a centred palette-style input.
				command_palette = true,
				-- Anything too long for a notification opens in a split you can
				-- scroll, instead of being truncated.
				long_message_to_split = true,
				-- Borders on hover/signature docs.
				lsp_doc_border = true,
				inc_rename = false,
			},

			routes = {
				-- "written" after every save is noise; gitsigns and the
				-- statusline already make it obvious the buffer is clean.
				{
					filter = { event = "msg_show", kind = "", find = "written" },
					opts = { skip = true },
				},
				-- Line/character count after a bulk edit.
				{
					filter = { event = "msg_show", kind = "", find = "more line" },
					opts = { skip = true },
				},
				{
					filter = { event = "msg_show", kind = "", find = "fewer line" },
					opts = { skip = true },
				},
				-- "search hit BOTTOM, continuing at TOP" -- expected behaviour,
				-- not news.
				{
					filter = { event = "msg_show", kind = "wmsg" },
					opts = { skip = true },
				},
			},
		},
		keys = {
			-- NOTE: `<leader>m` ("messages") rather than `<leader>n`, because
			-- package-info.nvim already owns `<leader>n` for npm/bun dependency
			-- actions. See lua/plugins/package_info.lua.
			{
				"<leader>ml",
				function()
					require("noice").cmd("last")
				end,
				desc = "[m]essages: [l]ast message",
			},
			{
				"<leader>mh",
				function()
					require("noice").cmd("history")
				end,
				desc = "[m]essages: [h]istory",
			},
			{
				"<leader>md",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "[m]essages: [d]ismiss all notifications",
			},
			{
				"<leader>me",
				function()
					require("noice").cmd("errors")
				end,
				desc = "[m]essages: [e]rrors only",
			},
			-- Make <C-d>/<C-u> scroll inside hover and signature popups, which
			-- otherwise cannot be scrolled at all.
			{
				"<C-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<C-f>"
					end
				end,
				silent = true,
				expr = true,
				mode = { "n", "i", "s" },
				desc = "Scroll forward in LSP popup",
			},
			{
				"<C-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<C-b>"
					end
				end,
				silent = true,
				expr = true,
				mode = { "n", "i", "s" },
				desc = "Scroll backward in LSP popup",
			},
		},
	},
}
