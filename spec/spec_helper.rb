require 'tmpdir'
require 'fileutils'
require 'vimrunner'

VIM = Vimrunner::Runner.start_gvim
VIM.add_plugin(File.expand_path('../..', __FILE__), 'plugin/runspec.vim')

RSpec.configure do |config|

  # cd into a temporary directory for every example.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end

  config.before do
    VIM.command("cd #{FileUtils.getwd}")
  end

  config.after(:suite) do
    VIM.kill
  end
end

