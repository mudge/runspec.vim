" Vim global plugin for running specs appropriate to the current file.
" Maintainer: Paul Mucur (http://mudge.name)

if exists('g:loaded_runspec')
  finish
endif
let g:loaded_runspec = 1

" Internal: Attempt to find a test or spec for the given path. Do this by
" first taking the path, replacing the end with a given extension and using
" findfile() to locate it. If it's not found, try stripping directories one-by-one
" from the front of the path until a match is found.
"
" path      - The String path of the file whose spec needs to be found.
" extension - The String extension of the spec (either _spec.rb or _test.rb)
"             to find.
"
" Examples
"
"   s:Hunt('app/models/user.rb', '_spec.rb')
"   # => 'spec/models/user_spec.rb'
"
"   s:Hunt('lib/admin/lock.rb', '_test.rb')
"   # => 'test/lock_test.rb'
"
" Returns the String path of the matching spec or 0 is none was found.
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

" Internal: Attempt to find a spec for the given path.
"
" path - The String path of the file whose spec needs to be found.
"
" Returns the String path of the matching spec or 0 if none was found.
function s:HuntSpec(path)
  return s:Hunt(a:path, '_spec.rb')
endfunction

" Internal: Attempt to find a test for the given path.
"
" path - The String path of the file whose test needs to be found.
"
" Returns the String path of the matching test or 0 if none was found.
function s:HuntTest(path)
  return s:Hunt(a:path, '_test.rb')
endfunction

" Internal: The path of the test file relevant to the current path. If this
" file is a test or spec, return that immediately, else go looking for it.
"
" path - The String path of the file whose spec needs to be found.
"
" Returns the String path of the matching spec or 0 if none was found.
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

" Internal: Any flags that need passing to ruby to set up the load path. Will
" look for lib, spec and test directories and add them as -I flags when
" appropriate.
"
" Examples
"
"   s:LoadPath()
"   # => ' -Ilib -Ispec'
"
" Returns the String flags to be passed to ruby.
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

" Internal: Whether or not Bundler is being used on the current project.
"
" Returns truthy if Gemfile.lock exists, false if not.
function s:HasBundler()
  return filereadable('Gemfile.lock')
endfunction

" Internal: Whether or not a given gem is installed in the current project.
"
" gem - The String gem name to search for.
"
" Examples
"
"   s:HasGem('rspec')
"   # => 40
"
"   s:HasGem('nonesuch')
"   # => 0
"
" Returns a truthy value if the gem is present, false if not.
function s:HasGem(gem)
  if s:HasBundler()
    let gems = join(readfile('Gemfile.lock'))
    return match(gems, '\<' . a:gem . '\>') != -1
  else
    return 0
  endif
endfunction

" Internal: The appropriate command to run the tests with. If rspec is
" present, use that (either via Bundler's binstubs or using bundle exec) or
" fall back to calling ruby directly with an appropriate load path.
"
" Examples
"
"   s:SpecCommand()
"   # => 'bin/rspec --no-color'
"
"   s:SpecCommand()
"   # => 'ruby -Ilib -Ispec'
"
" Returns the String command.
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

" Public: Save the current file and run its specs or tests. If the file is
" already a spec or test, run it using the appropriate command (rspec through
" Bundler, ruby directly, etc.); if not, find the most appropriate spec or
" test and run that.
"
" Returns nothing.
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
