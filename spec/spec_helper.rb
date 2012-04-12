require 'tmpdir'
require 'fileutils'
require 'vimrunner'

RSpec.configure do |config|

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

def vim
  @vim ||= Vimrunner::Runner.start_vim
end
