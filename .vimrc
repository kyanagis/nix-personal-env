set nocompatible
set encoding=utf-8
scriptencoding utf-8
filetype plugin indent on
syntax on

" 表示まわり
set number                 " 絶対行番号のみ
set norelativenumber       " 相対行番号OFF（数字が動かない）
set numberwidth=5          " 行番号桁を固定（横ズレ防止）
set signcolumn=yes         " サイン欄を常に表示（横ズレ防止）
set nowrap
set noshowmode
set noruler                " 左下の座標表示OFF
set cursorline!            " デフォOFF（白い膜を出さない）
set colorcolumn=           " デフォOFF（80桁線なし）
set laststatus=2
set hidden
set updatetime=300
set backspace=indent,eol,start
set mouse=
let mapleader = " "

" 42想定：TABインデント（必要なら expandtab に変えてOK）
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set cindent
set cinoptions=:0,l1,g0,(0,W4

" 検索
set ignorecase
set smartcase
set incsearch
set hlsearch

" 端末色
if has('termguicolors')
  set termguicolors
else
  set t_Co=256
endif
set background=dark
" yank/paste を常に OS クリップボードに
set clipboard+=unnamedplus
" （古いVim互換のため）PRIMARYも使うなら
set clipboard+=unnamed

" vim-plugを自動導入、vim,nvim両対応
let s:data_dir = has('nvim') ? stdpath('data') . '/site' : expand('~/.vim')

if empty(glob(s:data_dir . '/autoload/plug.vim'))
  if executable('curl')
    silent execute '!curl -fLo ' . shellescape(s:data_dir . '/autoload/plug.vim') .
          \ ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  elseif executable('wget')
    " Ubuntu最小構成など curl 無しを吸収
    silent execute '!wget -O ' . shellescape(s:data_dir . '/autoload/plug.vim') .
          \ ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  else
    echohl ErrorMsg
    echom '[vim-plug] curl/wget not found; install one of them and restart Vim'
    echohl None
  endif

  " 初回起動で同期インストール→vimrc再読込（公式の流れ）
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdtree'         " ファイルツリー
  Plug 'ctrlpvim/ctrlp.vim'         " ファジーファインダ
  Plug 'tpope/vim-surround'         " 囲み編集
  Plug 'tpope/vim-commentary'       " コメントトグル
  Plug 'jiangmiao/auto-pairs'       " 括弧の自動補完
  Plug 'itchyny/lightline.vim'      " 軽量ステータスライン
  Plug 'vim-syntastic/syntastic'    " 同期Lint（gcc/cc）
  Plug 'morhetz/gruvbox'            " 軽量配色
  Plug 'rhysd/vim-clang-format'     " C/C++ 本格整形（clang-formatがある時）
  Plug 'sbdchd/neoformat'           " ある言語のフォーマッタを一括起動（任意）
call plug#end()
" クリップボード非対応でもOSC52でコピーできる
call plug#begin('~/.vim/plugged')
Plug 'ojroques/vim-oscyank'
call plug#end()
" === OSC52でyankをOSクリップボードへ送る ===
if has('patch-8.0.1200') || has('nvim')
  function! s:osc52_send(str) abort
    if empty(a:str) | return | endif
    let l:b64 = system('base64 | tr -d "\n"', a:str)
    let l:b64 = substitute(l:b64, '\n\+$', '', '')
    call system('printf "\033]52;c;' . l:b64 . '\a"')
  endfunction
  augroup Osc52Yank
    autocmd!
    autocmd TextYankPost * if v:event.operator is 'y' |
          \ call <SID>osc52_send(getreg(v:event.regname=='' ? '"' : v:event.regname, 1)) |
          \ endif
  augroup END
endif
" 最後に yank した内容を ~/.yank.txt に保存 & 画面表示（手動コピーしやすい）
function! YankSave() abort
  let s = getreg('"', 1, 1)   " 改行保持で取得
  call writefile(s, expand('~/.yank.txt'))
  new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, s)
  normal! gg
  echo 'Saved to ~/.yank.txt'
endfunction

" ノーマルで <leader>yy、ビジュアルで <leader>y で保存
nnoremap <leader>yy y:call YankSave()<CR>
vnoremap <leader>y  y:call YankSave()<CR>

" Visual選択→<leader>y でOSクリップへ
vnoremap <leader>y :OSCYank<CR>
let g:oscyank_silent = v:true

" 通常の yank（yy / y / yw など）後に自動でOSクリップへ送る
augroup OscYank
  autocmd!
  autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname == '' |
        \ execute 'OSCYankReg "' |
        \ endif
augroup END

" ===================== カラースキーム =====================
try
  colorscheme gruvbox
catch
  colorscheme default
endtry

" ===================== 透明化（常時＆トグル） =====================
" ===================== 透明化（強化版） =====================
if has('termguicolors')
  set termguicolors
endif

augroup TransparentBG
  autocmd!
  " colorscheme 適用のたびに再適用
  autocmd ColorScheme * call s:TransparentOn()
  " 全プラグイン読み込み後にもう一回
  autocmd VimEnter * call s:TransparentOn()
augroup END

function! s:hi(groups) abort
  for g in a:groups
    execute 'highlight' g 'guibg=NONE ctermbg=NONE'
  endfor
endfunction

function! s:TransparentOn() abort
  call s:hi([
  \ 'Normal','NormalNC','NonText','EndOfBuffer',
  \ 'SignColumn','LineNr','CursorLine','CursorLineNr',
  \ 'StatusLine','StatusLineNC','WinSeparator','VertSplit',
  \ 'Pmenu','PmenuSel','PmenuSbar','PmenuThumb',
  \ 'ColorColumn','Folded','TabLine','TabLineFill','TabLineSel',
  \ 'NormalFloat','FloatBorder','FloatTitle'
  \ ])
endfunction

" すべてのハイライトに強制透明をかけたい時の非常手段
command! TransparentAll call s:TransparentAll()
function! s:TransparentAll() abort
  redir => l:out | silent highlight | redir END
  for l in split(l:out, "\n")
    let m = matchlist(l, '^\(\S\+\)\s\+xxx')
    if len(m) >= 2
      execute 'highlight' m[1] 'guibg=NONE ctermbg=NONE'
    endif
  endfor
  echo "All highlight groups set to bg=NONE"
endfunction

" 手動トグル
command! TransparentOn  call s:TransparentOn()
command! TransparentOff execute 'colorscheme ' . get(g:, 'colors_name', 'default')
nnoremap <leader>tb :TransparentOn<CR>

command! TransparentOn  call s:TransparentOn()
command! TransparentOff execute 'colorscheme ' . get(g:, 'colors_name', 'default')
nnoremap <leader>tb :TransparentOn<CR>   " <Space>tb で再適用

" ===================== 好みの色（関数/変数/型/定数/コメント） =====================
" TrueColor端末：guifgを #RRGGBB に。2色端末：ctermfg を 0-255 に。
highlight Function   guifg=#5FFF5F ctermfg=226 gui=NONE  cterm=NONE
highlight Identifier guifg=#66D9EF ctermfg=81  gui=NONE  cterm=NONE
highlight Statement  guifg=#F92672 ctermfg=197 gui=NONE  cterm=NONE
highlight Type       guifg=#AF87FF ctermfg=141 gui=NONE  cterm=NONE
highlight Constant   guifg=#FFAF00 ctermfg=213 gui=NONE  cterm=NONE
highlight Comment    guifg=#75715E ctermfg=242 gui=italic cterm=italic

" ---- 色を即変更できるコマンド ----
" 使い方:
"   :SetColor Function #FFCC00     （TrueColor）
"   :SetColor Identifier 81        （256色）
"   :Bg NONE                       （背景を完全透明に）
"   :Bg #1E1E1E / :Bg 235          （背景を単色に）
command! -nargs=+ SetColor call s:SetColor(<f-args>)
command! -nargs=1 Bg       call s:SetBg(<f-args>)
command! -nargs=1 ColorPreset call s:ApplyPreset(<f-args>)

function! s:SetColor(group, value) abort
  if a:value =~? '^#'
    execute 'highlight' a:group 'guifg=' . a:value 'ctermfg=NONE'
  else
    execute 'highlight' a:group 'ctermfg=' . a:value 'guifg=NONE'
  endif
endfunction

function! s:SetBg(val) abort
  if a:val ==# 'NONE'
    call s:TransparentOn()
  elseif a:val =~? '^#'
    execute 'highlight Normal   guibg=' . a:val
    execute 'highlight NonText  guibg=' . a:val
    execute 'highlight EndOfBuffer guibg=' . a:val
  else
    execute 'highlight Normal   ctermbg=' . a:val
    execute 'highlight NonText  ctermbg=' . a:val
    execute 'highlight EndOfBuffer ctermbg=' . a:val
  endif
endfunction

" 好みのプリセット（任意で追加OK）
let g:color_presets = {
\ 'monokai':   {'Function':'#A6E22E','Identifier':'#66D9EF','Statement':'#F92672','Type':'#AE81FF','Constant':'#FD971F','Comment':'#75715E'},
\ 'nord':      {'Function':'#A3BE8C','Identifier':'#88C0D0','Statement':'#BF616A','Type':'#B48EAD','Constant':'#D08770','Comment':'#616E88'},
\ 'solarized': {'Function':'#859900','Identifier':'#268BD2','Statement':'#CB4B16','Type':'#6C71C4','Constant':'#B58900','Comment':'#586E75'}
\ }

function! s:ApplyPreset(name) abort
  if !has_key(g:color_presets, a:name)
    echohl ErrorMsg | echom 'No such palette: ' . a:name | echohl None
    return
  endif
  for [grp, col] in items(g:color_presets[a:name])
    call s:SetColor(grp, col)
  endfor
  echo 'Applied palette: ' . a:name
endfunction

" ===================== Lightline（座標非表示寄り） =====================
let g:lightline = {
\ 'active': {
\   'left':  [ ['mode','paste'], ['readonly','filename'] ],
\   'right': [ ['percent'], ['fileformat','fileencoding','filetype'] ]
\ } }

" ===================== Syntastic（C） =====================
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_c_compiler = 'cc'
let g:syntastic_c_compiler_options = '-Wall -Wextra -Werror -std=c11 -pedantic'

" ===================== フォーマッタ =====================
" A) 軽量内蔵整形（末尾空白トリム + TAB統一 + 自動インデント）
function! s:FormatLite() abort
  let l:view = winsaveview()
  silent keeppatterns %s/\s\+$//e
  silent retab!
  silent normal! gg=G
  call winrestview(l:view)
  echo "FormatLite: trim + retab + reindent"
endfunction
command! Format call s:FormatLite()
nnoremap <leader>f :Format<CR>      " <Space>f で軽量整形

" B) clang-format が見つかる時だけ有効化（全体整形は <Space>cf）
if executable('clang-format') && exists(':ClangFormat')
  let g:clang_format#detect_style_file = 1
  let g:clang_format#style_options = {
  \ 'BasedOnStyle': 'LLVM',
  \ 'IndentWidth': 4,
  \ 'TabWidth': 4,
  \ 'UseTab': 'Always',
  \ 'ColumnLimit': 80
  \}
  nnoremap <leader>cf :ClangFormat<CR>
endif

" C) Neoformat（入っていれば <Space>F で利用）
if exists(':Neoformat')
  let g:neoformat_only_msg_on_error = 1
  nnoremap <leader>F :Neoformat<CR>
endif

" ===================== よく使うトグル =====================
nnoremap <leader>cl :set cursorline!<CR>      " 白い膜ON/OFF
nnoremap <leader>cc :execute 'set colorcolumn=' . (&colorcolumn=='' ? '80' : '')<CR>
nnoremap <leader>rn :set relativenumber!<CR>  " 相対行番号トグル（普段はOFF推奨）
nnoremap <leader>e  :NERDTreeToggle<CR>
let g:ctrlp_map = '<c-p>'

" ===================== 単発ビルド＆実行（単一Cファイル） =====================
nnoremap <F9> :w<CR>:!cc -Wall -Wextra -Werror -g % -o %:r && ./%:r<CR>
"（プロジェクトでは make 推奨）
