runspec.vim
===========

A simple Vim plugin to run specs: if the current file ends in `_spec.rb`, run it; if not, guess where the associated spec file is and run that.

The plugin will attempt to automatically discover whether you are using RSpec or minitest/spec and use Bundler (and binstubs) if appropriate.
