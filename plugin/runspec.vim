" If the current file is a spec, run it; if not, guess where the spec file is
" and run that.
"
" e.g.
"   spec/models/person_spec.rb => bin/rspec --no-color spec/models/person_spec.rb
"   lib/something.rb => bin/rspec --no-color spec/lib/something_spec.rb
"   app/models/person.rb => bin/rspec --no-color spec/models/person_spec.rb

if exists("g:loaded_runspec")
  finish
endif
let g:loaded_runspec = 1

function s:SpecPath(path)
  if match(a:path, '_\(spec\|test\)\.rb$') != -1
    return a:path
  else
    let spec_path = substitute(a:path, '\.rb$', '_spec.rb', '')

    if match(spec_path, '^app/') != -1
      let spec_path = substitute(spec_path, '^app/', '', '')
    endif

    return 'spec/' . spec_path
  endif
endfunction

function s:LoadPath()
  if isdirectory('spec')
    return ' -Ispec'
  elseif isdirectory('test')
    return ' -Itest'
  else
    return ''
  endif
endfunction

function s:SpecCommand()
  if filereadable('Gemfile')
    let gems = join(readfile('Gemfile'))
    if match(gems, 'rspec') != -1
      if filereadable('bin/rspec')
        return 'bin/rspec --no-color'
      else
        return 'bundle exec rspec --no-color'
      endif
    else
      return 'ruby' . s:LoadPath() . ' -rbundler/setup'
    endif
  else
    return 'ruby' . s:LoadPath()
  endif
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
