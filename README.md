# Neovim Setup and Configuration

A hand-rolled Neovim config built on [lazy.nvim](https://github.com/folke/lazy.nvim).

> **Note on naming:** this is *not* [LazyVim](https://www.lazyvim.org/), which is a
> pre-built distribution. This config uses **lazy.nvim**, the plugin *manager*,
> with plugin specs written by hand in `lua/plugins/`. Nothing is inherited from
> a distro, so there are no hidden defaults to fight — everything active is in
> this repository.

---

## Requirements

**Neovim 0.11 or newer** is mandatory. The LSP layer uses `vim.lsp.config()` /
`vim.lsp.enable()`, which do not exist before 0.11, and the config refuses to
load its LSP setup on older versions rather than half-working. 0.12+ is what this
is developed against.

```bash
nvim --version | head -1
```

### Core dependencies (brew)

```bash
# Nerd Font — required. The diagnostic, git, DAP and test signs are all Nerd
# Font glyphs; without it you get replacement boxes everywhere.
brew install --cask font-jetbrains-mono-nerd-font

# Fuzzy finding and grep. fzf-lua drives file/symbol/grep pickers off these.
brew install fzf ripgrep

# Treesitter CLI, needed to compile some grammars from source.
brew install tree-sitter

# Nice tree view of folders and files.
brew install tree
```

Set your terminal's font to **JetBrainsMono Nerd Font** after installing, or none
of the icons will render.

### Optional language toolchains

Mason installs language servers, formatters and debug adapters automatically, but
some of them are built *by* a toolchain rather than downloaded. The config checks
for each and silently skips what is missing, so nothing here is required to boot.

| Toolchain | Install | Unlocks |
|---|---|---|
| Node.js | `brew install node` | `vtsls`, `prettierd`, `js-debug-adapter`, `jsonls`, `yamlls`, `bashls` — most of Mason |
| Go | `brew install go` | `gopls`, `gofumpt`, `goimports`, `delve` (debugging), `neotest-golang` |
| Rust | [rustup](https://rustup.rs) + `rustup component add rust-analyzer clippy` | `rustaceanvim`, `rustfmt`, `clippy` |
| Flutter / Dart | [flutter.dev](https://docs.flutter.dev/get-started/install) | `flutter-tools.nvim`, `dartls`, `neotest-dart` |
| Bun | `brew install oven-sh/bun/bun` | detected by `package-info.nvim` for dependency actions |
| lazygit | `brew install lazygit` | `<leader>gt` full-screen git TUI |
| fd | `brew install fd` | faster file discovery for some fzf-lua pickers |

Mason builds the Go tools with `go install`. **Without a Go toolchain, the Go
tools and `gopls` are dropped from the install list on purpose** — otherwise they
would fail on every startup. Install Go first, then run `:MasonToolsUpdate`.

---

## Installation

Neovim reads its config from `~/.config/nvim`. Pick one of these.

**Option A — symlink (recommended).** Keeps the repo wherever you clone it, so
`git pull` in the repo updates your config directly:

```bash
git clone https://github.com/MR0100/nvim-setup.git ~/Projects/nvim-setup
ln -s ~/Projects/nvim-setup ~/.config/nvim
```

**Option B — clone straight into place:**

```bash
git clone https://github.com/MR0100/nvim-setup.git ~/.config/nvim
```

If you already have a config there, move it aside first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

### First launch

```bash
nvim
```

Expect this sequence, and note that it is not instant:

1. lazy.nvim bootstraps itself, then clones every plugin. A progress window shows
   the work.
2. Treesitter compiles its grammars (`:TSUpdate` runs via the `build` step). This
   is the slowest part.
3. **Open a real file** — e.g. `nvim init.lua`, not the dashboard. The LSP stack
   loads on `BufReadPre`, and Mason's installs are kicked off from there, three
   seconds after it loads. Sitting on the dashboard installs nothing.
4. Wait for the Mason messages to stop. Downloading a dozen servers takes a few
   minutes on a first run; `:Mason` shows live status.
5. **Restart Neovim.** `mason-lspconfig` enables the servers that were already
   installed when it started, so anything fetched during the *first* run only
   attaches on the second.

Then verify:

```vim
:checkhealth
:Lazy       " plugin status
:Mason      " installed tools; g? for help
:LspInfo    " what attached to this buffer
```

### Trying it without touching your existing config

`NVIM_APPNAME` gives Neovim a separate config *and* data directory, so you can
test this repo with zero risk to a setup you already rely on:

```bash
git clone https://github.com/MR0100/nvim-setup.git ~/.config/nvimtest
NVIM_APPNAME=nvimtest nvim
```

Remove `~/.config/nvimtest`, `~/.local/share/nvimtest` and
`~/.local/state/nvimtest` to undo it completely.

---

## Layout

```
init.lua                    entry point; requires config.lazy and nothing else
lua/config/
  lazy.lua                  bootstraps lazy.nvim, sets leader, imports plugins
  options.lua               vim.opt settings (indent, folds, clipboard, UI)
  keymaps.lua               global keymaps only
  autocmds.lua              yank highlight, cursor restore, trim whitespace, …
lua/plugins/                one file per plugin or coherent group
```

`lua/config/lazy.lua` imports `lua/plugins/` wholesale, so **a new file in that
directory is picked up automatically** — no registration step. A file must return
a lazy.nvim spec (a table, or a list of tables).

Leader is `<Space>`; local leader is `\`.

### Plugins

**Editing & motion** — `mini.pairs` (auto-close), `mini.surround` (`sa`/`sd`/`sr`),
`nvim-treesitter` + textobjects (structural select/move/swap), `vim-sleuth`
(detect indent per file), `conform.nvim` (format on save).

**Navigation** — `fzf-lua` (files, grep, symbols, help), `oil.nvim` (edit the
filesystem like a buffer), `project.nvim` (cd to project root).

**LSP & completion** — `nvim-lspconfig` + `mason.nvim`, `nvim-cmp` with LuaSnip
and `friendly-snippets`, `lazydev.nvim` (Neovim API types when editing this
config), `fidget.nvim` (progress), `schemastore.nvim` (JSON/YAML schemas).

**Languages** — `rustaceanvim` (Rust: runnables, macro expansion, DAP),
`flutter-tools.nvim` (Flutter: hot reload, device picker, outline),
`package-info.nvim` (dependency versions inside `package.json`).

**Debugging & tests** — `nvim-dap` + `nvim-dap-ui` + virtual text, `nvim-dap-go`,
`neotest` with Go / Vitest / Jest / Dart / Rust adapters.

**Git** — `gitsigns.nvim` (in-buffer hunks and blame), `neogit` (full status
buffer, commit, push, rebase), `diffview.nvim` (side-by-side diffs, merge
conflicts), `vim-fugitive` (`:Git blame`).

**UI** — `tokyonight.nvim` (moon), `mini.statusline`, `bufferline.nvim`,
`noice.nvim` + `nvim-notify`, `indent-blankline.nvim`, `mini.starter` (dashboard),
`dressing.nvim` (better prompts), `showkeys` (on-screen keys, for screencasts),
`which-key.nvim`.

**Workflow** — `toggleterm.nvim` (`<C-\>`), `persistence.nvim` (sessions).

---

## Keymaps

Press `<Space>` and wait — which-key lists everything live. This is a reference
for the parts worth memorising.

### Prefix groups

| Prefix | Meaning |
|---|---|
| `<leader>f` | find (fzf-lua); `<leader>fl` is the LSP subgroup |
| `<leader>g` | git |
| `<leader>d` | diagnostics |
| `<leader>b` | buffer |
| `<leader>c` | code |
| `<leader>s` | swap (treesitter) |
| `<leader>t` | toggle / test; `<leader>tt` is terminal |
| `<leader>x` | debug (DAP) |
| `<leader>q` | session |
| `<leader>m` | messages (noice) |
| `<leader>n` | npm / bun dependencies |
| `<leader>r` | rust (Rust buffers only) |
| `<leader>F` | flutter (Dart buffers only) |

> Debugging is on `<leader>x` ("e**x**ecute"), not the conventional `<leader>d` —
> that prefix was already diagnostics here, and `<leader>D` is
> delete-without-yanking.

### Core

| Key | Action |
|---|---|
| `<leader>-` | open parent directory in oil (float) |
| `<C-s>` | save (works in insert, visual, normal) |
| `<Esc>` | clear search highlight |
| `<C-h/j/k/l>` | move between splits |
| `<leader>\|` / `<leader>_` | split vertically / horizontally |
| `<C-Up/Down/Left/Right>` | resize split |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `<leader>bd` / `<leader>bb` | delete buffer / back to previous |
| `n` / `N`, `<C-d>` / `<C-u>` | search and scroll, cursor kept centred |
| `J` / `K` (visual) | move selection down / up, re-indenting |
| `<leader>p` (visual) | paste without clobbering the register |

### Find (fzf-lua)

| Key | Action |
|---|---|
| `<leader>fff` | files in project |
| `<leader>ffg` | live grep |
| `<leader>fcw` | grep word under cursor |
| `<leader>fof` | recent files |
| `<leader>ffr` | resume last picker |
| `<leader>fcfg` | files in the Neovim config dir |
| `<leader>ffh` / `<leader>ffk` | help tags / keymaps |
| `<leader>fdg` | document diagnostics |

### LSP

| Key | Action |
|---|---|
| `<leader>flgd` / `<leader>flgr` | definitions / references |
| `<leader>flgI` / `<leader>flgD` | implementation / declaration |
| `<leader>flds` / `<leader>fllws` | document / workspace symbols |
| `<leader>flrn` | rename symbol |
| `<leader>flca` | code action |
| `<leader>TIH` | toggle inlay hints |
| `]d` / `[d` | next / previous diagnostic |
| `<leader>df` / `<leader>dq` | diagnostic float / send to loclist |
| `<leader>cf` | format buffer or selection |
| `<leader>tf` | toggle format-on-save |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | neogit status — the main entry point |
| `<leader>gc` / `<leader>gl` | commit / log |
| `<leader>gP` / `<leader>gF` | push / pull |
| `<leader>gv` | diffview of the working tree |
| `<leader>gh` / `<leader>gH` | file history / branch history |
| `<leader>gt` | lazygit (needs `lazygit` installed) |
| `]c` / `[c` | next / previous hunk |
| `<leader>gs` / `<leader>gr` | stage / reset hunk (works on a visual range) |
| `<leader>gp` / `<leader>gb` | preview hunk / toggle line blame |
| `<leader>gd` / `<leader>gD` | diff against index / last commit |

### Debugging

| Key | Action |
|---|---|
| `<F5>` / `<S-F5>` | continue or start / terminate |
| `<F9>` | toggle breakpoint |
| `<F10>` / `<F11>` / `<F12>` | step over / into / out |
| `<leader>xB` / `<leader>xl` | conditional breakpoint / log point |
| `<leader>xu` / `<leader>xe` | toggle DAP UI / eval expression |
| `<leader>xj` | run to cursor |
| `<leader>xR` | toggle REPL |

### Tests

| Key | Action |
|---|---|
| `<leader>tn` | run nearest test |
| `<leader>tF` / `<leader>ta` | run file / whole suite |
| `<leader>tl` | re-run last |
| `<leader>td` | debug nearest test |
| `<leader>ts` / `<leader>to` | summary panel / output |

### Language-specific

Rust (`<leader>r`): `rr` runnables, `rt` testables, `rd` debuggables, `rm` expand
macro, `re` explain error, `rc` open `Cargo.toml`. `K` gives hover *actions*.

Flutter (`<leader>F`): `Fr` run, `Fl` hot reload, `FR` hot restart, `Fd` pick
device, `Fe` pick emulator, `Fo` widget outline, `Fp` pub get.

### Sessions

`<leader>qs` restore this directory's session, `<leader>ql` restore the last one,
`<leader>qS` pick from a list, `<leader>qd` don't save on exit. Sessions are saved
automatically on exit and are per git branch.

---

## Language support

| Language | Server | Formatter | Debug | Tests |
|---|---|---|---|---|
| Lua | `lua_ls` + lazydev | `stylua` | — | — |
| Go | `gopls` | `gofumpt` + `goimports` | delve | neotest-golang |
| TypeScript / JS | `vtsls` | `prettierd` | js-debug | Vitest, Jest |
| Rust | `rust_analyzer` (rustaceanvim) | `rustfmt` | codelldb | rustaceanvim |
| Dart / Flutter | `dartls` (flutter-tools) | `dart format` | flutter-tools | neotest-dart |
| JSON / YAML | `jsonls` / `yamlls` + schemastore | `prettierd` | — | — |
| HTML / CSS | `html` / `cssls` | `prettierd` | — | — |
| Shell | `bashls` | `shfmt` | — | — |
| TOML | `taplo` | `taplo` | — | — |

### Bun

Bun is supported for **running and dependency management**, not step-debugging.
`package-info.nvim` detects `bun.lockb` / `bun.lock` and uses Bun for install and
upgrade actions, and `bun dev` / `bun test --watch` work fine in a toggleterm
split (`<C-\>`).

Step-debugging does not work: Bun's inspector speaks the WebKit Inspector
Protocol, while `js-debug` — and every maintained Neovim DAP adapter for
JavaScript — targets V8 / Chrome DevTools. There is no bridge between them today.
Use `bun --inspect` with Bun's own browser debugger, or run the code under Node
when you need breakpoints. Bun projects that use **Vitest** as their test runner
do work with neotest.

### Servers owned by a plugin, not by Mason

`rust_analyzer` and `dartls` are started by `rustaceanvim` and
`flutter-tools.nvim` respectively, and are explicitly excluded from
`mason-lspconfig`'s automatic enabling in `lua/plugins/lsp.lua`. Enabling them in
both places starts two servers against the same project. If you add a plugin that
owns a server, add it to that exclude list.

---

## How the LSP layer works

Worth understanding, because it changed and most tutorials online are still
showing the old way.

Neovim 0.11 added `vim.lsp.config()` and `vim.lsp.enable()`. `nvim-lspconfig` no
longer sets servers up — it ships ~400 default config files in its own `lsp/`
directory, which Neovim discovers because the plugin is on the runtimepath. This
config only **overrides** the parts it cares about:

```lua
vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })
```

`vim.lsp.config("*", …)` sets defaults for every server, which is where the
nvim-cmp capabilities are declared once instead of per-server.

Two APIs this config used to depend on are gone:

- `require("lspconfig")[server].setup({})` — deprecated, prints a loud traceback,
  and is scheduled for removal in nvim-lspconfig v3.0.0.
- `mason-lspconfig`'s `handlers = {}` — **removed in mason-lspconfig 2.x**. Its
  settings schema is now only `ensure_installed` and `automatic_enable`. Anything
  passed as `handlers` is silently ignored.

That second one mattered: while this config was passing `handlers`, none of its
server settings were being applied and no server received the completion
capabilities. Servers are now enabled by `automatic_enable` and configured by
`vim.lsp.config`.

---

## Adding things

**A plugin.** Create `lua/plugins/<name>.lua` returning a spec. It is imported
automatically:

```lua
return {
  "owner/repo",
  event = "VeryLazy",   -- or ft / cmd / keys, so it loads lazily
  opts = {},            -- equivalent to require("repo").setup(opts)
}
```

**A language server.** Add it to the `servers` table in `lua/plugins/lsp.lua`.
The key is the name nvim-lspconfig knows (see its `lsp/` directory); an empty
table `{}` accepts every default. It is added to Mason's install list
automatically.

**A formatter.** Add it under `formatters_by_ft` in `lua/plugins/conform.lua`, and
to the `vim.list_extend(ensure_installed, …)` list in `lua/plugins/lsp.lua` so
Mason installs the binary.

**A treesitter grammar.** Add it to `ensure_installed` in
`lua/plugins/nvim_treesitter.lua`.

---

## Troubleshooting

**Icons show as boxes or `?`.** Terminal font is not a Nerd Font. Install the cask
above and select *JetBrainsMono Nerd Font* in your terminal profile.

**A language server never attaches.** Check `:LspInfo` in that buffer, then
`:Mason` to confirm the server is installed. Remember servers installed during a
session are only enabled after a restart. Also confirm the filetype is what you
expect — `:set filetype?`. Filetype names, not extensions, are what servers match
on (`typescript`, not `ts`).

**Mason install fails for a Go tool.** Those are built with `go install` and need
a Go toolchain on PATH. Install Go, then `:MasonToolsUpdate`.

**Formatting does nothing.** `:ConformInfo` shows which formatter conform picked
for the buffer and whether the binary was found. `<leader>tf` may also have
toggled format-on-save off for the session.

**Treesitter errors after an update.** `:TSUpdate`, then restart. If a grammar is
still broken, `:TSUninstall <lang>` and reinstall it.

**Everything is broken after a plugin update.** `lazy-lock.json` pins every
plugin to a known-good commit and is committed to this repo. `:Lazy restore` puts
every plugin back to those pinned versions. Commit the lockfile whenever you
update deliberately (`:Lazy sync`), and you always have a way back.

**Duplicate LSP progress messages.** noice can render progress too, and it is
disabled here so `fidget.nvim` owns it. If you remove fidget, re-enable
`lsp.progress` in `lua/plugins/noice.lua`.

**`:checkhealth vim.deprecated` reports `vim.lsp.buf_get_clients()`.** This comes
from `project.nvim`, which is no longer maintained upstream. It is harmless today.
See the comment at the top of `lua/plugins/nvim_project.lua` for the three ways
out when it eventually breaks; the one-line fix is to drop `"lsp"` from
`detection_methods`.

---

## Related

`tmux_readme.md` in this repo covers the tmux setup and cheatsheet that this
config is used alongside.
