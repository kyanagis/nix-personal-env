filetype plugin indent on
syntax on

let mapleader = " "

set number
set signcolumn=yes
set nowrap
set updatetime=250
set scrolloff=4
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

let g:gruvbox_transparent_bg = 1
colorscheme gruvbox

function! s:transparent_background() abort
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
  highlight NormalFloat guibg=NONE ctermbg=NONE
  highlight FloatBorder guibg=NONE ctermbg=NONE
  highlight Pmenu guibg=NONE ctermbg=NONE
  highlight PmenuSel gui=reverse cterm=reverse
endfunction

call s:transparent_background()

augroup user_filetypes
  autocmd!
  autocmd FileType make setlocal noexpandtab
augroup END

augroup user_colors
  autocmd!
  autocmd ColorScheme * call s:transparent_background()
augroup END

nnoremap <silent> <leader>w <Cmd>write<CR>
nnoremap <silent> <leader>q <Cmd>quit<CR>
nnoremap <silent> <leader>h <Cmd>nohlsearch<CR>
nnoremap <silent> [d <Cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d <Cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> <leader>e <Cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <silent> <leader>f <Cmd>lua vim.lsp.buf.format({ async = true })<CR>

lua << EOF
vim.diagnostic.config({
  virtual_text = false,
  float = { border = "rounded" },
})

require("nvim-autopairs").setup()

local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

local function confirm_rank(index)
  if not cmp.visible() then
    return false
  end

  local entry = cmp.get_entries()[index]
  if entry == nil then
    return false
  end

  cmp.core:confirm(entry, {
    behavior = cmp.ConfirmBehavior.Insert,
  }, function()
    cmp.complete({ reason = cmp.ContextReason.TriggerOnly })
  end)

  return true
end

cmp.setup({
  performance = {
    max_view_entries = 4,
  },
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
        return
      end
      fallback()
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
  }),
})

for index = 1, 4 do
  local rank = index

  vim.keymap.set("i", string.format("<C-g>%d", rank), function()
    if confirm_rank(rank) then
      return
    end
    vim.api.nvim_feedkeys(tostring(rank), "n", false)
  end, { silent = true })

  vim.keymap.set("i", string.format("<M-%d>", rank), function()
    if confirm_rank(rank) then
      return
    end
    vim.api.nvim_feedkeys(tostring(rank), "n", false)
  end, { silent = true })
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

  vim.lsp.config(server, opts)
  vim.lsp.enable(server)
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
  setup("ts_ls")
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
