-- toggleterm.nvim
-- ---------------
-- A terminal you can summon and dismiss with one key, instead of suspending
-- Neovim or juggling tmux panes for a two-second command.
--
-- This is what makes the Node/Bun/Go workflow bearable: `bun dev`, `go run .`,
-- `npm test -- --watch` all want a long-lived terminal sitting next to the code,
-- and you want to toggle it out of the way without killing the process.
--
-- Note this config also has tmux (see tmux_readme.md). toggleterm is not a
-- replacement -- tmux owns your session and survives closing Neovim, while
-- these terminals are per-Neovim and disappear with it. Use tmux for servers
-- you want to outlive the editor, toggleterm for the ones you don't.
--
--
-- KEYMAPS
-- -------
--   <C-\>        toggle the last-used terminal (works from insert mode too)
--   <leader>tth  horizontal split terminal
--   <leader>ttv  vertical split terminal
--   <leader>ttf  floating terminal
--   <leader>gt   lazygit, full screen (only if lazygit is installed)
--
-- Inside a terminal, <Esc> returns to normal mode and the usual <C-h/j/k/l>
-- window motions work, so you are not trapped in the terminal buffer.

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ [[<C-\>]], desc = "Toggle terminal" },
			{
				"<leader>tth",
				"<cmd>ToggleTerm direction=horizontal<CR>",
				desc = "[t]erminal [h]orizontal",
			},
			{
				"<leader>ttv",
				"<cmd>ToggleTerm direction=vertical<CR>",
				desc = "[t]erminal [v]ertical",
			},
			{ "<leader>ttf", "<cmd>ToggleTerm direction=float<CR>", desc = "[t]erminal [f]loat" },
			{
				"<leader>gt",
				function()
					if vim.fn.executable("lazygit") == 0 then
						vim.notify(
							"lazygit is not installed. Install it with `brew install lazygit`, "
								.. "or use <leader>gg for neogit instead.",
							vim.log.levels.WARN
						)
						return
					end

					local Terminal = require("toggleterm.terminal").Terminal
					Terminal:new({
						cmd = "lazygit",
						direction = "float",
						hidden = true,
						float_opts = { border = "rounded" },
						-- lazygit has its own keybindings; don't let Neovim
						-- intercept anything while it is focused.
						on_open = function(term)
							vim.cmd("startinsert!")
							vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr })
						end,
					}):toggle()
				end,
				desc = "[g]it: lazygi[t]",
			},
		},
		opts = {
			-- <C-\> is close to <C-`> from VS Code and is not otherwise bound.
			open_mapping = [[<C-\>]],
			-- Remember the size per direction.
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			direction = "horizontal",
			-- Start in insert mode; you almost always want to type immediately.
			start_in_insert = true,
			-- Close the buffer when the process exits, rather than leaving a
			-- dead `[Process exited 0]` buffer behind.
			close_on_exit = true,
			shade_terminals = true,
			float_opts = { border = "rounded" },
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)

			-- Make terminal buffers behave like the rest of the editor.
			vim.api.nvim_create_autocmd("TermOpen", {
				group = vim.api.nvim_create_augroup("config_toggleterm_keys", { clear = true }),
				pattern = "term://*toggleterm#*",
				callback = function(event)
					local function map(keys, to, desc)
						vim.keymap.set("t", keys, to, { buffer = event.buf, desc = desc })
					end

					-- Escape terminal insert mode. `<C-\><C-n>` is the built-in
					-- but nobody remembers it.
					map("<Esc>", [[<C-\><C-n>]], "Leave terminal mode")

					-- Window navigation without leaving terminal mode first.
					map("<C-h>", [[<Cmd>wincmd h<CR>]], "Go to left window")
					map("<C-j>", [[<Cmd>wincmd j<CR>]], "Go to lower window")
					map("<C-k>", [[<Cmd>wincmd k<CR>]], "Go to upper window")
					map("<C-l>", [[<Cmd>wincmd l<CR>]], "Go to right window")
				end,
			})
		end,
	},
}
