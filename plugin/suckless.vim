"|
"| File          : ~/.vim/plugin/suckless.vim
"| Project page  : https://github.com/fabi1cazenave/suckless.vim
"| Author        : Fabien Cazenave
"| Modified/forked by   : Anders Sildnes
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
if !exists("g:MetaSendsEscape")
  let g:MetaSendsEscape = !has("gui_running") && !has("nvim")
endif

"|    Tabs / views: organize windows in tabs                                
"|-----------------------------------------------------------------------------

set tabline=%!SucklessTabLine()
function! SucklessTabLine() "
  let line = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i+1 == tabpagenr()
      let line .= '%#TabLineSel#'
    else
      let line .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let line .= '%' . (i+1) . 'T'
    let line .= ' [' . (i+1)

    " modified since the last save?
    let buflist = tabpagebuflist(i+1)
    for bufnr in buflist
      if getbufvar(bufnr, '&modified')
        let line .= '*'
        break
      endif
    endfor
    let line .= ']'

    " add the file name without path information
    let buf = buflist[tabpagewinnr(i+1) - 1]
    let name = bufname(buf)
    if getbufvar(buf, '&modified') == 1
      let name .= " +"
    endif
    let line .= fnamemodify(name, ':t') . ' '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let line .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let line .= '%=%#TabLine#%999X X'
  endif
  "echomsg 's:' . s
  return line
endfunction "}}}

set guitablabel=%{SucklessTabLabel()}
function! SucklessTabLabel() "
  " see: http://blog.golden-ratio.net/2008/08/19/using-tabs-in-vim/

  " add the Tab number
  let label = '['.tabpagenr()

  " modified since the last save?
  let buflist = tabpagebuflist(v:lnum)
  for bufnr in buflist
    if getbufvar(bufnr, '&modified')
      let label .= '*'
      break
    endif
  endfor

  " count number of open windows in the Tab
  "let wincount = tabpagewinnr(v:lnum, '$')
  "if wincount > 1
    "let label .= ', '.wincount
  "endif
  let label .= '] '

  " add the file name without path information
  let name = bufname(buflist[tabpagewinnr(v:lnum) - 1])
  let label .= fnamemodify(name, ':t')
  if &modified == 1
    let label .= " +"
  endif

  return label
endfunction "}}}

"|    Window tiles: selection, movement, resizing                           
"|-----------------------------------------------------------------------------


function! WindowCmd(cmd) "
  let w:maximized = 0

  " issue the corresponding 'wincmd'
  let winnr = winnr()
  exe "wincmd " . a:cmd

  " wrap around if needed
  if winnr() == winnr
    " vertical wrapping 
    if "jk" =~ a:cmd
      " wrap around in current column
      if g:SucklessWrapAroundJK == 1
        let tmpnr = -1
        while tmpnr != winnr()
          let tmpnr = winnr()
          if a:cmd == "j"
            wincmd k
          elseif a:cmd == "k"
            wincmd j
          endif
        endwhile
      " select next/previous window
      elseif g:SucklessWrapAroundJK == 2
        if a:cmd == "j"
          wincmd w
        elseif a:cmd == "k"
          wincmd W
        endif
      endif
    endif "}}}
    " horizontal wrapping 
    if "hl" =~ a:cmd
      " wrap around in current window
      if g:SucklessWrapAroundHL == 1
        let tmpnr = -1
        while tmpnr != winnr()
          let tmpnr = winnr()
          if a:cmd == "h"
            wincmd l
          elseif a:cmd == "l"
            wincmd h
          endif
        endwhile
      " select next/previous tab
      elseif g:SucklessWrapAroundHL == 2
        if a:cmd == "h"
          if tabpagenr() > 1
            tabprev
            wincmd b
          endif
        elseif a:cmd == "l"
          if tabpagenr() < tabpagenr('$')
            tabnext
            wincmd t
          endif
        endif
      endif
    endif "}}}
  endif

  " ensure the window width is greater or equal to the minimum
  if "hl" =~ a:cmd && winwidth(0) < g:SucklessMinWidth
    exe "set winwidth=" . g:SucklessMinWidth
  endif
endfunction "}}}

function! WindowMove(direction) "
  let winnr = winnr()
  let bufnr = bufnr("%")

  if a:direction == "j"        " move window to the previous row
    wincmd j
    if winnr() != winnr
      "exe "normal <C-W><C-X>"
      wincmd k
      wincmd x
      wincmd j
    endif

  elseif a:direction == "k"    " move window to the next row
    wincmd k
    if winnr() != winnr
      wincmd x
    endif

  elseif "hl" =~ a:direction   " move window to the previous/next column
    exe "wincmd " . a:direction
    let newwinnr = winnr()
    if newwinnr == winnr
      " move window to a new column
      exe "wincmd " . toupper(a:direction)
      if t:windowMode == "S"
        wincmd p
        wincmd _
        wincmd p
      endif
    else
      " move window to an existing column
      wincmd p
      wincmd c
      if t:windowMode == "S"
        wincmd _
      endif
      exe newwinnr . "wincmd w"
      wincmd n
      if t:windowMode == "S"
        wincmd _
      endif
      exe "b" . bufnr
    endif

  endif
endfunction "}}}


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
  nnoremap <silent> <Esc>h :call WindowCmd("h")<CR>
  nnoremap <silent> <Esc>j :call WindowCmd("j")<CR>
  nnoremap <silent> <Esc>k :call WindowCmd("k")<CR>
  nnoremap <silent> <Esc>l :call WindowCmd("l")<CR>
else
  nnoremap <silent>  <M-h> :call WindowCmd("h")<CR>
  nnoremap <silent>  <M-j> :call WindowCmd("j")<CR>
  nnoremap <silent>  <M-k> :call WindowCmd("k")<CR>
  nnoremap <silent>  <M-l> :call WindowCmd("l")<CR>
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
    nnoremap <silent> <S-M-h> :call WindowMove("h")<CR>
    nnoremap <silent> <S-M-j> :call WindowMove("j")<CR>
    nnoremap <silent> <S-M-k> :call WindowMove("k")<CR>
    nnoremap <silent> <S-M-l> :call WindowMove("l")<CR>

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

if has("autocmd")
  " 'Divided' mode by default - each tab has its own window mode
  "autocmd! TabEnter * call GetTilingMode("D")
  " Resize all windows when Vim is resized.
  " developer candy: apply all changes immediately
  autocmd! BufWritePost suckless.vim source %
endif
