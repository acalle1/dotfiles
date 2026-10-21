vim.g.mapleader = " "

local o = vim.o
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 4
o.undofile = true
o.clipboard = "unnamedplus"
o.termguicolors = true
-- Completion menu: never preselect or insert an item; pick with <C-n>/<C-p>, accept with <C-y>.
o.completeopt = "menu,menuone,noselect,popup"
-- Complete while typing: buffer words plus LSP (via omnifunc, which vim.lsp.completion sets).
o.autocomplete = true
o.complete = ".,o"

vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/windwp/nvim-autopairs",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})
vim.cmd.colorscheme("tokyonight")

-- Treesitter: parsers are compiled locally (needs the tree-sitter CLI and gcc).
require("nvim-treesitter").install({ "rust", "toml" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust", "toml" },
  callback = function() vim.treesitter.start() end,
})

-- Auto-close (), [], {}, quotes.
require("nvim-autopairs").setup({})

-- Fuzzy finder (uses fzf, fd and ripgrep from home.nix).
local fzf = require("fzf-lua")
fzf.setup({})
fzf.register_ui_select()
vim.keymap.set("n", "<leader>ff", fzf.files)
vim.keymap.set("n", "<leader>fg", fzf.live_grep)
vim.keymap.set("n", "<leader>fb", fzf.buffers)
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols)
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document)

-- Rust: rust-analyzer comes from rustup (`rustup component add rust-analyzer`).
-- Native LSP only, no plugin needed.
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = { check = { command = "clippy" } },
  },
})
vim.lsp.enable("rust_analyzer")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      -- Own trigger instead of autotrigger so "4." (a float literal) stays quiet.
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
      vim.api.nvim_create_autocmd("InsertCharPre", {
        buffer = ev.buf,
        callback = function()
          local c = vim.v.char
          local prev = vim.api.nvim_get_current_line():sub(vim.fn.col(".") - 1, vim.fn.col(".") - 1)
          if (c == "." and not prev:match("%d")) or (c == ":" and prev == ":") then
            vim.schedule(vim.lsp.completion.get)
          end
        end,
      })
    end
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
    if client and client:supports_method("textDocument/signatureHelp") then
      -- Show the signature with the active parameter highlighted after "(" and ",".
      vim.api.nvim_create_autocmd("InsertCharPre", {
        buffer = ev.buf,
        callback = function()
          if vim.v.char == "(" or vim.v.char == "," then
            vim.schedule(vim.lsp.buf.signature_help)
          end
        end,
      })
    end
    local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = ev.buf }) end
    map("<leader>=", function() vim.lsp.buf.format() end)
    map("gr", fzf.lsp_references)
    map("<leader>e", vim.diagnostic.open_float)
  end,
})

vim.diagnostic.config({ virtual_text = false })

-- Format Rust on save via rust-analyzer (rustfmt).
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function() vim.lsp.buf.format({ async = false }) end,
})
