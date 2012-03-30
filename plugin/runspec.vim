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

" Attempt to find a test or spec for the given path.
" First take the path, replace the end with a given extension and use findfile() to
" locate it. If it's not found, try stripping directories one-by-one from the
" front of the path until a match is found.
function s:Hunt(path, extension)
  let path = substitute(a:path, '\.rb$', a:extension, '')
  let test_path = findfile(path, '**')

  if !filereadable(test_path)
    let path_components = split(a:path, '/')

    if len(path_components) > 1
      let test_path = s:Hunt(join(path_components[1:-1], '/'), a:extension)
    else
      let test_path = 0
    endif
  endif

  return test_path
endfunction

function s:HuntSpec(path)
  return s:Hunt(a:path, '_spec.rb')
endfunction

function s:HuntTest(path)
  return s:Hunt(a:path, '_test.rb')
endfunction

function s:SpecPath(path)
  let path = a:path

  if match(path, '_\(spec\|test\)\.rb$') == -1
    if isdirectory('spec')
      let path = s:HuntSpec(path)
    else
      let path = s:HuntTest(path)
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
    if executable('./bin/rspec')
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
  let path = s:SpecPath(expand('%'))

  " If path is a String...
  if type(path) == 1
    exec ':!' . s:SpecCommand() . ' ' . shellescape(path)
  else
    echo 'No matching spec or test found.'
  endif
endfunction

if !hasmapto('<Plug>RunSpecRun') && mapcheck('<Leader>t') == ''
  map <unique> <Leader>t <Plug>RunSpecRun
endif

" Expose a single RunSpecRun for mapping.
noremap <unique> <script> <Plug>RunSpecRun <SID>Run
noremap <SID>Run :call <SID>RunSpec()<CR>

" Add a menu item.
noremenu <script> Plugin.Run\ Spec <SID>Run
