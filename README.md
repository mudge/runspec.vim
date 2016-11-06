runspec.vim [![Build Status](https://secure.travis-ci.org/mudge/runspec.vim.png)](http://travis-ci.org/mudge/runspec.vim)
===========

A simple Vim plugin to run specs: if the current file ends in `_spec.rb`,
`_test.rb` or `.feature`, run it; if not, guess where the associated spec file
is and run that. It also includes a function for toggling between a test file
and the associated implementation file.

The plugin will attempt to automatically discover whether you are using
[RSpec](https://www.relishapp.com/rspec),
[minitest/spec](http://docs.seattlerb.org/minitest/MiniTest/Spec.html) or
[Cucumber](https://cucumber.io/) and use [Bundler](http://gembundler.com/) (and
binstubs) if appropriate.

Installation
------------

I recommend using [Vundle](https://github.com/gmarik/vundle) and then you can
install the plugin by simply adding the following line to your `.vimrc`:

```vim
Bundle 'mudge/runspec.vim'
```

Usage
-----

By default, the plugin will bind to `<Leader>t` if it is not already mapped but
you can manually map to `<Plug>RunSpecRun` like so:

```vim
map <Leader>r <Plug>RunSpecRun
```

You can override the automatic detection of the appropriate spec runner (e.g.
`rspec` or `ruby`) by having an executable `script/test` that accepts a spec
file as an argument. Note that features will always run with `cucumber`.

To toggle between having a test file open and the corresponding
implementation file, you can map a keybinding to
`<Plug>RunSpecToggle`, like so:

```vim
map <Leader>s <Plug>RunSpecToggle
```

Dependencies
------------

In order to detect custom test runners accurately, the plugin requires that you are
using Bundler and have a valid `Gemfile.lock` (so that it can work with
`Gemfile`s that only specify `gemspec`).

If you are not using any gems (e.g. you are using only Ruby's built-in testing
libraries) then you should not be affected as the plugin will default to using
`ruby` as your test runner.

Contributions
-------------

Thanks to [William Roe](https://github.com/wjlroe) for contributing the toggle
functionality.

License
-------

Copyright © 2015-2016 Paul Mucur

Distributed under the MIT License.
