-- gitsigns.nvim
-- -------------
-- Git integration inside the buffer: change markers in the sign column,
-- staging/resetting individual hunks without leaving nvim, inline blame,
-- and diffing against any revision.

return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add          = { text = "┃" },
			change       = { text = "┃" },
			delete       = { text = "▁" },
			topdelete    = { text = "▔" },
			changedelete = { text = "~" },
			untracked    = { text = "┆" },
		},
		-- Inline "who last touched this line" at the end of the current line.
		-- Off by default because it is distracting; <leader>gb toggles it.
		current_line_blame = false,
		current_line_blame_opts = {
			virt_text_pos = "eol",
			delay = 500,
		},

		on_attach = function(bufnr)
			local gs = require("gitsigns")

			local function map(mode, keys, func, desc)
				vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
			end

			-- [ NAVIGATION ]
			-- ]c / [c jump between changed hunks. When a diff is actually open
			-- these fall through to Vim's built-in diff navigation.
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gs.nav_hunk("next")
				end
			end, "Next hunk")

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gs.nav_hunk("prev")
				end
			end, "Previous hunk")

			-- [ STAGE / RESET ]
			map("n", "<leader>gs", gs.stage_hunk, "[s]tage hunk")
			map("n", "<leader>gr", gs.reset_hunk, "[r]eset hunk")
			map("v", "<leader>gs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "[s]tage selected lines")
			map("v", "<leader>gr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "[r]eset selected lines")
			map("n", "<leader>gS", gs.stage_buffer, "[S]tage whole buffer")
			map("n", "<leader>gR", gs.reset_buffer, "[R]eset whole buffer")
			map("n", "<leader>gu", gs.undo_stage_hunk, "[u]ndo stage hunk")

			-- [ INSPECT ]
			map("n", "<leader>gp", gs.preview_hunk, "[p]review hunk")
			map("n", "<leader>gb", gs.toggle_current_line_blame, "toggle line [b]lame")
			map("n", "<leader>gB", function()
				gs.blame_line({ full = true })
			end, "[B]lame line (full)")
			map("n", "<leader>gd", gs.diffthis, "[d]iff against index")
			map("n", "<leader>gD", function()
				gs.diffthis("@")
			end, "[D]iff against last commit")
		end,
	},
}
