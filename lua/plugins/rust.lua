-- rustaceanvim
-- ------------
-- Replaces the hand-rolled `rust_analyzer` block that used to live in
-- lua/plugins/lsp.lua. It is not just an LSP wrapper -- it adds the things
-- rust-analyzer exposes over LSP extensions that a plain setup cannot reach:
--
--   * runnables / testables  -- run the exact test or binary under the cursor
--   * expand macro           -- see what a macro actually generates
--   * explain error          -- full rustc explanation for the error code
--   * open Cargo.toml, parent module, join lines, move item up/down
--   * DAP integration, wired to codelldb automatically
--
-- IMPORTANT: rustaceanvim configures and starts rust_analyzer *itself*. It must
-- not also be enabled by mason-lspconfig, or you get two servers indexing the
-- same crate. That exclusion lives in lua/plugins/lsp.lua.
--
-- This plugin is configured through the `vim.g.rustaceanvim` global rather than
-- a `setup()` call, so there is deliberately no `opts`/`config` here.
--
--
-- REQUIREMENTS
-- ------------
-- rustaceanvim does NOT install rust-analyzer, and Mason is not used for it
-- either (the rustup-managed one always matches your toolchain). You need the
-- component installed:
--
--     rustup component add rust-analyzer
--     rustup component add clippy          # used by check.command below
--
-- Watch out for a specific trap: `rustup` puts a *shim* named `rust-analyzer` on
-- your PATH whether or not the component is installed. So `command -v
-- rust-analyzer` succeeds, the server starts, and then dies immediately with:
--
--     error: Unknown binary 'rust-analyzer' in official toolchain '...'
--
-- which surfaces in Neovim only as "Client rust-analyzer quit with exit code 1".
-- Verify what is actually installed with:
--
--     rustup component list --installed | grep rust-analyzer

return {
	{
		"mrcjkb/rustaceanvim",
		-- Loading on the filetype is enough; it registers everything it needs.
		ft = { "rust" },
		init = function()
			-- IMPORTANT: `vim.g.rustaceanvim` is assigned a *function*, not a
			-- table. rustaceanvim accepts either, and calls the function when it
			-- loads.
			--
			-- That distinction matters: lazy.nvim runs `init` during startup,
			-- before the plugin is on the runtimepath, so a table built here
			-- could not `require("rustaceanvim.config")` to construct the DAP
			-- adapter -- the module would not resolve yet. Deferring everything
			-- into a function moves that require to after the plugin has loaded.
			vim.g.rustaceanvim = function()
				-- Locate the codelldb that Mason installs, for debugging.
				local function codelldb_paths()
					local ok, mason_registry = pcall(require, "mason-registry")
					if not ok or not mason_registry.is_installed("codelldb") then
						return nil, nil
					end

					local pkg = mason_registry.get_package("codelldb")
					local root = pkg:get_install_path() .. "/extension"
					local sysname = vim.uv.os_uname().sysname
					local ext = sysname == "Windows_NT" and ".exe" or ""
					local lib_ext = sysname == "Darwin" and ".dylib" or ".so"

					return root .. "/adapter/codelldb" .. ext,
						root .. "/lldb/lib/liblldb" .. lib_ext
				end

				-- When codelldb is missing, leave `dap` empty and let
				-- rustaceanvim fall back to its own detection (a system lldb).
				local dap_config = {}
				local adapter, library = codelldb_paths()
				if adapter then
					local ok, rust_config = pcall(require, "rustaceanvim.config")
					if ok then
						dap_config.adapter = rust_config.get_codelldb_adapter(adapter, library)
					end
				end

				return {
					tools = {
						float_win_config = { border = "rounded" },
					},

					server = {
						on_attach = function(_, bufnr)
							local function map(keys, func, desc)
								vim.keymap.set(
									"n",
									keys,
									func,
									{ buffer = bufnr, desc = "Rust: " .. desc }
								)
							end

							-- The high-value rustaceanvim commands. These have no
							-- equivalent in a plain rust_analyzer setup.
							map("<leader>rr", function()
								vim.cmd.RustLsp("runnables")
							end, "[r]unnables (run binary/test under cursor)")

							map("<leader>rt", function()
								vim.cmd.RustLsp("testables")
							end, "[t]estables")

							map("<leader>rd", function()
								vim.cmd.RustLsp("debuggables")
							end, "[d]ebuggables (build + attach debugger)")

							map("<leader>rm", function()
								vim.cmd.RustLsp("expandMacro")
							end, "expand [m]acro")

							map("<leader>re", function()
								vim.cmd.RustLsp("explainError")
							end, "[e]xplain error under cursor")

							map("<leader>rD", function()
								vim.cmd.RustLsp("renderDiagnostic")
							end, "render [D]iagnostic (full rustc output)")

							map("<leader>rc", function()
								vim.cmd.RustLsp("openCargo")
							end, "open [c]argo.toml")

							map("<leader>rp", function()
								vim.cmd.RustLsp("parentModule")
							end, "go to [p]arent module")

							-- `K` for hover actions is strictly better than plain
							-- hover in Rust: press it twice to follow the
							-- actionable links it offers.
							map("K", function()
								vim.cmd.RustLsp({ "hover", "actions" })
							end, "hover actions")
						end,

						default_settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
									-- A separate target dir so `cargo build` in a
									-- terminal does not fight rust-analyzer for
									-- the build lock. This is the single biggest
									-- quality-of-life win for Rust in an editor.
									targetDir = true,
								},

								-- NOTE: `checkOnSave` is a BOOLEAN in current
								-- rust-analyzer. The old
								-- `checkOnSave = { command = "clippy" }` form is
								-- rejected with "invalid type: map, expected a
								-- boolean", which meant clippy was never actually
								-- running. The command moved to `check.command`.
								checkOnSave = true,
								check = {
									command = "clippy",
									extraArgs = { "--no-deps" }, -- don't lint dependencies
								},

								procMacro = {
									enable = true,
									ignored = {
										-- These macros are known to choke the
										-- expander; ignoring them avoids
										-- spurious errors in async code.
										["async-trait"] = { "async_trait" },
										["napi-derive"] = { "napi" },
									},
								},

								inlayHints = {
									lifetimeElisionHints = { enable = "skip_trivial" },
									closureReturnTypeHints = { enable = "with_block" },
								},
							},
						},
					},

					dap = dap_config,
				}
			end
		end,
	},
}
