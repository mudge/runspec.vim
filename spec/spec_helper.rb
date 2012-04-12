require 'tmpdir'
require 'fileutils'
require 'vimrunner'

def vim
  @vim ||= Vimrunner::Runner.start_vim
end

RSpec.configure do |config|

  config.before do
    vim.add_plugin(File.expand_path('../..', __FILE__), 'plugin/runspec.vim')
  end

  # cd into a temporary directory for every example.
  config.around do |example|
    original_dir = FileUtils.getwd
    Dir.mktmpdir do |tmp_dir|
      FileUtils.cd(tmp_dir)
      example.call
    end
    FileUtils.cd(original_dir)
  end

  config.after do
    @vim.kill if @vim
  end
end

