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

function! s:IsMac()
    let l:sysout=system('uname')
    return has('unix') && match(l:sysout, '\cDarwin') == 0
endfunction

" Preferences: window resizing
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

" in gVim, Alt sets the 8th bit; otherwise, assume the terminal is 8-bit clean
" Neovim isn't 8-bit clean yet, see https://github.com/neovim/neovim/issues/3727
if !exists('g:MetaSendsEscape')
  let g:MetaSendsEscape = !has('gui_running') && !has('nvim')
endif

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


" Alt+[0..9]: select Tab [1..10] 
if g:MetaSendsEscape
  nnoremap <silent> <Esc>1 :tabn  1<CR>
  nnoremap <silent> <Esc>2 :tabn  2<CR>
  nnoremap <silent> <Esc>3 :tabn  3<CR>
  nnoremap <silent> <Esc>4 :tabn  4<CR>
  nnoremap <silent> <Esc>5 :tabn  5<CR>
  nnoremap <silent> <Esc>6 :tabn  6<CR>
  nnoremap <silent> <Esc>7 :tabn  7<CR>
  nnoremap <silent> <Esc>8 :tabn  8<CR>
  nnoremap <silent> <Esc>9 :tabn  9<CR>
  nnoremap <silent> <Esc>0 :tabn 10<CR>
else
  nnoremap <silent>  <M-1> :tabn  1<CR>
  nnoremap <silent>  <M-2> :tabn  2<CR>
  nnoremap <silent>  <M-3> :tabn  3<CR>
  nnoremap <silent>  <M-4> :tabn  4<CR>
  nnoremap <silent>  <M-5> :tabn  5<CR>
  nnoremap <silent>  <M-6> :tabn  6<CR>
  nnoremap <silent>  <M-7> :tabn  7<CR>
  nnoremap <silent>  <M-8> :tabn  8<CR>
  nnoremap <silent>  <M-9> :tabn  9<CR>
  nnoremap <silent>  <M-0> :tabn 10<CR>

  if s:IsMac()
    nnoremap <silent>  ¡ :tabn  1<CR>
    nnoremap <silent>  ™ :tabn  2<CR>
    nnoremap <silent>  £ :tabn  3<CR>
    nnoremap <silent>  ¢ :tabn  4<CR>
    nnoremap <silent>  ∞ :tabn  5<CR>
    nnoremap <silent>  § :tabn  6<CR>
    nnoremap <silent>  ¶ :tabn  7<CR>
    nnoremap <silent>  • :tabn  8<CR>
    nnoremap <silent>  º :tabn 10<CR>

    inoremap <silent>  ¡ <Esc>:tabn  1<CR>
    inoremap <silent>  ™ <Esc>:tabn  2<CR>
    inoremap <silent>  £ <Esc>:tabn  3<CR>
    inoremap <silent>  ¢ <Esc>:tabn  4<CR>
    inoremap <silent>  ∞ <Esc>:tabn  5<CR>
    inoremap <silent>  § <Esc>:tabn  6<CR>
    inoremap <silent>  ¶ <Esc>:tabn  7<CR>
    inoremap <silent>  • <Esc>:tabn  8<CR>
    inoremap <silent>  º <Esc>:tabn 10<CR>

    tnoremap <silent>  ¡ <C-\><C-n>:tabn  1<CR>
    tnoremap <silent>  ™ <C-\><C-n>:tabn  2<CR>
    tnoremap <silent>  £ <C-\><C-n>:tabn  3<CR>
    tnoremap <silent>  ¢ <C-\><C-n>:tabn  4<CR>
    tnoremap <silent>  ∞ <C-\><C-n>:tabn  5<CR>
    tnoremap <silent>  § <C-\><C-n>:tabn  6<CR>
    tnoremap <silent>  ¶ <C-\><C-n>:tabn  7<CR>
    tnoremap <silent>  • <C-\><C-n>:tabn  8<CR>
    tnoremap <silent>  º <C-\><C-n>:tabn 10<CR>

    vnoremap <silent>  ¡ <Esc>:tabn  1<CR>
    vnoremap <silent>  ™ <Esc>:tabn  2<CR>
    vnoremap <silent>  £ <Esc>:tabn  3<CR>
    vnoremap <silent>  ¢ <Esc>:tabn  4<CR>
    vnoremap <silent>  ∞ <Esc>:tabn  5<CR>
    vnoremap <silent>  § <Esc>:tabn  6<CR>
    vnoremap <silent>  ¶ <Esc>:tabn  7<CR>
    vnoremap <silent>  • <Esc>:tabn  8<CR>
    vnoremap <silent>  º<M-0> <Esc>:tabn 10<CR>
  endif
endif
"}}}


" Alt+[hjkl]: select window 
if g:MetaSendsEscape
  nnoremap <silent> <Esc>h :call WindowCmd('h')<CR>
  nnoremap <silent> <Esc>j :call WindowCmd('j')<CR>
  nnoremap <silent> <Esc>k :call WindowCmd('k')<CR>
  nnoremap <silent> <Esc>l :call WindowCmd('l')<CR>
else
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

  if s:IsMac()
    inoremap <silent> ˙ <Esc>:call WindowCmd('h')<CR>
    inoremap <silent> ∆ <Esc>:call WindowCmd('j')<CR>
    inoremap <silent> ˚ <Esc>:call WindowCmd('k')<CR>
    inoremap <silent> ¬ <Esc>:call WindowCmd('l')<CR>
    tnoremap <silent> ˙ <C-\><C-n>:call WindowCmd('h')<CR>
    tnoremap <silent> ∆ <C-\><C-n>:call WindowCmd('j')<CR>
    tnoremap <silent> ˚ <C-\><C-n>:call WindowCmd('k')<CR>
    tnoremap <silent> ¬ <C-\><C-n>:call WindowCmd('l')<CR>
    vnoremap <silent> ˙ <C-\><C-n>:call WindowCmd('h')<CR>
    vnoremap <silent> ∆ <C-\><C-n>:call WindowCmd('j')<CR>
    vnoremap <silent> ˚ <C-\><C-n>:call WindowCmd('k')<CR>
    vnoremap <silent> ¬ <C-\><C-n>:call WindowCmd('l')<CR>
    nnoremap <silent> ˙ <C-\><C-n>:call WindowCmd('h')<CR>
    nnoremap <silent> ∆ <C-\><C-n>:call WindowCmd('j')<CR>
    nnoremap <silent> ˚ <C-\><C-n>:call WindowCmd('k')<CR>
    nnoremap <silent> ¬ <C-\><C-n>:call WindowCmd('l')<CR>
    inoremap <silent> ˛ <Esc>:call WindowCmd('h')<CR>
    inoremap <silent> √ <Esc>:call WindowCmd('j')<CR>
    inoremap <silent> ª <Esc>:call WindowCmd('k')<CR>
    inoremap <silent> ﬁ <Esc>:call WindowCmd('l')<CR>
    tnoremap <silent> ˛ <C-\><C-n>:call WindowCmd('h')<CR>
    tnoremap <silent> √ <C-\><C-n>:call WindowCmd('j')<CR>
    tnoremap <silent> ª <C-\><C-n>:call WindowCmd('k')<CR>
    tnoremap <silent> ﬁ <C-\><C-n>:call WindowCmd('l')<CR>
    vnoremap <silent> ˛ <C-\><C-n>:call WindowCmd('h')<CR>
    vnoremap <silent> √ <C-\><C-n>:call WindowCmd('j')<CR>
    vnoremap <silent> ª <C-\><C-n>:call WindowCmd('k')<CR>
    vnoremap <silent> ﬁ <C-\><C-n>:call WindowCmd('l')<CR>
    nnoremap <silent> ˛ <C-\><C-n>:call WindowCmd('h')<CR>
    nnoremap <silent> √ <C-\><C-n>:call WindowCmd('j')<CR>
    nnoremap <silent> ª <C-\><C-n>:call WindowCmd('k')<CR>
    nnoremap <silent> ﬁ <C-\><C-n>:call WindowCmd('l')<CR>
  endif
endif
"}}}

" Alt+[HJKL]: move current window 
if g:MetaSendsEscape
  nnoremap <silent>  <Esc>H :call WindowMove("h")<CR>
  nnoremap <silent>  <Esc>J :call WindowMove("j")<CR>
  nnoremap <silent>  <Esc>K :call WindowMove("k")<CR>
  nnoremap <silent>  <Esc>L :call WindowMove("l")<CR>
else
    " TODO: I don't see how to get S-M-<key> binding to work in neovim
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


    if s:IsMac()
        nnoremap <silent> Ó :call WindowMove("h")<CR>
        nnoremap <silent> Ô :call WindowMove("j")<CR>
        nnoremap <silent>  :call WindowMove("k")<CR>
        nnoremap <silent> Ò :call WindowMove("l")<CR>

        cnoremap <silent> Ó :call WindowMove("h")<CR>
        cnoremap <silent> Ô :call WindowMove("j")<CR>
        cnoremap <silent>  :call WindowMove("k")<CR>
        cnoremap <silent> Ò :call WindowMove("l")<CR>

        inoremap <silent> Ó :call WindowMove("h")<CR>
        inoremap <silent> Ô :call WindowMove("j")<CR>
        inoremap <silent>  :call WindowMove("k")<CR>
        inoremap <silent> Ò :call WindowMove("l")<CR>

        vnoremap <silent> Ó :call WindowMove("h")<CR>
        vnoremap <silent> Ô :call WindowMove("j")<CR>
        vnoremap <silent>  :call WindowMove("k")<CR>
        vnoremap <silent> Ò :call WindowMove("l")<CR>

        tnoremap <silent> Ó <C-\><C-n>:call WindowMove("h")<CR>
        tnoremap <silent> Ô <C-\><C-n>:call WindowMove("j")<CR>
        tnoremap <silent>  <C-\><C-n>:call WindowMove("k")<CR>
        tnoremap <silent> Ò <C-\><C-n>:call WindowMove("l")<CR>
    endif
endif
"}}}


"}}}

"|    Alt+[ocw]: create/collapse/close window                               
"|-----------------------------------------------------------------------------



" preferences 
" Preferences: key mappings to handle windows and tabs
" Warning, using <Alt-key> shortcuts is very handy but it can be tricky:
"  * may conflict with dwm/wmii - set the <Mod> key to <win> for your wm
"  * may conflict with gVim     - disable the menu to avoid this
"  * may raise problems in your terminal emulator (e.g. <M-s> on rxvt)
"  * Shift+Alt+number only works on the US-Qwerty keyboard layout
let g:SucklessWinKeyMappings = 3  " 0 = none - define your own!
                                  " 1 = <Leader> + key(s)
                                  " 2 = <Alt-key>
                                  " 3 = both
let g:SucklessTabKeyMappings = 3  " 0 = none - define your own!
                                  " 1 = <Leader> + key(s)
                                  " 2 = <Alt-key>
                                  " 3 = both
let g:SucklessTilingEmulation = 1 " 0 = none - define your own!
                                  " 1 = wmii-style (preferred)
                                  " 2 = dwm-style (not working yet)
