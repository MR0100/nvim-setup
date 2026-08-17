-- nvim-dap
-- --------
-- Debug Adapter Protocol client: real breakpoints, stepping, call stack, scopes
-- and a watch/REPL, rather than sprinkling print statements.
--
-- This config previously had no debugger at all.
--
--
-- KEYMAPS
-- -------
-- Stepping is on the function keys, matching what VS Code and most IDEs use.
-- That also keeps it clear of this config's existing leader mappings.
--
--   <F5>   continue / start        <S-F5>  terminate
--   <F10>  step over               <F9>    toggle breakpoint
--   <F11>  step into               <F12>   step out
--
-- Everything else lives under `<leader>x` ("e[x]ecute"). NOTE: `<leader>d` is
-- already the diagnostics group in this config and `<leader>D` is bound to
-- delete-without-yanking, so the conventional `<leader>d` debug prefix would
-- have collided with both.
--
--
-- WHICH LANGUAGES WORK
-- --------------------
--   Rust        -- via rustaceanvim + codelldb. Use `<leader>rd` (debuggables)
--                  from a Rust buffer; it builds the right target for you.
--   Go          -- via nvim-dap-go + delve. Requires a Go toolchain (Mason
--                  installs delve with `go install`).
--   Node / TS   -- via js-debug-adapter (installed by Mason, npm-based).
--   Dart/Flutter-- registered by flutter-tools.nvim, see lua/plugins/flutter.lua.
--
--   Bun         -- NOT supported for step debugging. Bun's inspector speaks the
--                  WebKit Inspector Protocol, while js-debug (and every mature
--                  nvim DAP adapter for JS) targets V8/Chrome DevTools. There
--                  is no maintained DAP bridge for it today. Use
--                  `bun --inspect` and Bun's own browser debugger, or drop to
--                  `console.log`. Bun *test* running still works fine through
--                  neotest -- see lua/plugins/neotest.lua.

return {
	{
		"mfussenegger/nvim-dap",

		dependencies = {
			-- UI: scopes, breakpoints, stacks, watches, and a REPL in panels.
			{
				"rcarriga/nvim-dap-ui",
				-- nvim-dap-ui needs nio; it is not optional.
				dependencies = { "nvim-neotest/nvim-nio" },
			},

			-- Shows variable values inline, as virtual text, next to the code.
			-- This is the single feature that makes a TUI debugger pleasant.
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {
					enabled = true,
					-- Don't show values for variables that are out of scope.
					only_first_definition = true,
					all_references = false,
					virt_text_pos = "eol",
				},
			},

			-- Go adapter. Wraps delve and figures out the right build target,
			-- including for individual tests.
			{
				"leoluz/nvim-dap-go",
				ft = "go",
				opts = {},
			},
		},

		keys = {
			-- [ STEPPING ] ------------------------------------------------------
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Debug: continue / start",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				desc = "Debug: step over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				desc = "Debug: step into",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				desc = "Debug: step out",
			},
			{
				"<S-F5>",
				function()
					require("dap").terminate()
				end,
				desc = "Debug: terminate",
			},

			-- [ BREAKPOINTS ] ---------------------------------------------------
			{
				"<F9>",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Debug: toggle breakpoint",
			},
			{
				"<leader>xb",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Debug: toggle [b]reakpoint",
			},
			{
				"<leader>xB",
				function()
					-- A conditional breakpoint only fires when the expression is
					-- true, which beats stepping through 400 loop iterations.
					vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
						if cond and cond ~= "" then
							require("dap").set_breakpoint(cond)
						end
					end)
				end,
				desc = "Debug: conditional [B]reakpoint",
			},
			{
				"<leader>xl",
				function()
					vim.ui.input({ prompt = "Log point message: " }, function(msg)
						if msg and msg ~= "" then
							require("dap").set_breakpoint(nil, nil, msg)
						end
					end)
				end,
				desc = "Debug: [l]og point",
			},
			{
				"<leader>xC",
				function()
					require("dap").clear_breakpoints()
				end,
				desc = "Debug: [C]lear all breakpoints",
			},

			-- [ SESSION ] -------------------------------------------------------
			{
				"<leader>xc",
				function()
					require("dap").continue()
				end,
				desc = "Debug: [c]ontinue / start",
			},
			{
				"<leader>xr",
				function()
					require("dap").restart()
				end,
				desc = "Debug: [r]estart session",
			},
			{
				"<leader>xq",
				function()
					require("dap").terminate()
				end,
				desc = "Debug: [q]uit session",
			},
			{
				"<leader>xp",
				function()
					require("dap").pause()
				end,
				desc = "Debug: [p]ause",
			},
			{
				"<leader>xj",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Debug: run to cursor ([j]ump)",
			},

			-- [ INSPECT ] -------------------------------------------------------
			{
				"<leader>xu",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug: toggle [u]I",
			},
			{
				"<leader>xe",
				function()
					require("dapui").eval(nil, { enter = true })
				end,
				mode = { "n", "v" },
				desc = "Debug: [e]val expression / selection",
			},
			{
				"<leader>xR",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Debug: toggle [R]EPL",
			},
			{
				"<leader>xf",
				function()
					require("dapui").float_element("scopes", { enter = true })
				end,
				desc = "Debug: [f]loat scopes",
			},
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ================================================================
			-- UI
			-- ================================================================
			dapui.setup({
				-- Two columns: variables/watches on the left, REPL below.
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.35 },
							{ id = "breakpoints", size = 0.15 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 45,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 12,
						position = "bottom",
					},
				},
				floating = { border = "rounded" },
			})

			-- Open the UI automatically when a session starts, and close it when
			-- the session ends, so you never have to manage the panels manually.
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- ================================================================
			-- Breakpoint signs
			-- ================================================================
			-- Single-width Nerd Font glyphs, to match the diagnostic signs in
			-- lua/plugins/lsp.lua and keep the sign column aligned.
			local signs = {
				DapBreakpoint = { text = "󰃤", texthl = "DiagnosticError" },
				DapBreakpointCondition = { text = "󰇽", texthl = "DiagnosticWarn" },
				DapLogPoint = { text = "󰛿", texthl = "DiagnosticInfo" },
				DapStopped = { text = "󰁕", texthl = "DiagnosticOk", linehl = "Visual" },
				DapBreakpointRejected = { text = "󰅚", texthl = "DiagnosticError" },
			}
			for name, opts in pairs(signs) do
				vim.fn.sign_define(name, opts)
			end

			-- ================================================================
			-- Node / TypeScript adapter (js-debug)
			-- ================================================================
			-- Mason installs `js-debug-adapter` and links it into its own bin
			-- directory, which mason.nvim prepends to PATH. Fall back to the
			-- absolute path in case PATH handling is ever disabled.
			local js_debug = "js-debug-adapter"
			if vim.fn.executable(js_debug) == 0 then
				local fallback = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter"
				if vim.fn.executable(fallback) == 1 then
					js_debug = fallback
				end
			end

			-- js-debug runs as a server and nvim-dap picks a free port for it.
			for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
				dap.adapters[adapter] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = js_debug,
						args = { "${port}" },
					},
				}
			end

			-- Node cannot execute TypeScript on its own on every version, so
			-- prefer `tsx` when the project has it. This keeps "debug the file
			-- I am looking at" working for .ts as well as .js.
			local function ts_runtime()
				if vim.fn.executable("tsx") == 1 then
					return "tsx"
				end
				return "node"
			end

			local js_filetypes =
				{ "javascript", "typescript", "javascriptreact", "typescriptreact" }

			for _, ft in ipairs(js_filetypes) do
				dap.configurations[ft] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch current file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						runtimeExecutable = (ft:match("^typescript") and ts_runtime() or "node"),
						sourceMaps = true,
						-- Don't step into node internals or dependencies.
						skipFiles = { "<node_internals>/**", "**/node_modules/**" },
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to running process (pick)",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**", "**/node_modules/**" },
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach on port 9229 (node --inspect)",
						address = "localhost",
						port = 9229,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**", "**/node_modules/**" },
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch Chrome against localhost:3000",
						url = "http://localhost:3000",
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
				}
			end
		end,
	},
}
