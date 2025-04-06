return {
	'stevearc/oil.nvim',
	---@module 'oil'
	---@type oil.SetupOpts
	config = function()
		require("oil").setup({})
	end,
	--- Optional dependencies
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	
	lazy = false, 
}
