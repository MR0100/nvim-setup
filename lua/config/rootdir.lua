--[[

Project Root Detection
----------------------

This replaces `ahmedkhalf/project.nvim`, which is unmaintained and still calls
`vim.lsp.buf_get_clients()` -- an API Neovim removed in 0.12. That single call
was the only thing left in this config making `:checkhealth vim.deprecated`
complain.

Neovim 0.10+ ships `vim.fs.root()`, which does the same "walk up until you find
a marker" search natively, so the plugin is not needed at all. All that is left
to do is watch for buffers being entered and `:cd` into the root of whatever
file we just landed on.

Everything that reads the current directory then follows along, which is the
whole point of doing this: the `files()` and `live_grep()` pickers in
`lua/plugins/fzflua.lua` are called without a `cwd`, so they search from the
project root rather than from the directory nvim happened to be launched in.

NOTE -- marker precedence:
Careful here, because `vim.fs.root()` on its own does NOT behave the way
project.nvim did. Given a list of markers it tries them *in order* and returns
the first one that matches anywhere up the tree -- so `.git` would always win,
even when a `Cargo.toml` sits much closer to the file. In a monorepo like

	repo/.git
	repo/crates/engine/Cargo.toml
	repo/crates/engine/src/lib.rs

that gives you `repo`, whereas project.nvim gave you `repo/crates/engine`.

project.nvim walked *directories* outward and checked every pattern at each
level, i.e. "the closest marker wins, whatever it is". `find_root()` below
keeps that behaviour by asking `vim.fs.root()` about one marker at a time and
keeping the deepest answer. Every candidate is an ancestor of the same file, so
the longest path is by definition the closest one.

If you would rather have the repository root win project-wide (nice when you
want one fuzzy-find across a whole monorepo), delete `find_root()` and use
`vim.fs.root()` directly -- the marker order in `M.patterns` then becomes the
priority order:

	local function find_root(buf)
		return vim.fs.root(vim.api.nvim_buf_get_name(buf), M.patterns)
	end

--]]

local M = {}

-- Root markers. Order does not matter while `find_root()` picks the closest
-- match; it only becomes a priority list if you switch to plain `vim.fs.root()`
-- as described above.
M.patterns = {
	".git",
	"Cargo.toml",		-- rust
	"pubspec.yaml",		-- dart / flutter
	"package.json",		-- js / ts
	"Makefile",
}

-- Only real, on-disk file buffers should move the working directory.
-- This skips help pages, quickfix, terminals, the empty startup buffer, and
-- plugin buffers that use a URI for a name (`oil://`, `fugitive://`, ...).
local function is_real_file(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end

	local buftype = vim.bo[buf].buftype
	if buftype ~= "" and buftype ~= "acwrite" then
		return false
	end

	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or name:find("://", 1, true) then
		return false
	end

	return true
end

--- Nearest ancestor of `buf` holding any of `M.patterns`.
--- One `vim.fs.root()` call per marker, keeping the deepest hit -- see the
--- marker precedence note at the top of this file for why.
---@param buf integer buffer handle
---@return string|nil root absolute path of the project root, if any
local function find_root(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	local closest = nil

	for _, pattern in ipairs(M.patterns) do
		local root = vim.fs.root(name, pattern)
		if root and (closest == nil or #root > #closest) then
			closest = root
		end
	end

	return closest
end

--- Change directory to the project root owning `buf`.
--- Does nothing when the buffer is not a file, or when no marker is found --
--- staying put is better than guessing.
---@param buf? integer buffer handle, defaults to the current buffer
function M.set_root(buf)
	buf = buf or vim.api.nvim_get_current_buf()

	if not is_real_file(buf) then
		return
	end

	local root = find_root(buf)
	if root == nil then
		return
	end

	-- `getcwd(-1, -1)` is the *global* cwd, which is what we set below.
	if root ~= vim.fn.getcwd(-1, -1) then
		vim.api.nvim_set_current_dir(root)
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("root-dir", { clear = true }),
	desc = "Set cwd to the project root of the current file",
	-- `nested` so that the DirChanged fired by the `:cd` still reaches anything
	-- listening for it. The `root ~= cwd` check in `set_root()` is what stops
	-- this from looping.
	nested = true,
	callback = function(event)
		M.set_root(event.buf)
	end,
})

-- Manual re-trigger, same name project.nvim used to provide.
vim.api.nvim_create_user_command("ProjectRoot", function()
	M.set_root()
	vim.notify("cwd: " .. vim.fn.getcwd(-1, -1))
end, { desc = "Re-detect the project root for the current buffer" })

return M
