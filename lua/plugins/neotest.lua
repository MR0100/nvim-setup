-- neotest
-- -------
-- Runs the test under your cursor, or the whole file, and shows pass/fail marks
-- in the sign column next to each test. Failures open with the actual output,
-- so you do not have to read a scrollback of `go test ./...` to find which
-- assertion broke.
--
-- The payoff over a terminal is the tight loop: `<leader>tn` reruns just the one
-- test you are working on, and `<leader>tl` reruns whatever you ran last from
-- anywhere in the project.
--
--
-- KEYMAPS -- under `<leader>t`
-- ----------------------------
-- NOTE: `<leader>t` is this config's "toggle" prefix (`<leader>tf` format,
-- `<leader>tk` keys, `<leader>tt*` terminals). The test mappings are folded into
-- the same prefix rather than claiming a new one, so which-key labels the group
-- "toggle / test". None of the letters below collide.
--
--   <leader>tn  nearest test        <leader>ts  summary panel
--   <leader>tF  whole file          <leader>to  output for nearest
--   <leader>ta  whole suite         <leader>tO  output panel (toggle)
--   <leader>tl  last test run       <leader>tS  stop the running test
--   <leader>td  debug nearest test (via nvim-dap)
--
--
-- ADAPTERS
-- --------
-- An adapter teaches neotest how one test runner reports results. Each is
-- independent, and an adapter whose runner is not installed simply never
-- matches any file.
--
--   Go      -- neotest-golang (delegates to `go test`, needs a Go toolchain)
--   Vitest  -- neotest-vitest
--   Jest    -- neotest-jest
--   Rust    -- provided by rustaceanvim itself, not a separate plugin
--   Dart    -- neotest-dart (`flutter test`)
--
-- BUN: `bun test` is Jest-flavoured but not Jest, and there is no maintained
-- neotest adapter for it. Run it from the terminal instead (`<C-\>` then
-- `bun test --watch`). The Vitest adapter does work for Bun projects that use
-- Vitest as the runner.

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/nvim-nio",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",

			-- Adapters.
			"fredrikaverpil/neotest-golang",
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-jest",
			"sidlatau/neotest-dart",
		},
		keys = {
			{
				"<leader>tn",
				function()
					require("neotest").run.run()
				end,
				desc = "[t]est: [n]earest",
			},
			{
				"<leader>tF",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[t]est: whole [F]ile",
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.run(vim.uv.cwd())
				end,
				desc = "[t]est: [a]ll (whole suite)",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "[t]est: re-run [l]ast",
			},
			{
				"<leader>tS",
				function()
					require("neotest").run.stop()
				end,
				desc = "[t]est: [S]top running test",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[t]est: [s]ummary panel",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "[t]est: [o]utput for nearest",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "[t]est: [O]utput panel",
			},
			{
				"<leader>td",
				function()
					-- Runs the nearest test under nvim-dap, so breakpoints in the
					-- test and in the code it exercises both work.
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "[t]est: [d]ebug nearest",
			},
		},
		config = function()
			local adapters = {}

			-- Only register the Go adapter when there is a Go toolchain; it
			-- shells out to `go test` and `go list`.
			if vim.fn.executable("go") == 1 then
				table.insert(
					adapters,
					require("neotest-golang")({
						go_test_args = { "-v", "-count=1" },
						dap_go_enabled = true, -- reuse nvim-dap-go for <leader>td
					})
				)
			end

			table.insert(
				adapters,
				require("neotest-vitest")({
					-- Don't treat every JS file as a possible test file; only
					-- ones that look like tests.
					filter_dir = function(name)
						return name ~= "node_modules" and name ~= "dist" and name ~= ".git"
					end,
				})
			)

			table.insert(
				adapters,
				require("neotest-jest")({
					jestCommand = "npm test --",
					env = { CI = true },
					cwd = function()
						return vim.uv.cwd()
					end,
				})
			)

			if vim.fn.executable("flutter") == 1 or vim.fn.executable("dart") == 1 then
				table.insert(
					adapters,
					require("neotest-dart")({
						command = vim.fn.executable("flutter") == 1 and "flutter" or "dart",
						use_lsp = true,
					})
				)
			end

			-- rustaceanvim ships its own neotest adapter rather than shipping a
			-- separate plugin. Register it only if rustaceanvim is installed.
			local ok_rust, rustaceanvim_neotest = pcall(require, "rustaceanvim.neotest")
			if ok_rust then
				table.insert(adapters, rustaceanvim_neotest)
			end

			require("neotest").setup({
				adapters = adapters,

				-- Pass/fail marks in the sign column.
				status = { virtual_text = true, signs = true },
				output = { open_on_run = false },

				quickfix = {
					-- Don't hijack the quickfix list; <leader>to shows output.
					enabled = false,
					open = false,
				},

				summary = {
					animated = false,
					mappings = {
						run = "r",
						debug = "d",
						expand = { "<CR>", "<2-LeftMouse>" },
						jumpto = "i",
						output = "o",
						stop = "u",
					},
				},

				icons = {
					passed = "󰄬",
					failed = "󰅚",
					running = "󰑮",
					skipped = "󰙨",
					unknown = "󰋼",
				},
			})
		end,
	},
}
