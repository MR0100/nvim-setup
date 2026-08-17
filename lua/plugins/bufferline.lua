-- bufferline.nvim
-- ---------------
-- Renders open buffers as tabs along the top, with diagnostic counts on each.
--
-- This config already navigates buffers with <S-h>/<S-l> (see
-- lua/config/keymaps.lua) but gave no visual indication of what was open, how
-- many, or which ones had errors. Those existing mappings keep working -- plain
-- `:bprevious`/`:bnext` walk the same list bufferline displays.
--
-- The additions here are the things that need a visible tab line to make sense:
-- pinning, closing others, and jumping to a specific position.

return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		-- Icons come from mini.icons via its nvim-web-devicons shim; see the
		-- mini.icons block in lua/plugins/mini.lua.
		dependencies = { "echasnovski/mini.icons" },
		keys = {
			{ "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "[b]uffer: toggle [p]in" },
			{
				"<leader>bP",
				"<cmd>BufferLineGroupClose ungrouped<CR>",
				desc = "[b]uffer: close un[P]inned",
			},
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "[b]uffer: close [o]thers" },
			{
				"<leader>br",
				"<cmd>BufferLineCloseRight<CR>",
				desc = "[b]uffer: close to the [r]ight",
			},
			{
				"<leader>bl",
				"<cmd>BufferLineCloseLeft<CR>",
				desc = "[b]uffer: close to the [l]eft",
			},
			{
				"<leader>bs",
				"<cmd>BufferLinePick<CR>",
				desc = "[b]uffer: pick / [s]elect by letter",
			},
			-- Reorder the current buffer, so the tab order can match how you
			-- think about the task rather than the order you happened to open
			-- files in.
			{ "<leader>b>", "<cmd>BufferLineMoveNext<CR>", desc = "[b]uffer: move right" },
			{ "<leader>b<", "<cmd>BufferLineMovePrev<CR>", desc = "[b]uffer: move left" },
		},
		opts = {
			options = {
				-- Show LSP diagnostics per buffer, so a broken file is obvious
				-- without switching to it.
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(_, _, diagnostics_dict)
					local s = ""
					for level, count in pairs(diagnostics_dict) do
						local sym = level == "error" and " 󰅚 "
							or (level == "warning" and " 󰀪 " or " 󰋽 ")
						s = s .. sym .. count
					end
					return s
				end,

				-- Clicking the x is a mouse action; `:bdelete` is the keyboard
				-- one and is already mapped to <leader>bd.
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",

				separator_style = "thin",
				always_show_bufferline = false, -- hide it when only one buffer is open
				show_buffer_close_icons = false,
				show_close_icon = false,

				-- Truncate long names rather than letting one path eat the bar.
				max_name_length = 20,
				tab_size = 18,

				-- Don't count these as buffers worth showing a tab for.
				custom_filter = function(buf_number)
					local ft = vim.bo[buf_number].filetype
					local excluded = {
						["oil"] = true,
						["neo-tree"] = true,
						["qf"] = true,
						["dapui_scopes"] = true,
						["dapui_breakpoints"] = true,
						["dapui_stacks"] = true,
						["dapui_watches"] = true,
						["dapui_console"] = true,
						["dap-repl"] = true,
						["NeogitStatus"] = true,
						["starter"] = true,
					}
					return not excluded[ft]
				end,

				-- Keep the tab line clear of the oil.nvim float and dap panels.
				offsets = {
					{
						filetype = "dapui_scopes",
						text = "Debugger",
						highlight = "Directory",
						separator = true,
					},
				},

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
			},
		},
	},
}
