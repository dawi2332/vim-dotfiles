if has('vim_starting')
  silent! execute pathogen#infect()
endif

set nocompatible
set ignorecase
set smartcase       " Case insensitive searches become sensitive with capitals

set foldmethod=marker
set foldopen+=jump

set hlsearch

if &listchars ==# 'eol:$'
  if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && version >= 700
    let &listchars = "tab:\u21e5\u00b7,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"
    let &fillchars = "vert:\u259a,fold:\u00b7"
  else
    set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
  endif
endif

"set backupdir=~/.vim/sessions
"set dir=~/.vim/sessions

" Don't use Ex mode, use Q for formatting
map Q gq


if has("autocmd") " {{{1
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

  augroup FTOptions " {{{2
    autocmd!
    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4 smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
    "let python_highlight_all=1
    "let python_highlight_exceptions=0
    "let python_highlight_builtins=0
    autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType php setlocal shiftwidth=8 tabstop=8 softtabstop=8

    " template language support (SGML / XML too)
    " ------------------------------------------
    "  and disable taht stupid html rendering (like making stuff bold etc)

    fun! s:SelectHTML() " {{{3
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
    " }}}3

    autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    autocmd BufNewFile,BufRead *.rhtml setlocal ft=eruby
    autocmd BufNewFile,BufRead *.mako setlocal ft=mako
    autocmd BufNewFile,BufRead *.tmpl setlocal ft=htmljinja
    autocmd BufNewFile,BufRead *.py_tmpl setlocal ft=python
    autocmd BufNewFile,BufRead *.html,*.htm
          \ call s:SelectHTML()
          \ let html_no_rendering=1
          \ let g:closetag_default_xml=1
    autocmd FileType html,htmldjango,htmljinja,eruby,mako let b:closetag_html_style=1
    autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako source ~/.vim/scripts/closetag.vim
    autocmd FileType css setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType java setlocal shiftwidth=4 tabstop=4 softtabstop=4
    autocmd BufNewFile,BufRead *.txt setlocal ft=rst
    autocmd FileType rst setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType cs setlocal tabstop=8 softtabstop=8 shiftwidth=8
    autocmd FileType vim setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
    autocmd FileType javascript setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
          \ | let javascript_enable_domhtmlcss=1
    autocmd FileType json setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
    autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
    autocmd FileType d setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
    autocmd FileType sh setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
    autocmd FileType zsh setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4
    autocmd FileType go setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType tex setlocal formatoptions+=l
          \ | let b:surround_{char2nr('x')} = "\\texttt{\r}"
          \ | let b:surround_{char2nr('l')} = "\\\1identifier\1{\r}"
          \ | let b:surround_{char2nr('e')} = "\\begin{\1environment\1}\n\r\n\\end{\1\1}"
          \ | let b:surround_{char2nr('v')} = "\\verb|\r|"
          \ | let b:surround_{char2nr('V')} = "\\begin{verbatim}\n\r\n\\end{verbatim}"
  augroup END " }}}2
else
  set autoindent " always set autoindenting on
endif " has("autocmd") }}}1

"
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

function! Fancy() " {{{1
  if &number
    if has("gui_running")
      let &columns=&columns-12
    endif
    windo set nonumber foldcolumn=0
    if exists("+cursorcolumn")
      set nocursorcolumn nocursorline
    endif
    set nolist
  else
    if has("gui_running")
      let &columns=&columns+12
    endif
    windo set number foldcolumn=4
    if exists("+cursorcolumn")
      set cursorline
    endif
    set list
  endif
endfunction
command! -bar Fancy :call Fancy()
" }}}1

" compiler stuff
let g:compiler_gcc_ignore_unmatched_lines=1
let mapleader=','
" quickfix :make
nmap <silent> <Leader>m :wa<CR>:silent! make \| redraw!<CR>
vmap <silent> <Leader>m :wa<CR>:silent! make \| redraw!<CR>
" handy shortcuts
map <Leader>h :lcl<CR>
map <Leader>s :lw<CR>
map <Leader>l :ll<CR>
" jump between mssages
map <Leader>n :lne<CR>
map <Leader>p :cp<CR>

if has("gui_running")
  map <F2> :Fancy<CR>
endif
nmap <F11> :TagbarToggle<CR>

" Plugin options {{{1
let g:bufferline_echo = 0

if exists("+statusline")
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
endif

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:Powerline_symbols = 'fancy'
let g:Powerline_colorscheme = 'solarized256'
let g:airline_theme = 'solarized'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
" }}}1

if (&t_Co > 2 || has("gui_running")) && has("syntax") " {{{1
  function! s:initialize_font()
    if exists("&guifont")
      if has("mac")
        set guifont=Meslo\ LG\ S\ Regular\ for\ Powerline:h13,Menlo:h13
        if has("gui_running")
          set macthinstrokes
        endif
      elseif has("unix")
        if &guifont == ""
          set guifont=Monospace\ Medium\ 12
        endif
      elseif has("win32")
        set guifont=Consolas:h11,Courier\ New:h10
      endif
    endif
  endfunction

  command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
  command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
  noremap <M-,>        :Smaller<CR>
  noremap <M-.>        :Bigger<CR>

  if exists("syntax_on") || exists("syntax_manual")
  else
    syntax on
  endif
  if !exists('g:colors_name')
    silent! colorscheme darkbone
  endif

  augroup RCVisual
    autocmd!
    autocmd VimEnter *  if !has("gui_running") | set background=dark notitle noicon | endif
    autocmd GUIEnter *  set background=dark title icon lines=32 columns=100 guioptions-=T guioptions-=m guioptions-=e guioptions-=r guioptions-=L
    autocmd GUIEnter *  if has("diff") && &diff | set columns=165 | endif
    autocmd GUIEnter *  silent! colorscheme solarized
    autocmd GUIEnter *  call s:initialize_font()
    autocmd GUIEnter *  let $GIT_EDITOR = 'false'
    autocmd Syntax sh   syn sync minlines=500
    autocmd Syntax css  syn sync minlines=50
    autocmd Syntax csh  hi link cshBckQuote Special | hi link cshExtVar PreProc | hi link cshSubst PreProc | hi link cshSetVariables Identifier
  augroup END
endif " (&t_Co > 2 || has("gui_running")) && has("syntax") }}}1
