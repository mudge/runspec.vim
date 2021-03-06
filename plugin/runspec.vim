" Vim global plugin for running specs appropriate to the current file.
" Maintainer: Paul Mucur (http://mudge.name)

if exists('g:loaded_runspec')
  finish
endif
let g:loaded_runspec = 1

" Public: Save the current file and run its specs or tests. If the file is
" already a spec or test, run it using the appropriate command (rspec through
" Bundler, ruby directly, etc.); if not, find the most appropriate spec or
" test and run that.
"
" Returns nothing.
function s:RunSpec()
  write
  let path = runspec#SpecPath(expand('%'))

  if type(path) == type('')
    exec ':!' . runspec#SpecCommand(path) . ' ' . shellescape(path)
  else
    echo 'No matching spec or test found.'
  endif
endfunction

function s:ToggleTestOrTarget()
  let path = runspec#TogglePath(expand('%'))
  if type(path) == type('')
    exec ':e ' . path
  else
    echo 'No matching test or target found'
  endif
endfunction

if !hasmapto('<Plug>RunSpecRun') && mapcheck('<Leader>t') == ''
  map <unique> <Leader>t <Plug>RunSpecRun
endif

" Expose a single RunSpecRun for mapping.
noremap <unique> <script> <Plug>RunSpecRun <SID>Run
noremap <SID>Run :call <SID>RunSpec()<CR>
noremap <unique> <script> <Plug>RunSpecToggle <SID>Toggle
noremap <SID>Toggle :call <SID>ToggleTestOrTarget()<CR>

" Add a menu item.
noremenu <script> Plugin.Run\ Spec <SID>Run
noremenu <script> Plugin.Toggle\ between\ test\ and\ implementation <SID>Toggle
