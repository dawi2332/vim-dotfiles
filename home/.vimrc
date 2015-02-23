" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

call pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set ignorecase
set smartcase
set number
set laststatus=2
set modeline
set modelines=2
set backupdir=~/.vim/sessions
set dir=~/.vim/sessions
set smarttab
set tabstop=8
set smartindent
set noerrorbells
set cursorline

source ~/.vim/scripts/FeralToggleCommentify.vim

map <M-c> :call ToggleCommentify()<CR>j
imap <M-c>  <ESC>:call ToggleCommentify()<CR>j

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

  autocmd BufEnter * :syntax sync fromstart

  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4 smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
  "let python_highlight_all=1
  "let python_highlight_exceptions=0
  "let python_highlight_builtins=0
  autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType php setlocal shiftwidth=8 tabstop=8 softtabstop=8

  " template language support (SGML / XML too)
  " ------------------------------------------
  "  and disable taht stupid html rendering (like making stuff bold etc)

  fun! s:SelectHTML()
    let n = 1
    while n < 50 && n < line("$")
      " check for jinja
      if getline(n) =~ '{%\s*\(extends\|block\|macro\|set\|if\|for\|include\|trans\)\>'
        set ft=htmljinja
        return
      endif
      " check for django
      if getline(n) =~ '{%\s*\(extends\|block\|comment\|ssi\|if\|for\|blocktrans\)\>'
        set ft=htmldjango
        return
      endif
      " check for mako
      if getline(n) =~ '<%\(def\|inherit\)'
        set ft=mako
        return
      endif
      " check for genshi
      if getline(n) =~ 'xmlns:py\|py:\(match\|for\|if\|def\|strip\|xmlns\)'
        set ft=genshi
        return
      endif
      let n = n + 1
    endwhile
    " go with html
    set ft=html
  endfun

  autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
  autocmd BufNewFile,BufRead *.rhtml setlocal ft=eruby
  autocmd BufNewFile,BufRead *.mako setlocal ft=mako
  autocmd BufNewFile,BufRead *.tmpl setlocal ft=htmljinja
  autocmd BufNewFile,BufRead *.py_tmpl setlocal ft=python
  autocmd BufNewFile,BufRead *.html,*.htm  call s:SelectHTML()
  let html_no_rendering=1

  let g:closetag_default_xml=1
  autocmd FileType html,htmldjango,htmljinja,eruby,mako let b:closetag_html_style=1
  autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako source ~/.vim/scripts/closetag.vim
  autocmd FileType css setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType java setlocal shiftwidth=4 tabstop=4 softtabstop=4
  autocmd BufNewFile,BufRead *.txt setlocal ft=rst
  autocmd FileType rst setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType cs setlocal tabstop=8 softtabstop=8 shiftwidth=8
  autocmd FileType vim setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
  autocmd FileType javascript setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
  let javascript_enable_domhtmlcss=1
  autocmd FileType d setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
  autocmd FileType sh setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
  autocmd FileType zsh setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
  autocmd FileType go setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

"
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

if has("gui_running")
  syntax enable
  set background=dark
  colorscheme solarized
  set guifont=Meslo\ LG\ S\ Regular\ for\ Powerline:h13
  let g:Powerline_symbols = 'fancy'
  let g:Powerline_colorscheme = 'solarized256'
  let g:airline_theme = 'solarized'
  let g:airline_powerline_fonts=1
  let g:airline#extensions#tabline#enabled = 1
  set columns=100
  set lines=32
  set guioptions-=T
  set guioptions-=r
else
  colorscheme darkbone
endif

" compiler stuff
let g:compiler_gcc_ignore_unmatched_lines=1
let mapleader=','
" quickfix :make
nmap <silent> <Leader>m :wa<CR>:silent! make \| redraw! \| cw<CR>
vmap <silent> <Leader>m :wa<CR>:silent! make \| redraw! \| cw<CR>
" handy shortcuts
map <Leader>h :ccl<CR>
map <Leader>s :cw<CR>
map <Leader>l :cl<CR>
" jump between messages
map <Leader>n :cn<CR>
map <Leader>p :cp<CR>

nmap <F8> :TagbarToggle<CR>


let g:bufferline_echo = 0

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
