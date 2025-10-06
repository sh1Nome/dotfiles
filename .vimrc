" -------------------------------
" プラグイン
" -------------------------------
" vim-plugの自動インストール (Linux/Windows対応)
if has('win32') || has('win64')
  let data_dir = expand('~/vimfiles')
else
  let data_dir = expand('~/.vim')
endif
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" vim-plugで管理するプラグイン
call plug#begin()
Plug 'lambdalisue/vim-fern'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" -------------------------------
" システム系
" -------------------------------
" 文字エンコード
set fenc=utf-8
" バックアップファイルを作成禁止
set nobackup
" スワップファイルを作成禁止
set noswapfile
" バックスペース有効化
set backspace=indent,eol,start
" システムクリップボードを利用
set clipboard=unnamed,unnamedplus

" -------------------------------
" 表示系
" -------------------------------
" コマンドを表示
set showcmd
" 行番号を表示
set number
" 相対行番号を表示（現在行は絶対表示）
set relativenumber
" 対応する括弧をハイライト
set showmatch
" タブキー押下時の文字幅
set softtabstop=4
" タブ文字の表示幅
set tabstop=4
" インデント幅
set shiftwidth=4
" 不可視文字を表示
set list
" 不可視文字の表示方法を設定（スペース、タブ、改行、ノーブレークスペース）
set listchars=space:·,tab:▸\ ,eol:¬,nbsp:_
" ステータスラインを常に表示
set laststatus=2
" ルーラー（カーソル位置）を表示
set ruler
" モード表示を有効化
set showmode
" 常に3行のスクロールオフセットを確保
set scrolloff=3
" カーソル行をハイライト
set cursorline
" タブをスペースに変換
set expandtab
" タブラインを常に表示
set showtabline=2

" -------------------------------
" 検索系
" -------------------------------
" 大文字小文字を区別しない
set ignorecase
" 入力中に検索開始
set incsearch
" 検索結果をハイライト
set hlsearch

" -------------------------------
" プラグイン系
" -------------------------------
" lightline.vimでバッファ一覧をタブラインに表示
function! LightlineBuffers()
  let buflist = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  return map(buflist, {_, b ->
    \ (b == bufnr('%')
    \   ? '%#TabLineSel# ' . (bufname(b) ==# '' ? '[No Name]' : fnamemodify(bufname(b), ':t')) . ' %#TabLine#'
    \   : ' ' . (bufname(b) ==# '' ? '[No Name]' : fnamemodify(bufname(b), ':t')) . ' ')
    \ })
endfunction
let g:lightline = {
  \ 'tabline': { 'left': [ [ 'buffers' ] ] },
  \ 'component_expand': { 'buffers': 'LightlineBuffers' },
  \ }
" vim-fernで隠しファイルも常に表示
let g:fern#default_hidden = 1

" -------------------------------
" キーマッピング
" -------------------------------
" バッファ移動
nnoremap H :bprevious<CR>
nnoremap L :bnext<CR>
" リーダーキーをスペースに設定
let mapleader = " "
" <leader>eでfernを起動
nnoremap <leader>e :Fern . -reveal=%<CR>
" <leader><space>でfzf.vimを起動
nnoremap <leader><space> :Files<CR>
" <leader>gでlazygitを起動
nnoremap <leader>g :silent !lazygit<CR>:redraw!<CR>
