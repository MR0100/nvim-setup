-- showkeys
-- --------
-- On-screen display of the keys you press. Useful for screencasts, pairing,
-- and for catching what a plugin actually bound -- but noisy for everyday
-- editing.
--
-- NOTE: this used to call ShowkeysToggle on startup, so the overlay was always
-- on. It is now lazy-loaded behind a keymap instead.

return {
	"nvzone/showkeys",
	cmd = "ShowkeysToggle",
	keys = {
		{ "<leader>tk", "<cmd>ShowkeysToggle<CR>", desc = "[t]oggle [k]eys overlay" },
	},
	opts = {
		timeout = 1,
		maxkeys = 5,
		position = "top-right",
	},
}
