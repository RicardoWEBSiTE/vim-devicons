" Version: 0.8.1
" Webpage: https://github.com/ryanoasis/vim-devicons
" Maintainer: Ryan McIntyre <ryanoasis@gmail.com>
" License: see LICENSE

" @todo fix duplicate global variable initialize here:
if !exists('g:webdevicons_enable')
  let g:webdevicons_enable = 1
endif

if !exists('g:webdevicons_enable_nerdtree')
  let g:webdevicons_enable_nerdtree = 1
endif

if !exists('g:DevIconsEnableFoldersOpenClose')
  let g:DevIconsEnableFoldersOpenClose = 0
endif

if !exists('g:DevIconsEnableFolderPatternMatching')
  let g:DevIconsEnableFolderPatternMatching = 1
endif

if !exists('g:DevIconsEnableFolderExtensionPatternMatching')
  let g:DevIconsEnableFolderExtensionPatternMatching = 0
endif

" end @todo duplicate global variables

" Temporary (hopefully) fix for glyph issues in gvim (proper fix is with the
" actual font patcher)
if !exists('g:webdevicons_gui_glyph_fix')
  let g:webdevicons_gui_glyph_fix = 1
endif

if g:webdevicons_enable_nerdtree == 1
  if !exists('g:loaded_nerd_tree')
     echohl WarningMsg |
       \ echomsg "vim-webdevicons requires NERDTree to be loaded before vim-webdevicons."
  endif

  if exists('g:loaded_nerd_tree') && g:loaded_nerd_tree == 1 && !exists('g:NERDTreePathNotifier')
     let g:webdevicons_enable_nerdtree = 0
     echohl WarningMsg |
        \ echomsg "vim-webdevicons requires a newer version of NERDTree to show glyphs in NERDTree - consider updating NERDTree."
  endif

  " @todo I don't even want this to execute UNLESS the user has the
  " 'nerdtree-git-plugin' INSTALLED (not LOADED)
  " As it currently functions this warning will display even if the user does
  " not have nerdtree-git-plugin not just if it isn't loaded yet 
  " (not what we want)
  "if !exists('g:loaded_nerdtree_git_status')
  "   echohl WarningMsg |
  "     \ echomsg "vim-webdevicons works better when 'nerdtree-git-plugin' is loaded before vim-webdevicons (small refresh issues otherwise)."
  "endif
endif

if !exists('g:webdevicons_enable_airline_tabline')
  let g:webdevicons_enable_airline_tabline = 1
endif

if !exists('g:webdevicons_enable_airline_statusline')
  let g:webdevicons_enable_airline_statusline = 1
endif

function! s:SetupListeners()
  call g:NERDTreePathNotifier.AddListener("init", "NERDTreeWebDevIconsRefreshListener")
  call g:NERDTreePathNotifier.AddListener("refresh", "NERDTreeWebDevIconsRefreshListener")
  call g:NERDTreePathNotifier.AddListener("refreshFlags", "NERDTreeWebDevIconsRefreshListener")
endfunction

" Temporary (hopefully) fix for glyph issues in gvim (proper fix is with the
" actual font patcher)

" NERDTree-C
" scope: global
function! WebDevIconsNERDTreeChangeRootHandler(node)
  call b:NERDTree.changeRoot(a:node)
  call NERDTreeRender()
  call a:node.putCursorHere(0, 0)
  redraw!
endfunction

" NERDTree-u
" scope: global
function! WebDevIconsNERDTreeUpDirCurrentRootClosedHandler()
  call nerdtree#ui_glue#upDir(0)
  redraw!
endfunction

" NERDTreeMapActivateNode and <2-LeftMouse>
" handle the user activating a tree node
" scope: global
function! WebDevIconsNERDTreeMapActivateNode(node)
  let path = a:node.path
  let isOpen = a:node.isOpen
  let padding = g:WebDevIconsNerdTreeAfterGlyphPadding
  let prePadding = ''
  let hasGitFlags = (len(path.flagSet._flagsForScope("git")) > 0)
  let hasGitNerdTreePlugin = (exists('g:loaded_nerdtree_git_status') == 1)

  if g:WebDevIconsUnicodeGlyphDoubleWidth == 0
    let padding = ''
  endif

  if hasGitFlags && g:WebDevIconsUnicodeGlyphDoubleWidth == 1
    let prePadding = ' '
  endif

  " align vertically at the same level: non git-flag nodes with git-flag nodes
  if g:WebDevIconsNerdTreeGitPluginForceVAlign && !hasGitFlags && hasGitNerdTreePlugin
    let prePadding .= '  '
  endif

  " toggle flag
  if isOpen
    let flag = prePadding . g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol . padding
  else
    let flag = prePadding . g:DevIconsDefaultFolderOpenSymbol . padding
  endif

  call a:node.path.flagSet.clearFlags("webdevicons")

  if flag != ''
    call a:node.path.flagSet.addFlag("webdevicons", flag)
    call a:node.path.refreshFlags(b:NERDTree)
  endif

  " continue with normal activate logic
  call a:node.activate()
endfunction

if g:webdevicons_enable == 1 && g:webdevicons_enable_nerdtree == 1
  call s:SetupListeners()

  if g:DevIconsEnableFoldersOpenClose
    " NERDTreeMapActivateNode
    call NERDTreeAddKeyMap({
      \ 'key': g:NERDTreeMapActivateNode,
      \ 'callback': 'WebDevIconsNERDTreeMapActivateNode',
      \ 'override': 1,
      \ 'scope': 'DirNode' })

    " <2-LeftMouse>
    call NERDTreeAddKeyMap({
      \ 'key': '<2-LeftMouse>',
      \ 'callback': 'WebDevIconsNERDTreeMapActivateNode',
      \ 'override': 1,
      \ 'scope': 'DirNode' })
  endif

  " Temporary (hopefully) fix for glyph issues in gvim (proper fix is with the
  " actual font patcher)
  if g:webdevicons_gui_glyph_fix == 1 && has("gui_running")
    call NERDTreeAddKeyMap({
      \ 'key': g:NERDTreeMapChangeRoot,
      \ 'callback': 'WebDevIconsNERDTreeChangeRootHandler',
      \ 'override': 1,
      \ 'quickhelpText': "change tree root to the\n\"    selected dir\n\"    plus webdevicons redraw\n\"    hack fix",
      \ 'scope': 'Node' })

    call NERDTreeAddKeyMap({
      \ 'key': g:NERDTreeMapUpdir,
      \ 'callback': 'WebDevIconsNERDTreeUpDirCurrentRootClosedHandler',
      \ 'override': 1,
      \ 'quickhelpText': "move tree root up a dir\n\"    plus webdevicons redraw\n\"    hack fix",
      \ 'scope': 'all' })
  endif
endif

" modeline syntax:
" vim: fdm=marker tabstop=2 softtabstop=2 shiftwidth=2 expandtab:
