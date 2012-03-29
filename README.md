runspec.vim
===========

A simple Vim plugin to run specs: if the current file ends in `_spec.rb`, run it; if not, guess where the associated spec file is and run that.

The plugin will attempt to automatically discover whether you are using [RSpec](https://www.relishapp.com/rspec) or [minitest/spec](http://docs.seattlerb.org/minitest/MiniTest/Spec.html) and use [Bundler](http://gembundler.com/) (and binstubs) if appropriate.

Installation
------------

I recommend using [Vundle](https://github.com/gmarik/vundle) and then you can install the plugin by simply adding the following line to your `.vimrc`:

```vim
Bundle 'mudge/runspec.vim'
```

Usage
-----

By default, the plugin will bind to `<Leader>t` but you can manually map to `<Plug>RunSpecRun` like so:

```vim
map <Leader>r <Plug>RunSpecRun
```
