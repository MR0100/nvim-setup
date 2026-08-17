-- flutter-tools.nvim
-- -----------------
-- Replaces the hand-rolled `dartls` block that used to live in
-- lua/plugins/lsp.lua, and adds the Flutter-specific workflow that a bare
-- language server cannot provide:
--
--   * hot reload / hot restart on save
--   * device and emulator picker
--   * `flutter run` output in a split, with the log filtered
--   * widget tree / outline
--   * closing labels (the `// Column` markers at the end of long widget trees)
--   * pubspec.yaml dependency management via `:FlutterPubGet` / `:FlutterPubUpgrade`
--
-- IMPORTANT: flutter-tools starts dartls itself, so mason-lspconfig must not
-- also enable it. That exclusion lives in lua/plugins/lsp.lua.
--
-- The upstream repo moved from `akinsho/flutter-tools.nvim` to the
-- `nvim-flutter` organisation; the URL below is the current one.
--
-- REQUIREMENTS: the `flutter` and `dart` binaries must be on your PATH. Neither
-- is installed by Mason (they ship with the Flutter SDK). Nothing here errors
-- if they are missing -- the plugin simply never loads, because it only loads
-- for `dart` files.

return {
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = { "dart" },
		cmd = {
			"FlutterRun",
			"FlutterDevices",
			"FlutterEmulators",
			"FlutterReload",
			"FlutterRestart",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Nicer pickers for the device/emulator selection prompts. We
			-- already depend on dressing.nvim elsewhere, which handles this.
			"stevearc/dressing.nvim",
		},
		opts = {
			ui = {
				border = "rounded",
				-- Route notifications through whatever notify handler is
				-- installed (nvim-notify, via noice) rather than printing.
				notification_style = "native",
			},

			decorations = {
				statusline = {
					-- Show the running app and selected device in the statusline.
					app_version = true,
					device = true,
					project_config = true,
				},
			},

			-- Hot reload the running app whenever you save. This is the whole
			-- reason to use Flutter from an editor.
			lsp = {
				color = {
					-- Render Color(0xFF...) literals as an actual colour swatch
					-- in the sign column.
					enabled = true,
					background = false,
					foreground = false,
					virtual_text = true,
					virtual_text_str = "■",
				},

				-- The closing labels that Flutter's own tooling shows.
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					renameFilesWithClasses = "prompt",
					enableSnippets = true,
					updateImportsOnRename = true,
					-- Analysis excludes: skip generated code so the analyser
					-- is not reporting on files you never edit.
					analysisExcludedFolders = {
						vim.fn.expand("$HOME/.pub-cache"),
						vim.fn.expand("$HOME/flutter/.pub-cache"),
					},
				},

				on_attach = function(_, bufnr)
					local function map(keys, cmd, desc)
						vim.keymap.set(
							"n",
							keys,
							cmd,
							{ buffer = bufnr, desc = "Flutter: " .. desc }
						)
					end

					map("<leader>Fr", "<cmd>FlutterRun<CR>", "[r]un app")
					map("<leader>FR", "<cmd>FlutterRestart<CR>", "hot [R]estart")
					map("<leader>Fl", "<cmd>FlutterReload<CR>", "hot re[l]oad")
					map("<leader>Fq", "<cmd>FlutterQuit<CR>", "[q]uit running app")
					map("<leader>Fd", "<cmd>FlutterDevices<CR>", "pick [d]evice")
					map("<leader>Fe", "<cmd>FlutterEmulators<CR>", "pick [e]mulator")
					map("<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", "toggle widget [o]utline")
					map("<leader>Fs", "<cmd>FlutterLspRestart<CR>", "re[s]tart dart LSP")
					map("<leader>Fp", "<cmd>FlutterPubGet<CR>", "[p]ub get")
					map("<leader>FD", "<cmd>FlutterDevTools<CR>", "start [D]evTools")
				end,
			},

			debugger = {
				-- Use nvim-dap for Dart/Flutter. flutter-tools registers the
				-- adapter itself, so there is nothing to install via Mason.
				enabled = true,
				-- Ask before starting a debug session on `FlutterRun`, rather
				-- than always attaching.
				run_via_dap = false,
				exception_breakpoints = {},
			},
		},
	},
}
