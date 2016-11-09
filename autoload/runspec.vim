" Public: The path of the test file relevant to the current path. If this file
" is a test, spec or feature, return that immediately, else go looking for it.
"
" path - The String path of the file whose spec needs to be found.
"
" Returns the String path of the matching spec or 0 if none was found.
function runspec#SpecPath(path)
  let path = 0

  if s:IsNotTest(a:path)
    if isdirectory('spec')
      let path = s:HuntSpec(a:path)
    else
      let path = s:HuntTest(a:path)
    endif

    if string(path) == '0' && isdirectory('features')
      let path = s:HuntFeature(a:path)
    endif
  else
    let path = a:path
  endif

  return path
endfunction

" Public: The path of the target file relevant to the current path. If this
" path is a test or spec, go look for a matching implementation file,
" otherwise return the path unmodified.
"
" path - The String path of the file whose implementation needs to be found.
"
" Returns the String path of the matching implementation file or 0 if none was
" found.
function runspec#TargetPath(path)
  let path = a:path

  if s:IsTest(path)
    let path = s:HuntTarget(path)
  endif

  return path
endfunction

function runspec#TogglePath(path)
  let path = a:path
  if s:IsTest(path)
    let path = runspec#TargetPath(path)
  else
    let path = runspec#SpecPath(path)
  endif
  return path
endfunction

" Public: The appropriate command to run the tests with. If this is a feature,
" try to find the most appropriate Cucumber runner. If an executable exists at
" script/test, prefer that over all others. Failing that, if rspec is present,
" use that (either via Bundler's binstubs or using bundle exec) or fall back
" to calling ruby directly with an appropriate load path.
"
" Examples
"
"   runspec#SpecCommand("foo_spec.rb")
"   # => 'bin/rspec'
"
"   runspec#SpecCommand("foo_spec.rb")
"   # => 'ruby -Ilib -Ispec'
"
"   runspec#SpecCommand("foo.feature")
"   # => 'cucumber'
"
" Returns the String command.
function runspec#SpecCommand(path)
  let spec_command = 'ruby' . s:LoadPath()

  if s:IsFeature(a:path)
    if s:HasGem('cucumber')
      if executable('./bin/cucumber')
        let spec_command = 'bin/cucumber'
      else
        let spec_command = 'bundle exec cucumber'
      endif
    else
      let spec_command = 'cucumber'
    end
  elseif executable('./script/test')
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

" Internal: Attempt to find a test, spec or feature for the given path. Do
" this by first taking the path, replacing the end with a given extension and
" using findfile() to locate it. If it's not found, try stripping directories
" one-by-one from the front of the path until a match is found.
"
" path        - The String path of the file whose spec needs to be found.
" extension   - The String extension to strip from the path
" replacement - The String replacement of the spec (either _spec.rb, _test.rb
"               or .feature) to find.
" search_path - The String path to search
"
" Examples
"
"   s:Hunt('app/models/user.rb', '\.rb$', '_spec.rb', 'spec/**')
"   # => 'spec/models/user_spec.rb'
"
"   s:Hunt('lib/admin/lock.rb', '\.rb$', '_test.rb', 'test/**')
"   # => 'test/lock_test.rb'
"
"   s:Hunt('spec/models/user_spec.rb', '_\(spec\|test\)\.rb$', '.rb', '**')
"   # => 'app/models/user.rb'
"
"   s:Hunt('features/step_definitions/a_steps.rb', '_steps\.rb$', '.feature')
"   # => 'features/a.feature'
"
" Returns the String path of the matching spec or 0 is none was found.
function s:Hunt(path, extension, replacement, search_path)
  let path = substitute(a:path, a:extension, '', '') . a:replacement
  let test_path = findfile(path, a:search_path)

  if !filereadable(test_path)
    let path_components = split(a:path, '/')

    if len(path_components) > 1
      let test_path = s:Hunt(join(path_components[1:-1], '/'), a:extension, a:replacement, a:search_path)
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
  let search_path = '**'

  if isdirectory('spec')
    let search_path = 'spec/**'
  endif

  return s:Hunt(a:path, '\.rb$', '_spec.rb', search_path)
endfunction

" Internal: Attempt to find a test for the given path.
"
" path - The String path of the file whose test needs to be found.
"
" Returns the String path of the matching test or 0 if none was found.
function s:HuntTest(path)
  let search_path = '**'

  if isdirectory('test')
    let search_path = 'test/**'
  endif

  return s:Hunt(a:path, '\.rb$', '_test.rb', search_path)
endfunction

" Internal: Attempt to find a feature for the given path.
"
" path - The String path of the file whose test needs to be found.
"
" Returns the String path of the matching spec or 0 if none was found.
function s:HuntFeature(path)
  let search_path = '**'

  if isdirectory('features')
    let search_path = 'features/**'
  endif

  return s:Hunt(a:path, '_steps\.rb$', '.feature', search_path)
endfunction

" Internal: Attempt to find an implementation file for the given path.
"
" path - The String path of the file whose implementation file needs to be
" found.
"
" Returns the String path of the matching target implementation or 0 if none
" was found.
function s:HuntTarget(path)
  if s:IsFeature(a:path)
    return s:Hunt(a:path, s:test_regex, '_steps.rb', 'features/**')
  else
    return s:Hunt(a:path, s:test_regex, '.rb', '**')
  endif
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

let s:test_regex = '\(_\(spec\|test\)\.rb\|\.feature\)$'

function s:IsNotTest(path)
  return match(a:path, s:test_regex) == -1
endfunction

function s:IsTest(path)
  return !s:IsNotTest(a:path)
endfunction

function s:IsFeature(path)
  return match(a:path, '\.feature$') != -1
endfunction
