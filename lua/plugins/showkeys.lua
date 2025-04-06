return { 
	"nvzone/showkeys",
	lazy = false, -- Ensure it loads on startup. 
	config = function()
		-- Run the toggle command after the plugin is loaded. 
		vim.schedule(function()
			vim.cmd("ShowkeysToggle")
		end)
	end 
}
