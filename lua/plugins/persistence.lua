-- persistence.nvim
-- ----------------
-- Automatic session save and restore, keyed by working directory.
--
-- Without this, reopening a project means finding and reopening every file you
-- had, and rebuilding your split layout. With it, `<leader>qs` puts you back
-- exactly where you were: same buffers, same windows, same cursor positions.
--
-- Sessions are saved on exit automatically. Restoring is always explicit -- it
-- never hijacks a plain `nvim` invocation, which is important because `nvim
-- somefile.txt` should open that file and nothing else.
--
-- This pairs with project.nvim (lua/plugins/nvim_project.lua): that decides
-- what the project root is, this remembers what you had open in it.

return {
	{
		"folke/persistence.nvim",
		-- BufReadPre, so the session hooks are registered before any buffer is
		-- fully loaded, but after Neovim knows the cwd.
		event = "BufReadPre",
		opts = {
			-- Where session files live. Kept in `state` rather than `data`
			-- because these are throwaway, machine-local, and should not be
			-- confused with installed plugins.
			dir = vim.fn.stdpath("state") .. "/sessions/",

			-- Things that should not be persisted into a session. Without this,
			-- restoring can resurrect an empty dap-ui panel or a stale neogit
			-- status buffer that then errors.
			need = 1,
			branch = true, -- separate sessions per git branch
		},
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "[q]uit/session: re[s]tore session for this directory",
			},
			{
				"<leader>qS",
				function()
					require("persistence").select()
				end,
				desc = "[q]uit/session: [S]elect a session to restore",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "[q]uit/session: restore [l]ast session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "[q]uit/session: [d]on't save this session on exit",
			},
		},
	},
}
