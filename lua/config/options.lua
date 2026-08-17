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

-- Share the system clipboard, so y/p work across nvim and every other app.
-- Scheduled because checking the clipboard provider at startup measurably
-- slows nvim down. See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Highlight matches as you search, and while typing the pattern.
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Wrap long lines at word boundaries rather than mid-word.
vim.opt.linebreak = true

-- Ask to save instead of failing when quitting with unsaved changes.
vim.opt.confirm = true

-- Time to wait for a mapped sequence to complete, and how long which-key
-- waits before showing its popup.
vim.opt.timeoutlen = 400

-- [ FOLDING ]
-- Treesitter-driven folds: fold by actual code structure, not indentation.
-- `za` toggles a fold, `zR` opens all, `zM` closes all.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99   -- start with everything unfolded
vim.opt.foldnestmax = 4

-- Rounded borders for all floating windows (hover, diagnostics, etc).
-- Requires Neovim 0.11+; harmless to skip on older versions.
if vim.fn.has("nvim-0.11") == 1 then
	vim.opt.winborder = "rounded"
end

-- Disable language providers this config does not use. Each one that stays
-- enabled costs a `:checkhealth` warning and a little startup time.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
