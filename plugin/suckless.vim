set termencoding=utf-8
scriptencoding utf8
"|
"| File          : ~/.vim/plugin/suckless.vim
"| Project page  : https://github.com/fabi1cazenave/suckless.vim
"| Author        : Fabien Cazenave
"| Modified/forked by   : Anders Sildnes
"| (changes: 
"removed a lot of functionality, retained ability to move and navigate windows. 
"Added keymaps for mac, termmode, imode and visua mode
"
"| Licence       : WTFPL
"|
"| Tiling window management that sucks less - see http://suckless.org/
"| This emulates wmii/i3 in Vim as much as possible.
"|

let g:SucklessMinWidth = 24       " minimum window width
let g:SucklessIncWidth = 12       " width increment
let g:SucklessIncHeight = 6       " height increment

" Preferences: wrap-around modes for window selection
let g:SucklessWrapAroundJK = 1    " 0 = no wrap
                                  " 1 = wrap in current column (wmii-like)
                                  " 2 = wrap in current tab    (dwm-like)
let g:SucklessWrapAroundHL = 1    " 0 = no wrap
                                  " 1 = wrap in current tab    (wmii-like)
                                  " 2 = wrap in all tabs
let g:SucklessWinKeyMappings = 2
let g:SucklessTabKeyMappings = 2
let g:SucklessTilingEmulation = 1

"|    Tabs / views: organize windows in tabs                                
"|-----------------------------------------------------------------------------
function! WindowCmd(cmd) "
  let w:maximized = 0

  " issue the corresponding 'wincmd'
  let l:winnr = winnr()
  exe 'wincmd ' . a:cmd

  " wrap around if needed
  if winnr() == l:winnr
    " vertical wrapping 
    if 'jk' =~? a:cmd
      " wrap around in current column
      if g:SucklessWrapAroundJK == 1
        let l:tmpnr = -1
        while l:tmpnr != winnr()
          let l:tmpnr = winnr()
          if a:cmd ==? 'j'
            wincmd k
          elseif a:cmd ==? 'k'
            wincmd j
          endif
        endwhile
      " select next/previous window
      elseif g:SucklessWrapAroundJK == 2
        if a:cmd ==? 'j'
          wincmd w
        elseif a:cmd ==? 'k'
          wincmd W
        endif
      endif
    endif "}}}
    " horizontal wrapping 
    if 'hl' =~? a:cmd
      " wrap around in current window
      if g:SucklessWrapAroundHL == 1
        let l:tmpnr = -1
        while l:tmpnr != winnr()
          let l:tmpnr = winnr()
          if a:cmd ==? 'h'
            wincmd l
          elseif a:cmd ==? 'l'
            wincmd h
          endif
        endwhile
      " select next/previous tab
      elseif g:SucklessWrapAroundHL == 2
        if a:cmd ==? 'h'
          if tabpagenr() > 1
            tabprev
            wincmd b
          endif
        elseif a:cmd ==? 'l'
          if tabpagenr() < tabpagenr('$')
            tabnext
            wincmd t
          endif
        endif
      endif
    endif 
  endif

  " ensure the window width is greater or equal to the minimum
  if 'hl' =~? a:cmd && winwidth(0) < g:SucklessMinWidth
    exe 'set winwidth=' . g:SucklessMinWidth
  endif
endfunction 

function! WindowMove(direction) "
  let l:winnr = winnr()
  let l:bufnr = bufnr('%')

  if a:direction ==? 'j'        " move window to the previous row
    wincmd j
    if winnr() != l:winnr
      "exe "normal <C-W><C-X>"
      wincmd k
      wincmd x
      wincmd j
    endif

  elseif a:direction ==? 'k'    " move window to the next row
    wincmd k
    if winnr() != l:winnr
      wincmd x
    endif

  elseif 'hl' =~? a:direction   " move window to the previous/next column
    exe 'wincmd ' . a:direction 
    let l:newwinnr = winnr()

    if l:newwinnr == l:winnr
      " move window to a new column
      exe 'wincmd ' . toupper(a:direction)
    else
      " move window to an existing column
      wincmd p
      wincmd c
      exe 'wincmd ' . a:direction 
      wincmd n
      exe 'b' . l:bufnr
    endif

  endif
endfunction 

" Alt+[hjkl]: select window 
nnoremap <silent>  <M-h> :call WindowCmd('h')<CR>
nnoremap <silent>  <M-j> :call WindowCmd('j')<CR>
nnoremap <silent>  <M-k> :call WindowCmd('k')<CR>
nnoremap <silent>  <M-l> :call WindowCmd('l')<CR>
inoremap <silent> <M-h> <Esc>:call WindowCmd('h')<CR>
inoremap <silent> <M-j> <Esc>:call WindowCmd('j')<CR>
inoremap <silent> <M-k> <Esc>:call WindowCmd('k')<CR>
inoremap <silent> <M-l> <Esc>:call WindowCmd('l')<CR>
tnoremap <silent> <M-h> <C-\><C-n>:call WindowCmd("h")<CR>
tnoremap <silent> <M-j> <C-\><C-n>:call WindowCmd("j")<CR>
tnoremap <silent> <M-k> <C-\><C-n>:call WindowCmd("k")<CR>
tnoremap <silent> <M-l> <C-\><C-n>:call WindowCmd("l")<CR>
vnoremap <silent> <M-h> <Esc>:call WindowCmd("h")<CR>
vnoremap <silent> <M-j> <Esc>:call WindowCmd("j")<CR>
vnoremap <silent> <M-k> <Esc>:call WindowCmd("k")<CR>
vnoremap <silent> <M-l> <Esc>:call WindowCmd("l")<CR>

" Alt+[HJKL]: move current window 
nnoremap <silent> <c-M-H> :call WindowMove("h")<CR>
nnoremap <silent> <c-M-J> :call WindowMove("j")<CR>
nnoremap <silent> <c-M-K> :call WindowMove("k")<CR>
nnoremap <silent> <c-M-L> :call WindowMove("l")<CR>

tnoremap <silent> <c-a-h> <C-\><C-n>:call WindowMove("h")<CR>
tnoremap <silent> <c-a-j> <C-\><C-n>:call WindowMove("j")<CR>
tnoremap <silent> <c-a-k> <C-\><C-n>:call WindowMove("k")<CR>
tnoremap <silent> <c-a-l> <C-\><C-n>:call WindowMove("l")<CR>
                          
inoremap <silent> <c-M-h> <C-\><C-n>:call WindowMove("h")<CR>
inoremap <silent> <c-M-j> <C-\><C-n>:call WindowMove("j")<CR>
inoremap <silent> <c-M-k> <C-\><C-n>:call WindowMove("k")<CR>
inoremap <silent> <c-M-l> <C-\><C-n>:call WindowMove("l")<CR>
                          
vnoremap <silent> <c-M-h> <C-\><C-n>:call WindowMove("h")<CR>
vnoremap <silent> <c-M-j> <C-\><C-n>:call WindowMove("j")<CR>
vnoremap <silent> <c-M-k> <C-\><C-n>:call WindowMove("k")<CR>
vnoremap <silent> <c-M-l> <C-\><C-n>:call WindowMove("l")<CR>

cnoremap <silent> <c-M-h> <C-\><C-n>:call WindowMove("h")<CR>
cnoremap <silent> <c-M-j> <C-\><C-n>:call WindowMove("j")<CR>
cnoremap <silent> <c-M-k> <C-\><C-n>:call WindowMove("k")<CR>
cnoremap <silent> <c-M-l> <C-\><C-n>:call WindowMove("l")<CR>

" dupliate as above, for mac:
nnoremap <silent> ˙ :call WindowCmd('h')<CR>
nnoremap <silent> ∆ :call WindowCmd('j')<CR>
nnoremap <silent> ˚ :call WindowCmd('k')<CR>
nnoremap <silent> ¬ :call WindowCmd('l')<CR>
inoremap <silent> ˙ <Esc>:call WindowCmd('h')<CR>
inoremap <silent> ∆ <Esc>:call WindowCmd('j')<CR>
inoremap <silent> ˚ <Esc>:call WindowCmd('k')<CR>
inoremap <silent> ¬ <Esc>:call WindowCmd('l')<CR>
tnoremap <silent> ˙ <C-\><C-n>:call WindowCmd("h")<CR>
tnoremap <silent> ∆ <C-\><C-n>:call WindowCmd("j")<CR>
tnoremap <silent> ˚ <C-\><C-n>:call WindowCmd("k")<CR>
tnoremap <silent> ¬ <C-\><C-n>:call WindowCmd("l")<CR>
vnoremap <silent> ˙ <Esc>:call WindowCmd("h")<CR>
vnoremap <silent> ∆ <Esc>:call WindowCmd("j")<CR>
vnoremap <silent> ˚ <Esc>:call WindowCmd("k")<CR>
vnoremap <silent> ¬ <Esc>:call WindowCmd("l")<CR>

" Alt+[HJKL]: move current window 
nnoremap <silent> Ó :call WindowMove("h")<CR>
nnoremap <silent> Ô :call WindowMove("j")<CR>
nnoremap <silent>  :call WindowMove("k")<CR>
nnoremap <silent> Ò :call WindowMove("l")<CR>

tnoremap <silent> Ó <C-\><C-n>:call WindowMove("h")<CR>
tnoremap <silent> Ô <C-\><C-n>:call WindowMove("j")<CR>
tnoremap <silent>  <C-\><C-n>:call WindowMove("k")<CR>
tnoremap <silent> Ò <C-\><C-n>:call WindowMove("l")<CR>
                          
inoremap <silent> Ó <C-\><C-n>:call WindowMove("h")<CR>
inoremap <silent> Ô <C-\><C-n>:call WindowMove("j")<CR>
inoremap <silent>  <C-\><C-n>:call WindowMove("k")<CR>
inoremap <silent> Ò <C-\><C-n>:call WindowMove("l")<CR>
                          
vnoremap <silent> Ó <C-\><C-n>:call WindowMove("h")<CR>
vnoremap <silent> Ô <C-\><C-n>:call WindowMove("j")<CR>
vnoremap <silent>  <C-\><C-n>:call WindowMove("k")<CR>
vnoremap <silent> Ò <C-\><C-n>:call WindowMove("l")<CR>

cnoremap <silent> Ó <C-\><C-n>:call WindowMove("h")<CR>
cnoremap <silent> Ô <C-\><C-n>:call WindowMove("j")<CR>
cnoremap <silent>  <C-\><C-n>:call WindowMove("k")<CR>
cnoremap <silent> Ò <C-\><C-n>:call WindowMove("l")<CR>
