require "spec_helper"

describe "runspec.vim" do
  def runspec(command)
    vim.command("echo runspec##{command}")
  end

  describe "#SpecPath" do
    it "returns the current path if it ends in _spec.rb" do
      runspec('SpecPath("foo_spec.rb")').should == "foo_spec.rb"
      runspec('SpecPath("bar/foo_spec.rb")').should == "bar/foo_spec.rb"
    end

    it "returns the current path if it ends in _test.rb" do
      runspec('SpecPath("foo_test.rb")').should == "foo_test.rb"
      runspec('SpecPath("bar/foo_test.rb")').should == "bar/foo_test.rb"
    end

    context "with a spec directory" do
      before do
        FileUtils.mkdir("spec")
      end

      it "finds a spec with the same name" do
        FileUtils.touch("spec/foo_spec.rb")
        runspec('SpecPath("foo.rb")').should == "spec/foo_spec.rb"
      end

      it "finds a spec with the most similar name" do
        FileUtils.mkdir("spec/models")
        FileUtils.touch("spec/models/user_spec.rb")
        runspec('SpecPath("app/models/user.rb")').should == "spec/models/user_spec.rb"
      end

      it "finds a spec even if the file doesn't end in .rb" do
        FileUtils.touch("spec/runspec.vim_spec.rb")
        runspec('SpecPath("autoload/runspec.vim")').should == "spec/runspec.vim_spec.rb"
      end
    end

    context "with a test directory" do
      before do
        FileUtils.mkdir("test")
      end

      it "finds a test with the same name" do
        FileUtils.touch("test/foo_test.rb")
        runspec('SpecPath("foo.rb")').should == "test/foo_test.rb"
      end

      it "finds a test with the most similar name" do
        FileUtils.mkdir("test/unit")
        FileUtils.touch("test/unit/user_test.rb")
        runspec('SpecPath("app/models/user.rb")').should == "test/unit/user_test.rb"
      end
    end
  end

  describe "#SpecCommand" do
    context "with no Gemfile.lock" do
      it "returns a plain ruby command" do
        runspec('SpecCommand()').should == "ruby"
      end

      it "includes lib on the load path if present" do
        FileUtils.mkdir("lib")
        runspec('SpecCommand()').should == "ruby -Ilib"
      end

      it "includes spec on the load path if present" do
        FileUtils.mkdir("spec")
        runspec('SpecCommand()').should == "ruby -Ispec"
      end

      it "includes test on the load path if present" do
        FileUtils.mkdir("test")
        runspec('SpecCommand()').should == "ruby -Itest"
      end
    end

    context "with a Gemfile.lock" do
      context "with RSpec" do
        before do
          File.open("Gemfile.lock", "w") do |f|
            f.puts(<<-EOF)
GEM
  remote: https://rubygems.org/
  specs:
    diff-lcs (1.1.3)
    rake (0.9.2.2)
    rspec (2.9.0)
      rspec-core (~> 2.9.0)
      rspec-expectations (~> 2.9.0)
      rspec-mocks (~> 2.9.0)
    rspec-core (2.9.0)
    rspec-expectations (2.9.1)
      diff-lcs (~> 1.1.3)
    rspec-mocks (2.9.0)

PLATFORMS
  ruby

DEPENDENCIES
  rake
  rspec
            EOF
          end
        end

        context "and binstubs" do
          before do
            FileUtils.mkdir("bin")
            FileUtils.touch("bin/rspec")
            FileUtils.chmod(0755, "bin/rspec")
          end

          it "returns bin/rspec" do
            runspec('SpecCommand()').should == "bin/rspec --no-color"
          end
        end

        context "and no binstubs" do
          it "returns bundle exec rspec" do
            runspec('SpecCommand()').should == "bundle exec rspec --no-color"
          end
        end
      end

      context "without RSpec" do
        before do
          FileUtils.touch("Gemfile.lock")
        end

        it "returns ruby with Bundler included" do
          runspec('SpecCommand()').should == "ruby -rbundler/setup"
        end
      end
    end
  end
end
