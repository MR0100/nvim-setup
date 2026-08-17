-- Git UI
-- ------
-- gitsigns.nvim (lua/plugins/gitsigns.lua) already handles everything *inside* a
-- buffer: hunk signs, staging a hunk, blame for one line. What it deliberately
-- does not do is the repository-level work -- writing a commit message,
-- switching branches, resolving a rebase, reviewing a full diff.
--
-- That is what these three add, and they overlap less than they look:
--
--   neogit    -- a full magit-style porcelain. Stage/unstage by hunk or file
--                from one status buffer, write commit messages, push, pull,
--                rebase, cherry-pick, stash, browse the log. This is the one
--                you will use daily. `<leader>gg`
--
--   diffview  -- proper side-by-side diffs and a file-tree view of a whole
--                changeset or merge conflict. Neogit hands off to it. `<leader>gv`
--
--   fugitive  -- tpope's classic. Kept because `:Git blame` in a scrollbound
--                split is still the best blame view there is, and because this
--                config's `close_with_q` autocmd in lua/config/autocmds.lua
--                already lists `fugitive` as a filetype, which previously
--                referred to a plugin that was never installed.

return {
	-- ====================================================================
	-- neogit -- the main interface
	-- ====================================================================
	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			-- This config uses fzf-lua rather than telescope, and neogit
			-- supports it natively for its pickers.
			"ibhagwan/fzf-lua",
		},
		keys = {
			{ "<leader>gg", "<cmd>Neogit<CR>", desc = "[g]it status (neo[g]it)" },
			{ "<leader>gc", "<cmd>Neogit commit<CR>", desc = "[g]it [c]ommit" },
			{ "<leader>gl", "<cmd>Neogit log<CR>", desc = "[g]it [l]og" },
			{ "<leader>gP", "<cmd>Neogit push<CR>", desc = "[g]it [P]ush" },
			{ "<leader>gF", "<cmd>Neogit pull<CR>", desc = "[g]it pull ([F]etch+merge)" },
		},
		opts = {
			-- Open the status buffer as a normal split rather than replacing the
			-- current window, so you keep your place in the code.
			kind = "split",
			-- Commit messages are easier to write in a real buffer than a popup.
			commit_editor = { kind = "split" },
			commit_select_view = { kind = "split" },
			commit_view = { kind = "split" },
			log_view = { kind = "split" },
			-- Use fzf-lua for branch/commit selection prompts.
			integrations = {
				diffview = true,
				fzf_lua = true,
				telescope = false,
			},
			-- Show a word-level diff inside changed lines, not just line-level.
			disable_hint = false,
			graph_style = "unicode",
		},
	},

	-- ====================================================================
	-- diffview -- side-by-side diffs and merge conflict resolution
	-- ====================================================================
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "[g]it diff [v]iew (working tree)" },
			{
				"<leader>gh",
				"<cmd>DiffviewFileHistory %<CR>",
				desc = "[g]it [h]istory of this file",
			},
			{
				"<leader>gH",
				"<cmd>DiffviewFileHistory<CR>",
				desc = "[g]it [H]istory of the branch",
			},
			{ "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "[g]it diffview close ([x])" },
		},
		opts = {
			enhanced_diff_hl = true,
			view = {
				-- Three-way merge view when resolving conflicts: OURS, base,
				-- THEIRS, plus the working copy you actually edit.
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true,
				},
			},
		},
	},

	-- ====================================================================
	-- fugitive -- kept for :Git blame and raw :Git passthrough
	-- ====================================================================
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gread", "Gwrite", "Gdiffsplit", "Gvdiffsplit" },
		keys = {
			{ "<leader>gW", "<cmd>Git blame<CR>", desc = "[g]it blame [W]indow (fugitive)" },
		},
	},
}
