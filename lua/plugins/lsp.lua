--[[

LSP
---

The Language Server Protocol (LSP) is an open, JSON-RPC-based protocol used
between source code editors and servers that provide "language intelligence":
completion, diagnostics, go-to-definition, rename, code actions, and so on.

The goal of the protocol is to let language support be implemented and
distributed independently of any given editor.


HOW THIS FILE WORKS (and what changed)
--------------------------------------
Neovim 0.11 introduced `vim.lsp.config()` and `vim.lsp.enable()`. nvim-lspconfig
no longer "sets up" servers itself. It now just ships ~400 default config files
in its own `lsp/` directory, which Neovim discovers automatically because the
plugin is on the runtimepath. Our only job here is to:

  1. override the bits of those defaults we care about, via `vim.lsp.config()`
  2. make sure the servers get enabled

Two APIs this file used to rely on are gone or going:

  * `require('lspconfig')[server].setup({...})` -- deprecated, and scheduled for
    removal in nvim-lspconfig v3.0.0. It prints a loud deprecation traceback.

  * mason-lspconfig's `handlers = { ... }` option -- REMOVED in mason-lspconfig
    2.x. Its settings schema is now only `ensure_installed` and
    `automatic_enable`. Anything passed as `handlers` is silently ignored, which
    is why the previous version of this file applied *none* of its server
    settings: lua_ls never got `callSnippet`, and no server ever received the
    nvim-cmp capabilities.

Servers owned by a dedicated plugin are excluded from automatic enabling and
configured there instead:

  * `rust_analyzer` -> lua/plugins/rust.lua    (rustaceanvim)
  * `dartls`        -> lua/plugins/flutter.lua (flutter-tools.nvim)

Enabling them in both places starts two copies of the server.

--]]

-- Neovim version guard. `vim.lsp.config` is 0.11+; there is no sensible
-- fallback, so fail loudly rather than half-working.
if vim.fn.has("nvim-0.11") == 0 then
	vim.notify(
		"This LSP config requires Neovim 0.11+ (uses vim.lsp.config). Please upgrade.",
		vim.log.levels.ERROR
	)
	return {}
end

-- Some tooling can only be installed if its host toolchain is present. Mason
-- builds the Go tools with `go install`, so without a Go toolchain those
-- installs fail noisily on every startup. Gate them.
local has_go = vim.fn.executable("go") == 1

return {
	{
		-- Main LSP configuration.
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- NOTE: the `williamboman/mason*` repos were transferred to the
			-- `mason-org` organisation. The old URLs still redirect, but the new
			-- ones are canonical.
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP progress, bottom right.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Extra completion capabilities provided by nvim-cmp.
			"hrsh7th/cmp-nvim-lsp",

			-- Ships the JSON/YAML schemas from schemastore.org, so jsonls and
			-- yamlls can validate and complete package.json, tsconfig.json,
			-- .eslintrc, GitHub Actions workflows, docker-compose.yml and so on.
			-- Without it those files get syntax checking only.
			"b0o/schemastore.nvim",
		},
		config = function()
			-- ================================================================
			-- Buffer-local keymaps, set when a server attaches
			-- ================================================================
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- Small helper so we don't repeat the mode/buffer/desc
					-- boilerplate on every mapping.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(
							mode,
							keys,
							func,
							{ buffer = event.buf, desc = "LSP: " .. desc }
						)
					end

					-- Jump to the definition of the word under the cursor: where
					-- a variable was first declared, or a function defined.
					-- Jump back with <C-t>.
					map(
						"<leader>flgd",
						require("fzf-lua").lsp_definitions,
						"[l]sp [g]oto [d]efinition"
					)

					-- Find references for the word under the cursor.
					map(
						"<leader>flgr",
						require("fzf-lua").lsp_references,
						"[l]sp [g]oto [r]eferences"
					)

					-- Jump to the implementation. Useful in languages that can
					-- declare a type without implementing it.
					map(
						"<leader>flgI",
						require("fzf-lua").lsp_implementations,
						"[l]sp [g]oto [I]mplementation"
					)

					-- Jump to the *type* of the word under the cursor, rather
					-- than to where it was defined.
					map(
						"<leader>flT",
						require("fzf-lua").lsp_typedefs,
						"[<leader>]:operator [T]ype"
					)

					-- Fuzzy find symbols across the whole workspace.
					map(
						"<leader>fllws",
						require("fzf-lua").lsp_live_workspace_symbols,
						"[<leader>]:operator [L]ive [W]orkspace [S]ymbols"
					)

					-- Fuzzy find symbols in just this document.
					map(
						"<leader>flds",
						require("fzf-lua").lsp_document_symbols,
						"[l]sp [d]ocument [s]ymbols"
					)

					-- Rename the symbol under the cursor, across files.
					map("<leader>flrn", vim.lsp.buf.rename, "[<leader>]:operator [C]ode re[N]ame")

					-- Run a code action. Usually the cursor needs to be on a
					-- diagnostic or a server suggestion for this to offer
					-- anything.
					map(
						"<leader>flca",
						vim.lsp.buf.code_action,
						"[<leader>]:operator [C]ode [A]ction",
						{ "n", "x" }
					)

					-- WARN: this is Goto *Declaration*, not Goto Definition. In
					-- C, for example, this takes you to the header.
					map("<leader>flgD", vim.lsp.buf.declaration, "[l]sp [g]oto [D]eclaration")

					-- Resolves a difference between Neovim 0.10 and 0.11+.
					---@param client vim.lsp.Client
					---@param method string
					---@param bufnr? integer some servers support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							-- NOTE: colon call. On 0.11+ this is a real method
							-- and needs `self`.
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- Highlight other references to the symbol under the cursor
					-- when the cursor rests there for a moment, and clear the
					-- highlights once it moves. See `:help CursorHold`.
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup = vim.api.nvim_create_augroup(
							"kickstart-lsp-highlight",
							{ clear = false }
						)

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup(
								"kickstart-lsp-detach",
								{ clear = true }
							),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({
									group = "kickstart-lsp-highlight",
									buffer = event2.buf,
								})
							end,
						})
					end

					-- Toggle inlay hints, if the attached server provides them.
					-- They render extra text inside your code, which is useful
					-- but can be visually noisy, so it is opt-in per session.
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_inlayHint,
							event.buf
						)
					then
						map("<leader>TIH", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
							)
						end, "[<leader>]:operator [T]oggle [I]nline [H]ints")
					end
				end,
			})

			-- ================================================================
			-- Diagnostics presentation
			-- ================================================================
			-- See `:help vim.diagnostic.Opts`
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				-- NOTE: single-width Nerd Font glyphs. Emoji are double-width
				-- and push the sign column out of alignment.
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						return diagnostic.message
					end,
				},
			})

			-- ================================================================
			-- Capabilities shared by every server
			-- ================================================================
			-- `vim.lsp.config('*', ...)` is merged into every server config, so
			-- the nvim-cmp capabilities only need declaring once. This is the
			-- replacement for the old per-handler `tbl_deep_extend` dance.
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			-- ================================================================
			-- Per-server overrides
			-- ================================================================
			-- Each key is a server name as known to nvim-lspconfig (see its
			-- `lsp/` directory for the full list). The table is merged *on top
			-- of* lspconfig's shipped default for that server, so you only need
			-- to state what differs.
			--
			-- Available keys include:
			--   cmd       (table) override the command used to start the server
			--   filetypes (table) override which filetypes it attaches to
			--   settings  (table) server-specific settings; for lua_ls see
			--                     https://luals.github.io/wiki/settings/
			local servers = {
				-- [ LUA ] -----------------------------------------------------
				-- Worth having purely for editing this config.
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							-- lazydev.nvim (lua/plugins/lazydev.lua) supplies the
							-- Neovim runtime types on demand, so no
							-- hand-maintained workspace.library is needed.
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},

				-- [ GO ] ------------------------------------------------------
				gopls = {
					settings = {
						gopls = {
							-- Report shadowed variables, useless assignments,
							-- unused params -- the analysers that catch real
							-- bugs rather than style nits.
							analyses = {
								unusedparams = true,
								shadow = true,
								useany = true,
								nilness = true,
								unusedwrite = true,
							},
							staticcheck = true,
							gofumpt = true,
							-- Complete unimported packages and add the import
							-- for you when you accept the completion.
							completeUnimported = true,
							usePlaceholders = true,
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},

				-- [ TYPESCRIPT / JAVASCRIPT ] ---------------------------------
				-- vtsls wraps the official TypeScript language service and
				-- exposes the extras the plain `ts_ls` config does not:
				-- organise-imports, "go to source definition", better inlay
				-- hints, and saner monorepo handling.
				--
				-- Works for Node, Bun and Deno-less TS projects alike, since it
				-- is driven by tsconfig.json rather than by the runtime.
				vtsls = {
					settings = {
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = { completeFunctionCalls = true },
							inlayHints = {
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								variableTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								enumMemberValues = { enabled = true },
							},
						},
						javascript = {
							updateImportsOnFileMove = { enabled = "always" },
							inlayHints = {
								parameterNames = { enabled = "literals" },
								variableTypes = { enabled = true },
							},
						},
						vtsls = {
							-- Surface the TS server's own errors instead of
							-- swallowing them.
							experimental = { completion = { enableServerSideFuzzyMatch = true } },
						},
					},
				},

				-- [ WEB / CONFIG FORMATS ] ------------------------------------
				jsonls = {
					settings = {
						json = {
							-- Schemas for package.json, tsconfig.json, .eslintrc,
							-- and several hundred others.
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					settings = {
						yaml = {
							-- schemastore also covers YAML: GitHub Actions
							-- workflows, docker-compose, k8s manifests.
							schemaStore = {
								-- Disable the built-in store; we supply it.
								enable = false,
								url = "",
							},
							schemas = require("schemastore").yaml.schemas(),
							keyOrdering = false, -- don't demand alphabetical keys
						},
					},
				},
				html = {},
				cssls = {},
				bashls = {},
				taplo = {}, -- TOML: Cargo.toml, pyproject.toml, etc.

				-- [ AST-GREP ] ------------------------------------------------
				-- NOTE: ast_grep only reports diagnostics for rules you write
				-- yourself in an `sgconfig.yml` at the project root. Without
				-- that file it attaches and does nothing. It is NOT a
				-- replacement for a real language server.
				ast_grep = {
					filetypes = { "dart", "typescript", "javascript", "rust", "lua" },
				},
			}

			-- Register every override. This does not start anything; it only
			-- records the config for when the server is enabled.
			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end

			-- ================================================================
			-- Installing the servers and tools
			-- ================================================================
			-- To inspect or manually manage installs, run `:Mason`. Press `g?`
			-- inside that window for help.
			--
			-- mason.nvim itself was set up earlier -- see the `dependencies`
			-- table on nvim-lspconfig above.

			-- Servers Mason should keep installed.
			local ensure_installed = vim.tbl_keys(servers)

			-- Formatters, linters and debug adapters. These are not language
			-- servers, so they are listed separately. They are consumed by
			-- conform.nvim (lua/plugins/conform.lua) and nvim-dap
			-- (lua/plugins/dap.lua).
			--
			-- NOTE: `rustfmt` and `dart format` are deliberately absent -- they
			-- ship with the Rust and Dart toolchains, so Mason would only
			-- duplicate them.
			vim.list_extend(ensure_installed, {
				"stylua", -- Lua formatter
				"prettierd", -- js/ts/json/yaml/html/css/markdown formatter
				"shfmt", -- shell formatter
				"js-debug-adapter", -- Node/browser DAP adapter
				"codelldb", -- native DAP adapter (Rust)
			})

			-- Mason builds these with `go install`, which needs a Go toolchain.
			-- Without one the install fails on every startup, so only ask for
			-- them when Go is actually present.
			if has_go then
				vim.list_extend(ensure_installed, {
					"gofumpt", -- stricter gofmt
					"goimports", -- manages the import block
					"delve", -- Go debugger, used by nvim-dap-go
				})
			else
				-- gopls is a pure-Go binary too; drop it rather than fail.
				ensure_installed = vim.tbl_filter(function(tool)
					return tool ~= "gopls"
				end, ensure_installed)
			end

			require("mason-tool-installer").setup({
				ensure_installed = ensure_installed,
				-- Don't block startup on network calls.
				run_on_start = true,
				start_delay = 3000,
			})

			-- mason-lspconfig 2.x automatically enables every server Mason has
			-- installed, via `vim.lsp.enable()`. We only need to tell it which
			-- ones to leave alone.
			require("mason-lspconfig").setup({
				-- Installs are driven by mason-tool-installer above, so this
				-- stays empty on purpose.
				ensure_installed = {},
				automatic_enable = {
					exclude = {
						-- Owned by rustaceanvim (lua/plugins/rust.lua).
						"rust_analyzer",
						-- Owned by flutter-tools.nvim (lua/plugins/flutter.lua).
						"dartls",
					},
				},
			})
		end,
	},
}
