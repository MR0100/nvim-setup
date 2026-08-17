-- lazydev.nvim
-- -----------
-- Configures lua_ls specifically for editing a Neovim config: it makes the
-- Neovim runtime API (`vim.*`) available to the language server on demand,
-- so you get completion and docs for `vim.keymap.set`, `vim.opt`, etc.
--
-- This replaces the old `neodev.nvim`, and is why lua_ls in lsp.lua does not
-- need a hand-maintained `workspace.library` list.

return {
	"folke/lazydev.nvim",
	ft = "lua", -- only loads when you open a Lua file
	opts = {
		library = {
			-- Load the luvit type definitions when `vim.uv` is referenced.
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
