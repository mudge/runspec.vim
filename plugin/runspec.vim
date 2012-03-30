" If the current file is a spec, run it; if not, guess where the spec file is
" and run that.
"
" e.g.
"   spec/models/person_spec.rb => bin/rspec --no-color spec/models/person_spec.rb
"   lib/something.rb => bin/rspec --no-color spec/lib/something_spec.rb
"   app/models/person.rb => bin/rspec --no-color spec/models/person_spec.rb

if exists('g:loaded_runspec')
  finish
endif
let g:loaded_runspec = 1

function s:SpecPath(path)
  let path = a:path

  if match(path, '_\(spec\|test\)\.rb$') == -1

    " First remove app/ from the file name if it is present.
    if match(a:path, '^app/') != -1
      let path = substitute(a:path, '^app/', '', '')
    else
      let path = a:path
    endif

    " Determine whether this is a spec or a test case.
    if isdirectory('spec')
      let path = 'spec/' . substitute(path, '\.rb$', '_spec.rb', '')
    else
      let path = 'test/' . substitute(path, '\.rb$', '_test.rb', '')
    endif
  endif

  return path
endfunction

function s:LoadPath()
  let load_path = ''

  if isdirectory('lib')
    let load_path .= ' -Ilib'
  endif

  if isdirectory('spec')
    let load_path .= ' -Ispec'
  endif

  if isdirectory('test')
    let load_path .= ' -Itest'
  endif

  return load_path
endfunction

function s:HasBundler()
  return filereadable('Gemfile')
endfunction

function s:HasGem(gem)
  if s:HasBundler()
    let gems = join(readfile('Gemfile'))
    return match(gems, a:gem) != -1
  else
    return 0
  endif
endfunction

function s:SpecCommand()
  let spec_command = 'ruby' . s:LoadPath()

  if s:HasGem('rspec')
    if filereadable('bin/rspec')
      let spec_command = 'bin/rspec --no-color'
    else
      let spec_command = 'bundle exec rspec --no-color'
    endif
  elseif s:HasBundler()
    let spec_command .= ' -rbundler/setup'
  endif

  return spec_command
endfunction

function s:RunSpec()
  write
  exec ':!' . s:SpecCommand() . ' ' . shellescape(s:SpecPath(expand('%')))
endfunction

if !hasmapto('<Plug>RunSpecRun')
  map <unique> <Leader>t <Plug>RunSpecRun
endif

" Expose a single RunSpecRun for mapping.
noremap <unique> <script> <Plug>RunSpecRun <SID>Run
noremap <SID>Run :call <SID>RunSpec()<CR>

" Add a menu item.
noremenu <script> Plugin.Run\ Spec <SID>Run
