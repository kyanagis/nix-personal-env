set encoding=utf-8
scriptencoding utf-8
filetype plugin indent on
syntax on

let mapleader = " "
let maplocalleader = " "

set number
set relativenumber
set signcolumn=yes
set cursorline
set nowrap
set hidden
set updatetime=250
set timeoutlen=400
set scrolloff=4
set sidescrolloff=8
set splitbelow
set splitright
set ignorecase
set smartcase
set incsearch
set hlsearch
set clipboard=unnamedplus
set completeopt=menu,menuone,noselect
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent
set undofile
set mouse=
set grepprg=rg\ --vimgrep\ --smart-case

if has('termguicolors')
  set termguicolors
endif

colorscheme gruvbox

augroup user_filetypes
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd FileType c,cpp,go,rust setlocal tabstop=4 shiftwidth=4 softtabstop=4
augroup END

nnoremap <silent> <leader>w <Cmd>write<CR>
nnoremap <silent> <leader>q <Cmd>quit<CR>
nnoremap <silent> <leader>h <Cmd>nohlsearch<CR>
nnoremap <silent> - <Cmd>Ex<CR>
nnoremap <silent> <leader>ff <Cmd>Telescope find_files<CR>
nnoremap <silent> <leader>fg <Cmd>Telescope live_grep<CR>
nnoremap <silent> <leader>fb <Cmd>Telescope buffers<CR>
nnoremap <silent> <leader>fh <Cmd>Telescope help_tags<CR>
nnoremap <silent> [d <Cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d <Cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> <leader>e <Cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <silent> <leader>f <Cmd>lua vim.lsp.buf.format({ async = true })<CR>

lua << EOF
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = false,
  float = { border = "rounded" },
})

require("Comment").setup()
require("gitsigns").setup()
require("nvim-autopairs").setup()
require("luasnip.loaders.from_vscode").lazy_load()

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
})

local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local has_native_lsp = vim.lsp.config ~= nil and vim.lsp.enable ~= nil
local legacy_lspconfig = nil

if not has_native_lsp then
  local ok, mod = pcall(require, "lspconfig")
  if ok then
    legacy_lspconfig = mod
  end
end

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

local function setup(server, opts)
  opts = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
    on_attach = on_attach,
  }, opts or {})

  if has_native_lsp then
    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
    return
  end

  if legacy_lspconfig ~= nil and legacy_lspconfig[server] ~= nil then
    legacy_lspconfig[server].setup(opts)
  end
end

if vim.fn.executable("nil") == 1 then
  setup("nil_ls")
end

if vim.fn.executable("lua-language-server") == 1 then
  setup("lua_ls", {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })
end

if vim.fn.executable("bash-language-server") == 1 then
  setup("bashls")
end

if vim.fn.executable("pyright-langserver") == 1 then
  setup("pyright")
end

if vim.fn.executable("typescript-language-server") == 1 then
  if has_native_lsp then
    setup("ts_ls")
  elseif legacy_lspconfig ~= nil and legacy_lspconfig.ts_ls ~= nil then
    setup("ts_ls")
  elseif legacy_lspconfig ~= nil and legacy_lspconfig.tsserver ~= nil then
    setup("tsserver")
  end
end

if vim.fn.executable("vscode-html-language-server") == 1 then
  setup("html")
end

if vim.fn.executable("vscode-css-language-server") == 1 then
  setup("cssls")
end

if vim.fn.executable("vscode-json-language-server") == 1 then
  setup("jsonls")
end

if vim.fn.executable("clangd") == 1 then
  setup("clangd")
end
EOF
