require 'tmpdir'
require 'vimrunner'

VIM = Vimrunner.start_gui_vim
VIM.add_plugin(File.expand_path('../..', __FILE__), 'plugin/runspec.vim')

RSpec.configure do |config|

  # cd into a temporary directory for every example.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        VIM.command("cd #{dir}")
        example.call
      end
    end
  end

  config.after(:suite) do
    VIM.kill
  end
end

