vim.opt.expandtab = true		-- Convert tabs to spaces. 
vim.opt.shiftwidth = 4 			-- Amount to indent with << and >>
vim.opt.tabstop = 4 			-- How many spaces are shown per Tab
vim.opt.softtabstop = 4 		-- How many spaces are applied when pressing Tab

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true 		-- Keep indentation from previous line

-- Always show relative line number 
vim.opt.number = true
vim.opt.relativenumber = true

-- Show line under cursor
vim.opt.cursorline = true

-- Store undos between sessions
vim.opt.undofile = true

-- Enable mouse mode, can be useful for resizing splits.
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line. 
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor 
vim.opt.scrolloff = 10

-- Disable commandline until it is needed. This gives us a cleaner look and an extra line ;)
-- vim.opt.cmdheight = 0

-- Sets how neovim will display certain whitecharacters in the editor. 
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣"}
