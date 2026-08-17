-- Autocommands
-- ------------
-- Things that should happen automatically in response to editor events.

local function augroup(name)
	return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Briefly highlight text when you yank it, so you can see exactly what was
-- copied. Purely visual, but it catches a lot of "did that actually work?"
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	desc = "Highlight when yanking text",
	callback = function()
		-- `vim.highlight` was renamed to `vim.hl` in 0.11 and the old name is
		-- deprecated. Prefer the new one when it exists.
		local hl = vim.hl or vim.highlight
		hl.on_yank()
	end,
})

-- Reopen a file with the cursor where you left it.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("restore_cursor"),
	desc = "Return to the last edit position when reopening a file",
	callback = function(event)
		local exclude = { "gitcommit", "gitrebase" }
		if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
			return
		end

		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Strip trailing whitespace on save. conform.nvim handles this for filetypes
-- that have a formatter; this covers everything else.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	desc = "Remove trailing whitespace on save",
	callback = function()
		local save = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(save)
	end,
})

-- Rebalance splits when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_splits"),
	desc = "Equalize split sizes on terminal resize",
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Let `q` close throwaway windows, instead of having to reach for `:q`.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	desc = "Close scratch/help windows with q",
	pattern = {
		"help",
		"qf",
		"man",
		"checkhealth",
		"lspinfo",
		"startuptime",
		"fugitive",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Turn off line numbers and spellcheck in terminal buffers.
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup("terminal_settings"),
	desc = "Sane defaults for terminal buffers",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.spell = false
	end,
})
