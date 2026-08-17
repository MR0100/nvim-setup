-- nvim-treesitter
-- ---------------
-- Parses your code into a syntax tree, which drives better highlighting,
-- indentation, and structural selection/motion.
--
-- NOTE: textobjects used to live in its own file and called `configs.setup()`
-- a second time. nvim-treesitter has a single global config, so calling setup
-- twice means the second call fights the first. Everything now lives here in
-- one setup call, with textobjects declared as a dependency.

return {
	"nvim-treesitter/nvim-treesitter",
	-- IMPORTANT: pin the branch explicitly.
	-- Upstream flipped its DEFAULT branch from `master` to `main`, and `main`
	-- is a full incompatible rewrite that deletes `nvim-treesitter.configs`
	-- (the module this file uses). Without this line, `:Lazy update` silently
	-- moves to `main` and the config hard-errors on next launch.
	--
	-- Caveat: `master` is frozen and targets Neovim 0.11, while you run 0.12.
	-- This pin is a stopgap that keeps things working today; migrating to
	-- `main` is a deliberate rewrite, not an update.
	branch = "master",
	build = ":TSUpdate",
	dependencies = {
		-- textobjects flipped its default branch to `main` too, for the same reason.
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
	},
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c",			"lua",			"vim",			"vimdoc",
				"query",		"elixir",		"heex",			"dart",
				"html",			"css",			"rust",			"python",
				"javascript",	"typescript",	"markdown",		"markdown_inline",
				"json",			"yaml",			"toml",			"bash",

				-- [ GO ] -- the module/sum/work grammars matter as much as the
				-- language one; without them go.mod is an unhighlighted blob.
				"go",			"gomod",		"gosum",		"gowork",

				-- [ WEB / NODE ] -- `tsx` is a separate grammar from
				-- `typescript` and is what React .tsx files actually use.
				"tsx",			"jsdoc",		"jsonc",		"scss",
				"graphql",		"prisma",

				-- [ TOOLING ] -- diffs, commit messages and interactive rebase
				-- buffers all get real highlighting, which makes reviewing in
				-- neogit/diffview far easier to read.
				"diff",			"git_rebase",	"gitcommit",	"gitignore",
				"git_config",	"dockerfile",	"make",			"sql",
				"regex",		"ssh_config",
			},
			sync_install = false,
			-- auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<Enter>", -- set to `false` to disable one of the mappings
					node_incremental = "<Enter>",
					scope_incremental = false,
					node_decremental = "<Backspace>",
				},
			},

			textobjects = {
				-- [ SELECT ]
				-- Operate on syntax nodes: `daf` deletes a whole function,
				-- `vif` selects a function body, etc.
				select = {
					enable = true,

					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,

					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",

						-- You can optionally set descriptions to the mappings (used in the desc parameter of nvim_buf_set_keymap) which plugins like which-key display
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },

						-- You can also use captures from other query groups like `locals.scm`
						["as"] = { query = "@local.scope", query_group = "locals", desc = "Select langauge scope" },

						-- Parameters/arguments. `daa` deletes an argument including
						-- its comma, `cia` changes just the argument itself.
						["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter" },
						["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter" },
					},

					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-V>') or a table
					-- mapping query_strings to modes.
					selection_modes = {
						['@parameter.outer'] = 'v',		-- charwise
						['@function.outer'] = 'V',		-- linewise
						['@class.outer'] = '<c-V>',		-- blockwise
					},

					-- If you set this to `true` (default is `false`) then any textobject is extended to include preceding or succeeding whitespace.
					-- Succeeding whitespace has priority in order to act similarly to eg the build-in `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true or false.
					include_surrounding_whitespace = true,
				},

				-- [ MOVE ]
				-- Jump between syntax nodes. These are the ones you end up using
				-- constantly once they exist. All of them are repeatable with `;`/`,`.
				move = {
					enable = true,
					set_jumps = true, -- record these jumps in the jumplist, so <C-o> works

					goto_next_start = {
						["]m"] = { query = "@function.outer", desc = "Next function start" },
						["]]"] = { query = "@class.outer", desc = "Next class start" },
						["]a"] = { query = "@parameter.inner", desc = "Next parameter" },
					},
					goto_next_end = {
						["]M"] = { query = "@function.outer", desc = "Next function end" },
						["]["] = { query = "@class.outer", desc = "Next class end" },
					},
					goto_previous_start = {
						["[m"] = { query = "@function.outer", desc = "Previous function start" },
						["[["] = { query = "@class.outer", desc = "Previous class start" },
						["[a"] = { query = "@parameter.inner", desc = "Previous parameter" },
					},
					goto_previous_end = {
						["[M"] = { query = "@function.outer", desc = "Previous function end" },
						["[]"] = { query = "@class.outer", desc = "Previous class end" },
					},
				},

				-- [ SWAP ]
				-- Reorder arguments/functions without cutting and pasting.
				swap = {
					enable = true,
					swap_next = {
						["<leader>sn"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
					},
					swap_previous = {
						["<leader>sp"] = { query = "@parameter.inner", desc = "Swap parameter with previous" },
					},
				},
			},
		})
	end,
}
