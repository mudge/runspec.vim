require 'tmpdir'
require 'fileutils'
require 'vimrunner'

VIM = Vimrunner::Runner.start_gvim
VIM.add_plugin(File.expand_path('../..', __FILE__), 'plugin/runspec.vim')

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

  config.before do
    VIM.command("cd #{FileUtils.getwd}")
  end

  config.after(:suite) do
    VIM.kill
  end
end

