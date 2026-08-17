-- Keymaps
-- -------
-- Global keymaps only. Plugin-specific ones live with their plugin spec, and
-- buffer-local LSP ones are set in the LspAttach autocmd in plugins/lsp.lua.

local map = vim.keymap.set

-- [ FILE EXPLORER ]
map("n", "<leader>-", "<cmd>Oil --float<CR>", { desc = "Open Parent Directory in Oil" })

-- [ DIAGNOSTICS ]
-- NOTE: this used to be `|sd`, which shadowed the built-in `|` motion (go to
-- column 1) and made every plain `|` wait for the timeout before firing.
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "[d]iagnostic [f]loat" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "[d]iagnostics to [q]uickfix list" })
-- `vim.diagnostic.jump` is 0.11+; `goto_next`/`goto_prev` are the 0.10 names
-- and are deprecated in 0.11. Support both so this config is not pinned to
-- one Neovim version.
local function diagnostic_jump(count)
	return function()
		if vim.diagnostic.jump then
			vim.diagnostic.jump({ count = count, float = true })
		elseif count > 0 then
			vim.diagnostic.goto_next({ float = true })
		else
			vim.diagnostic.goto_prev({ float = true })
		end
	end
end

map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "[d", diagnostic_jump(-1), { desc = "Previous diagnostic" })

-- [ SEARCH ]
-- Clear the search highlight left over after a search.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Keep the cursor centred when jumping between matches, so you always have
-- context above and below.
map("n", "n", "nzzzv", { desc = "Next search match (centred)" })
map("n", "N", "Nzzzv", { desc = "Previous search match (centred)" })

-- [ SCROLLING ]
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })

-- [ WINDOWS ]
-- Move between splits without the <C-w> prefix.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>_", "<cmd>split<CR>", { desc = "Split window horizontally" })

-- Resize splits with the arrow keys.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- [ BUFFERS ]
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "[b]uffer [d]elete" })
map("n", "<leader>bb", "<cmd>edit #<CR>", { desc = "[b]ack to previous [b]uffer" })

-- [ SAVING ]
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save file" })

-- [ EDITING ]
-- Stay in visual mode after indenting, so you can repeat it.
map("v", "<", "<gv", { desc = "Indent left and keep selection" })
map("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Move the selected lines up and down, re-indenting as they go.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Paste over a selection without clobbering the unnamed register with the
-- text you just replaced.
map("x", "<leader>p", [["_dP]], { desc = "[p]aste without yanking replaced text" })

-- Delete to the black hole register.
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "[D]elete without yanking" })
