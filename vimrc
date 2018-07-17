set nocompatible

" Buffers and files
set hidden
set autowrite
set nobackup
set noswapfile

" Editing
set backspace=indent,eol,start
set autoindent
set sw=4 sts=4 ts=8 et tw=0
set nojoinspaces

" UI
syntax on
set bg=dark
set showcmd
set ruler
set splitbelow
set splitright
set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
let &showbreak='↳'
set wrap
set linebreak
set visualbell t_vb=
set noerrorbells
set shortmess+=I
set title

" Menu
set wildmenu
set wildmode=list:longest,full
set wildignore+=*.so,*.dll,*.o,*.a,*.obj,*.exe,*.pyc,*.class
set wildignore+=.git,.hg,.svn
set wildignore+=*.bak,*.swp,.DS_Store,*.tmp,*~

" Completion
set ofu=syntaxcomplete#Complete
set completeopt=menuone,longest,preview

" Search & replace
set gdefault
set showmatch
set ignorecase
set infercase
set smartcase
set incsearch
set nohls

" File type detection
filetype on
filetype plugin on
filetype indent on

" Folding
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

" Custom function confs
let g:findcmd = 'find . \( -type f -o -type l \) -iname'

" Functions
function! s:BufferInfo()
    let name = expand('%:t')
    let name = empty(l:name) ? '[No Name]' : l:name
    let maininfo = bufnr('%') . ' ' . name
    let infos = join([
        \ empty(&ft) ? '-' : &ft,
        \ empty(&fenc) ? '-' : &fenc,
        \ empty(&ff) ? '-' : &ff,
        \ &modified ? 'modified' : 'unmodified'
        \ ], ', ')
    echo l:maininfo . ': ' . l:infos
endfunction

function! s:GetConfVar(varname, alternative)
    if exists('b:' . a:varname)
        return eval('b:' . a:varname)
    elseif exists('g:' . a:varname)
        return eval('g:' . a:varname)
    else
        return a:alternative
    endif
endfunction

function! s:CommentLines(...) range
    let commentstart = a:0 >= 1 ? a:1 : s:GetConfVar('commentsymbol', '//')
    let commentend = a:0 >= 2 ? a:2 : s:GetConfVar('commentsymbolend', '')
    let beginsWithComment = getline(a:firstline) =~ ('\M^' . l:commentstart)

    for linenum in range(a:firstline, a:lastline)
        let line = getline(l:linenum)
        let replacement = l:beginsWithComment
            \ ? substitute(line, '\M^' . l:commentstart . '\s\?', '', '')
            \ : l:commentstart . ' ' . l:line
        if !empty(l:commentend)
            let l:replacement = l:beginsWithComment
                \ ? substitute(l:replacement, '\M\s\?' . l:commentend . '$', '', '')
                \ : l:replacement . ' ' . l:commentend
        endif
        call setline(l:linenum, l:replacement)
    endfor

    call cursor(a:lastline + 1, 1)
endfunction

function! s:CommentSymbol(start, ...)
    let b:commentsymbol = a:start
    if a:0 >= 1
        let b:commentsymbolend = a:1
    elseif exists('b:commentsymbolend')
        unlet b:commentsymbolend
    endif
endfunction

function! s:SetIndent(...)
    let level = a:0 >= 1 ? str2nr(a:1) : 4
    setl et
    let &sts=l:level
    let &sw=l:level
    let &ts=l:level
endfunction

function! s:SetIndentTab(...)
    let level = a:0 >= 1 ? str2nr(a:1) : 4
    setl noet sts=0
    let &sw=l:level
    let &ts=l:level
endfunction

function! s:Underline(...)
    let underlinestring = a:0 >= 1 ? a:1 : s:GetConfVar('underlinechar', '=')
    let underlinechar = l:underlinestring[0]
    let linenr = line('.')
    let line_len = len(getline(l:linenr))
    let nextline_nr = l:linenr + 1
    let nextline = getline(l:nextline_nr)
    let underline = repeat(l:underlinechar, l:line_len)
    let is_underlined = nextline =~ ('^' . l:underlinechar . '\+$')
    if is_underlined
        call setline(l:nextline_nr, l:underline)
    else
        call append(l:linenr, l:underline)
    endif
endfunction

function! s:RunShellCommand(cmdline)
    let expanded_cmdline = a:cmdline
    for part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let expanded_part = fnameescape(expand(part))
            let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
        endif
    endfor
    botright new
    setl buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    call setline(1, a:cmdline)
    call setline(2, substitute(a:cmdline, '.', '=', 'g'))
    execute 'silent $read !'. expanded_cmdline
    setl nomodifiable
    1
endfunction

function! s:Find(pattern)
    let fullcmd = g:findcmd . " '*" . a:pattern . "*'"

    let files = systemlist(l:fullcmd)
    if len(l:files) == 0
        echo 'No files found'
        return
    endif

    let results = map(l:files, {entry, file -> {'filename': file, 'lnum': 1}})
    let id = win_getid()
    let title = 'Find: ' . a:pattern

    call setloclist(l:id, l:results, 'r')
    call setloclist(l:id, [], 'a', {'title': l:title})
    lwindow
endfunction

function! s:Search(pattern)
    execute 'silent! lgrep! ' . a:pattern
    lwindow
endfunction

" Commands
command! -nargs=0 BufferInfo call s:BufferInfo()
command! -nargs=* -range Comment <line1>,<line2>call s:CommentLines(<f-args>)
command! -nargs=+ CommentSymbol call s:CommentSymbol(<f-args>)
command! -nargs=0 Here lcd %:p:h
command! -nargs=* SetIndent call s:SetIndent(<f-args>)
command! -nargs=* SetIndentTab call s:SetIndentTab(<f-args>)
command! -nargs=? Underline call s:Underline(<f-args>)
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
command! -nargs=1 Find call s:Find(<q-args>)
command! -nargs=1 Search call s:Search(<q-args>)

" Custom file types
augroup filetypedetect
    au BufRead,BufNewFile *.txt setfiletype text
    au BufRead,BufNewFile *mutt-* setfiletype mail
    au BufRead,BufNewFile *.md setfiletype markdown
augroup END

" Config by file type
au FileType go SetIndentTab 4

" Preferred defaults
noremap k gk
noremap j gj
nnoremap <space> za
map x "_dl
map X "_dh
map Y y$
vnoremap < <gv
vnoremap > >gv
inoremap <M-Backspace> <C-w>
inoremap <Esc><Backspace> <C-w>
cnoremap <M-Backspace> <C-w>
cnoremap <Esc><Backspace> <C-w>

" Custom command mappings
nnoremap <Leader>i :BufferInfo<cr>
nnoremap <silent> <M-;> :Comment<cr>
nnoremap <silent> <Esc>; :Comment<cr>
vnoremap <silent> <M-;> :Comment<cr>
vnoremap <silent> <Esc>; :Comment<cr>

" Autocompleted commands
nnoremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <cr>

" Copy/paste
vnoremap <Leader>c "+y
nnoremap <Leader>v "+p

" Ctrl+Space for omnicompletion
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>

" Toggles
nnoremap <Leader>th :set hlsearch! hlsearch?<cr>
nnoremap <Leader>tp :setl paste! paste?<cr>
nnoremap <Leader>tn :set number!<cr>
nnoremap <Leader>tl :set list! list?<cr>
nnoremap <Leader>tw :set wrap! wrap?<cr>
nnoremap <Leader>tc :set cursorline! cursorline?<cr>
nnoremap <Leader>ts :setl spell! spell?<cr>

" Replace commands
nnoremap <Leader>rw :%s/\s\+$//e<cr>

" Finding files
autocmd VimEnter *
            \ if exists(':FZF') | nnoremap <Leader>f :FZF<cr> |
            \ else | nnoremap <Leader>f :Find | endif

" Grep
nnoremap <Leader>s :Search<space>
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

" Mouse
set mouse=a

" Colors
hi statusline term=inverse,bold cterm=inverse,bold ctermfg=darkblue ctermbg=white
    \ gui=inverse,bold guifg=blue guibg=white
hi statuslinenc term=inverse,bold cterm=inverse,bold ctermfg=gray ctermbg=black
    \ gui=inverse,bold guifg=lightgray guibg=black
hi Normal guifg=grey guibg=black

" GUI
if has("gui_running")
    set guioptions-=rLT
endif

" Local conf
if filereadable($HOME . "/.vimrc.local")
    source $HOME/.vimrc.local
endif

