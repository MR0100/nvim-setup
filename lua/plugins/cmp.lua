-- nvim-cmp
-- --------
-- Completion engine. Pulls suggestions from several "sources" (LSP, snippets,
-- the current buffer, filesystem paths) and merges them into one menu.

return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		{
			"L3MON4D3/LuaSnip",								-- Snippet Engine
			build = "make install_jsregexp",				-- optional, enables regex transforms in snippets
			dependencies = {
				-- NOTE: this is the actual snippet *content*. Without it LuaSnip is
				-- an engine with nothing to expand, so the `luasnip` source below
				-- was previously always empty.
				{
					"rafamadriz/friendly-snippets",
					config = function()
						require("luasnip.loaders.from_vscode").lazy_load()
					end,
				},
			},
		},
		"saadparwaiz1/cmp_luasnip",							-- Snippet Completions
		"hrsh7th/cmp-nvim-lsp",								-- LSP Source
		"hrsh7th/cmp-buffer",								-- Buffer Source
		"hrsh7th/cmp-path",									-- Path Source
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		luasnip.config.setup({})

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			completion = { completeopt = "menu,menuone,noinsert" },
			mapping = cmp.mapping.preset.insert({
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),

				-- Scroll the documentation window of the highlighted item.
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),

				-- [ SNIPPET NAVIGATION ]
				-- Once a snippet expands it has placeholders (the bits you tab
				-- through and fill in). Without these you cannot reach them.
				-- <C-l> moves to the next placeholder, <C-h> to the previous.
				["<C-l>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
				["<C-h>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				-- lazydev is listed first so that when editing this config, the
				-- Neovim API completions outrank generic buffer words.
				{ name = "lazydev", group_index = 0 },
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
	end,
}
