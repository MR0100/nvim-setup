-- conform.nvim
-- ------------
-- Runs external formatters on save. Previously nothing in this config ever
-- invoked a formatter -- `stylua` was installed by Mason but never called.
--
-- Toggle format-on-save with <leader>tf (persists for the session).
-- Format manually at any time with <leader>cf.

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[c]ode [f]ormat buffer / selection",
		},
	},
	opts = {
		notify_on_error = false,

		formatters_by_ft = {
			lua = { "stylua" },
			rust = { "rustfmt" },
			dart = { "dart_format" },

			-- [ GO ]
			-- goimports must run after gofumpt: gofumpt reformats the file,
			-- goimports then fixes up the import block. Listed as a sequence
			-- (no `stop_after_first`) so both run.
			go = { "gofumpt", "goimports" },
			gomod = { "gofumpt" },

			-- Use the first of these that is actually installed.
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			graphql = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },

			-- [ SHELL / CONFIG ]
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			toml = { "taplo" },
		},

		-- Formatter-specific tweaks.
		formatters = {
			shfmt = {
				-- Two-space indent and `case` bodies indented, which matches
				-- how most shell in the wild is written.
				prepend_args = { "-i", "2", "-ci" },
			},
		},

		format_on_save = function(bufnr)
			-- Respect the toggles set by <leader>tf below.
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- Languages whose LSP-side formatting is unreliable or whose
			-- formatter is slow enough to be annoying can be excluded here.
			local ignore_filetypes = {}
			if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
				return
			end

			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
	init = function()
		-- Make gq use conform, so the built-in format operator works too.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		vim.keymap.set("n", "<leader>tf", function()
			vim.g.disable_autoformat = not vim.g.disable_autoformat
			vim.notify(
				"Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"),
				vim.log.levels.INFO
			)
		end, { desc = "[t]oggle [f]ormat on save" })
	end,
}
