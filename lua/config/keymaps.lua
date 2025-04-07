vim.keymap.set("n", "<leader>-", "<cmd>Oil --float<CR>", {desc="Open Parent Directory in Oil"})
vim.keymap.set("n", "|sd", function() vim.diagnostic.open_float() end, {desc="Open Diagnostics in Float."})
