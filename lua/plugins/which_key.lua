return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- Names for the key prefixes, so the popup shows "find"/"git" instead
		-- of an undifferentiated wall of keys.
		spec = {
			{ "<leader>f", group = "find (fzf-lua)" },
			{ "<leader>ff", group = "find files/help/keymaps" },
			{ "<leader>fl", group = "lsp" },
			{ "<leader>g", group = "git" },
			{ "<leader>d", group = "diagnostics" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>s", group = "swap (treesitter)" },

			-- `<leader>t` carries both the toggles that were already here
			-- (tf format-on-save, tk key overlay) and the neotest mappings.
			{ "<leader>t", group = "toggle / test" },
			{ "<leader>tt", group = "terminal (toggleterm)" },

			-- Debugging. NOTE: this is `x` ("e[x]ecute") rather than the
			-- conventional `d`, because `<leader>d` is already diagnostics here
			-- and `<leader>D` is delete-without-yanking.
			{ "<leader>x", group = "debug (dap)" },

			-- Sessions (persistence.nvim).
			{ "<leader>q", group = "session" },

			-- Messages / notifications (noice).
			{ "<leader>m", group = "messages (noice)" },

			-- npm / bun dependency actions inside package.json.
			{ "<leader>n", group = "npm / bun deps" },

			-- Language-specific groups. These only have mappings while a buffer
			-- of that language is open, since both plugins set them on attach.
			{ "<leader>r", group = "rust (rustaceanvim)" },
			{ "<leader>F", group = "flutter" },

			{ "[", group = "previous" },
			{ "]", group = "next" },
		},
	},
	keys = {
		{
			"<leader>//",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
