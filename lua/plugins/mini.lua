-- mini.nvim modules
-- -----------------
-- This config leans on mini.nvim rather than pulling in a separate plugin for
-- each small behaviour. mini.statusline lives in lua/plugins/statusline.lua;
-- everything else is here.

return {
	-- ====================================================================
	-- [ mini.icons ]
	-- ====================================================================
	-- Filetype/folder icons. Already used by fzf-lua and oil, but it was only
	-- ever declared as *their* dependency, which left it without a config of
	-- its own.
	--
	-- IMPORTANT: most of the wider ecosystem (bufferline, neogit, diffview,
	-- nvim-dap-ui, neotest) asks for `nvim-web-devicons` by name and silently
	-- falls back to no icons when it is absent. mini.icons ships a shim that
	-- registers itself under that module name, so those plugins get icons
	-- without installing a second icon provider. Without the mock call below,
	-- half the new UI renders with blank gutters.
	{
		"echasnovski/mini.icons",
		version = false,
		lazy = true,
		opts = {},
		init = function()
			-- Registered lazily: the shim is installed the first time anything
			-- requires nvim-web-devicons.
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	-- ====================================================================
	-- [ mini.pairs ]
	-- ====================================================================
	-- Auto-inserts the closing bracket/quote, and deletes both halves when you
	-- backspace over the opening one.
	{
		"echasnovski/mini.pairs",
		version = false,
		event = "InsertEnter",
		opts = {},
	},

	-- ====================================================================
	-- [ mini.surround ]
	-- ====================================================================
	-- Add / delete / replace surrounding characters.
	--   sa  -- add     e.g. `saiw"` wraps the word under the cursor in quotes
	--   sd  -- delete  e.g. `sd"`   removes the surrounding quotes
	--   sr  -- replace e.g. `sr"'`  turns "text" into 'text'
	--   sf / sF -- find surrounding, forward / backward
	--   sh  -- highlight surrounding
	{
		"echasnovski/mini.surround",
		version = false,
		keys = { "sa", "sd", "sr", "sf", "sF", "sh" },
		opts = {},
	},

	-- ====================================================================
	-- [ mini.starter ]
	-- ====================================================================
	-- The screen you land on when you run `nvim` with no arguments. Chosen over
	-- a standalone dashboard plugin because it is one more mini module rather
	-- than a new dependency tree, and it reads its items from real commands.
	{
		"echasnovski/mini.starter",
		version = false,
		-- VimEnter so it only shows for a bare `nvim`, never in place of a file
		-- you actually asked for.
		event = "VimEnter",
		opts = function()
			local starter = require("mini.starter")
			return {
				evaluate_single = true,
				header = table.concat({
					"                                            ",
					"  ███╗   ██╗██╗   ██╗██╗███╗   ███╗         ",
					"  ████╗  ██║██║   ██║██║████╗ ████║         ",
					"  ██╔██╗ ██║██║   ██║██║██╔████╔██║         ",
					"  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║         ",
					"  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║         ",
					"  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝         ",
				}, "\n"),
				items = {
					{ name = "Find files", action = "FzfLua files", section = "Search" },
					{ name = "Live grep", action = "FzfLua live_grep", section = "Search" },
					{ name = "Recent files", action = "FzfLua oldfiles", section = "Search" },
					{
						name = "Restore session",
						action = function()
							require("persistence").load()
						end,
						section = "Session",
					},
					{
						name = "Config",
						action = function()
							require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
						end,
						section = "Config",
					},
					{ name = "Lazy (plugins)", action = "Lazy", section = "Config" },
					{ name = "Mason (tools)", action = "Mason", section = "Config" },
					{ name = "Checkhealth", action = "checkhealth", section = "Config" },
					{ name = "Quit", action = "qall", section = "Config" },
				},
				content_hooks = {
					starter.gen_hook.adding_bullet(),
					starter.gen_hook.aligning("center", "center"),
				},
			}
		end,
	},
}
