-- package-info.nvim
-- -----------------
-- Inside `package.json`, shows the currently installed version of each
-- dependency as virtual text, and marks the ones that are outdated. You can
-- bump, install, or delete a dependency without leaving the buffer.
--
-- This is the piece of the Node/Bun workflow that otherwise means alt-tabbing to
-- run `npm outdated` and reading a table.
--
-- It shells out to a package manager, and Bun is supported alongside npm/yarn/
-- pnpm -- set `package_manager` below if the auto-detection guesses wrong for a
-- given repo.

return {
	{
		"vuki656/package-info.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		-- Only ever relevant in a package.json.
		event = { "BufRead package.json" },
		keys = {
			{
				"<leader>ns",
				function()
					require("package-info").show({ force = true })
				end,
				desc = "[n]pm: [s]how dependency versions",
			},
			{
				"<leader>nc",
				function()
					require("package-info").hide()
				end,
				desc = "[n]pm: [c]lose/hide versions",
			},
			{
				"<leader>nu",
				function()
					require("package-info").update()
				end,
				desc = "[n]pm: [u]pdate dependency on this line",
			},
			{
				"<leader>ni",
				function()
					require("package-info").install()
				end,
				desc = "[n]pm: [i]nstall a new dependency",
			},
			{
				"<leader>nD",
				function()
					require("package-info").delete()
				end,
				desc = "[n]pm: [D]elete dependency on this line",
			},
			{
				"<leader>np",
				function()
					require("package-info").change_version()
				end,
				desc = "[n]pm: [p]ick a different version",
			},
		},
		opts = {
			-- Detected per project from the lockfile. Bun projects need
			-- `bun.lockb`/`bun.lock` present for detection to work; otherwise
			-- set this explicitly.
			package_manager = (function()
				if
					vim.fn.filereadable("bun.lockb") == 1
					or vim.fn.filereadable("bun.lock") == 1
				then
					return "bun"
				elseif vim.fn.filereadable("pnpm-lock.yaml") == 1 then
					return "pnpm"
				elseif vim.fn.filereadable("yarn.lock") == 1 then
					return "yarn"
				end
				return "npm"
			end)(),

			-- Virtual text markers. Single-width glyphs, consistent with the
			-- diagnostic and DAP signs elsewhere in this config.
			icons = {
				enable = true,
				style = {
					up_to_date = "  ",
					outdated = "  ",
				},
			},

			-- Don't hit the network on every buffer read; cache for an hour.
			autostart = true,
			hide_up_to_date = false,
			hide_unstable_versions = true,
		},
	},
}
