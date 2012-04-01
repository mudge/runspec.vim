runspec.vim
===========

A simple Vim plugin to run specs: if the current file ends in `_spec.rb` or
`_test.rb`, run it; if not, guess where the associated spec file is and run
that.

The plugin will attempt to automatically discover whether you are using
[RSpec](https://www.relishapp.com/rspec) or
[minitest/spec](http://docs.seattlerb.org/minitest/MiniTest/Spec.html) and use
[Bundler](http://gembundler.com/) (and binstubs) if appropriate.

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

Dependencies
------------

In order to detect custom test runners accurately, the plugin requires that you are
using Bundler and have a valid `Gemfile.lock` (so that it can work with
`Gemfile`s that only specify `gemspec`).

If you are not using any gems (e.g. you are using only Ruby's built-in testing
libraries) then you should not be affected as the plugin will default to using
`ruby` as your test runner.
