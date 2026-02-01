" =========================
" Basic / Compatibility
" =========================
set nocompatible
scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,latin1
set termencoding=utf-8

" 予期しない挙動を減らす
set backspace=indent,eol,start
set hidden
set autoread
set confirm
set history=1000

" =========================
" UI / Display
" =========================
syntax on
filetype plugin indent on

set number
set relativenumber
set ruler
set showcmd
set laststatus=2
set cmdheight=1
set showmode
set cursorline
set nowrap

" 行末や空白の可視化（必要なら ON/OFF）
set list
set listchars=tab:»·,trail:·,extends:→,precedes:←,nbsp:␣

" 80桁目のガイド（規約がある場合に有効化）
" set colorcolumn=81

" 見やすいスクロール
set scrolloff=5
set sidescrolloff=5

" =========================
" Search
" =========================
set incsearch
set hlsearch
set ignorecase
set smartcase
set magic

" =========================
" Indent / Tabs
" =========================
set autoindent
set smartindent

" デフォルトは「スペース展開 + 4幅」
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" --- タブ主体にしたい場合（規約次第で切替） ---
" set noexpandtab
" set tabstop=4
" set shiftwidth=4
" set softtabstop=0

" Cのインデントをより制御したい場合（好みで）
" set cindent
" set cinoptions=:0,l1,t0,g0,(0

" =========================
" Editing Convenience
" =========================
set virtualedit=
set whichwrap+=<,>,h,l
set matchtime=2
set wildmenu
set wildmode=longest:full,full
set completeopt=menuone,noselect

" ヤンク/削除の挙動（レジスタを汚しにくくする）
set clipboard=
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

" =========================
" Files / Backup / Undo
" =========================
set noswapfile
set nobackup
set nowritebackup

" 永続 undo（ディレクトリ自動作成）
if has('persistent_undo')
  set undofile
  if has('nvim')
    let s:undo_dir = stdpath('data') . '/undo'
    let s:swap_dir = stdpath('data') . '/swap'
    let s:backup_dir = stdpath('data') . '/backup'
  else
    let s:undo_dir = expand('~/.vim/undo')
    let s:swap_dir = expand('~/.vim/swap')
    let s:backup_dir = expand('~/.vim/backup')
  endif

  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  if !isdirectory(s:swap_dir)
    call mkdir(s:swap_dir, 'p', 0700)
  endif
  if !isdirectory(s:backup_dir)
    call mkdir(s:backup_dir, 'p', 0700)
  endif

  execute 'set undodir=' . fnameescape(s:undo_dir)
  execute 'set directory=' . fnameescape(s:swap_dir)
  execute 'set backupdir=' . fnameescape(s:backup_dir)
endif

" =========================
" Performance-ish knobs
" =========================
set updatetime=300
set timeout
set timeoutlen=400
set ttimeout
set ttimeoutlen=50
set lazyredraw
set synmaxcol=240

" =========================
" Quickfix / Make
" =========================
set errorformat^=%f:%l:%c:\ %t%*[^:]:\ %m
set errorformat^=%f:%l:\ %t%*[^:]:\ %m
set makeef=

" =========================
" netrw (built-in file explorer)
" =========================
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" =========================
" Leader / Keymaps
" =========================
let mapleader = " "

" 保存/終了
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>q :q<CR>
nnoremap <silent> <leader>Q :qa!<CR>

" 検索ハイライト消去
nnoremap <silent> <leader>/ :nohlsearch<CR>

" 分割移動
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

" 分割作成
nnoremap <silent> <leader>sv :vsplit<CR>
nnoremap <silent> <leader>ss :split<CR>

" netrw 起動
nnoremap <silent> <leader>e :Ex<CR>

" 行の上下移動（ビジュアルで選択して動かす）
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv

" =========================
" Filetype tweaks
" =========================
augroup MyFiletypes
  autocmd!
  " C: 末尾空白を見つけやすく、コメントを扱いやすく
  autocmd FileType c setlocal formatoptions-=cro
  autocmd FileType c setlocal commentstring=//\ %s
  autocmd FileType c setlocal makeprg=make

  " Makefile はタブが必要になりがちなので expandtab を切る（必要なら）
  autocmd FileType make setlocal noexpandtab
augroup END

" =========================
" Optional: trailing spaces trim on save (慎重に)
" =========================
" 空白が意味を持つファイルでは事故るので、Cなどに限定推奨
" augroup TrimSpaces
"   autocmd!
"   autocmd BufWritePre *.c,*.h %s/\s\+$//e
" augroup END

" =========================
" Optional: quick build current C file without Makefile
" =========================
" 既存プロジェクトと衝突し得るためデフォルトはOFF
" function! s:BuildSingleC()
"   if &filetype !=# 'c'
"     echo "not a C file"
"     return
"   endif
"   let l:src = expand('%:p')
"   let l:out = expand('%:p:r')
"   " コンパイラやフラグは環境依存: 必要なら調整
"   let &l:makeprg = 'cc -O2 -g -Wall -Wextra -Werror ' . shellescape(l:src) . ' -o ' . shellescape(l:out)
"   make
"   copen
" endfunction
" nnoremap <silent> <F5> :call <SID>BuildSingleC()<CR>


