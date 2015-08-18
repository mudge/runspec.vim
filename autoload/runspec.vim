" Public: The path of the test file relevant to the current path. If this
" file is a test or spec, return that immediately, else go looking for it.
"
" path - The String path of the file whose spec needs to be found.
"
" Returns the String path of the matching spec or 0 if none was found.
function runspec#SpecPath(path)
  let path = a:path

  if s:IsNotTest(path)
    if isdirectory('spec')
      let path = s:HuntSpec(path)
    else
      let path = s:HuntTest(path)
    endif
  endif

  return path
endfunction

" Public: The appropriate command to run the tests with. If an executable
" exists at script/test, prefer that over all others. Failing that, if rspec
" is present, use that (either via Bundler's binstubs or using bundle exec) or
" fall back to calling ruby directly with an appropriate load path.
"
" Examples
"
"   runspec#SpecCommand()
"   # => 'bin/rspec'
"
"   runspec#SpecCommand()
"   # => 'ruby -Ilib -Ispec'
"
" Returns the String command.
function runspec#SpecCommand()
  let spec_command = 'ruby' . s:LoadPath()

  if executable('./script/test')
    let spec_command = 'script/test'
  elseif s:HasGem('rspec')
    if executable('./bin/rspec')
      let spec_command = 'bin/rspec'
    else
      let spec_command = 'bundle exec rspec'
    endif
  elseif s:HasBundler()
    let spec_command .= ' -rbundler/setup'
  endif

  return spec_command
endfunction

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
  let path = substitute(a:path, '\.rb$', '', '') . a:extension
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

let s:test_regex = '_\(spec\|test\)\.rb$'

function s:IsNotTest(path)
  return match(a:path, s:test_regex) == -1
endfunction

function s:IsTest(path)
  return !s:IsNotTest(a:path)
endfunction
