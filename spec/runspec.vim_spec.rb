RSpec.describe "runspec.vim" do
  def runspec(command)
    VIM.command("echo runspec##{command}")
  end

  describe "#SpecPath" do
    it "returns the current path if it ends in _spec.rb" do
      expect(runspec('SpecPath("foo_spec.rb")')).to eq("foo_spec.rb")
      expect(runspec('SpecPath("bar/foo_spec.rb")')).to eq("bar/foo_spec.rb")
    end

    it "returns the current path if it ends in _test.rb" do
      expect(runspec('SpecPath("foo_test.rb")')).to eq("foo_test.rb")
      expect(runspec('SpecPath("bar/foo_test.rb")')).to eq("bar/foo_test.rb")
    end

    context "with a spec directory" do
      before do
        FileUtils.mkdir("spec")
      end

      it "finds a spec with the same name" do
        FileUtils.touch("spec/foo_spec.rb")
        expect(runspec('SpecPath("foo.rb")')).to eq("spec/foo_spec.rb")
      end

      it "finds a spec with the most similar name" do
        FileUtils.mkdir("spec/models")
        FileUtils.touch("spec/models/user_spec.rb")
        expect(runspec('SpecPath("app/models/user.rb")')).to eq("spec/models/user_spec.rb")
      end

      it "finds a spec even if the file doesn't end in .rb" do
        FileUtils.touch("spec/runspec.vim_spec.rb")
        expect(runspec('SpecPath("autoload/runspec.vim")')).to eq("spec/runspec.vim_spec.rb")
      end
    end

    context "with a test directory" do
      before do
        FileUtils.mkdir("test")
      end

      it "finds a test with the same name" do
        FileUtils.touch("test/foo_test.rb")
        expect(runspec('SpecPath("foo.rb")')).to eq("test/foo_test.rb")
      end

      it "finds a test with the most similar name" do
        FileUtils.mkdir("test/unit")
        FileUtils.touch("test/unit/user_test.rb")
        expect(runspec('SpecPath("app/models/user.rb")')).to eq("test/unit/user_test.rb")
      end
    end
  end

  describe "#SpecCommand" do
    context "with no Gemfile.lock" do
      it "uses script/test if it exists" do
        FileUtils.mkdir("script")
        FileUtils.touch("script/test")
        FileUtils.chmod(0755, "script/test")
        expect(runspec('SpecCommand()')).to eq("script/test")
      end

      it "returns a plain ruby command" do
        expect(runspec('SpecCommand()')).to eq("ruby")
      end

      it "includes lib on the load path if present" do
        FileUtils.mkdir("lib")
        expect(runspec('SpecCommand()')).to eq("ruby -Ilib")
      end

      it "includes spec on the load path if present" do
        FileUtils.mkdir("spec")
        expect(runspec('SpecCommand()')).to eq("ruby -Ispec")
      end

      it "includes test on the load path if present" do
        FileUtils.mkdir("test")
        expect(runspec('SpecCommand()')).to eq("ruby -Itest")
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

          it "uses script/test if it exists" do
            FileUtils.mkdir("script")
            FileUtils.touch("script/test")
            FileUtils.chmod(0755, "script/test")
            expect(runspec('SpecCommand()')).to eq("script/test")
          end

          it "returns bin/rspec" do
            expect(runspec('SpecCommand()')).to eq("bin/rspec")
          end
        end

        context "and no binstubs" do
          it "uses script/test if it exists" do
            FileUtils.mkdir("script")
            FileUtils.touch("script/test")
            FileUtils.chmod(0755, "script/test")
            expect(runspec('SpecCommand()')).to eq("script/test")
          end

          it "returns bundle exec rspec" do
            expect(runspec('SpecCommand()')).to eq("bundle exec rspec")
          end
        end
      end

      context "without RSpec" do
        before do
          FileUtils.touch("Gemfile.lock")
        end

        it "uses script/test if it exists" do
          FileUtils.mkdir("script")
          FileUtils.touch("script/test")
          FileUtils.chmod(0755, "script/test")
          expect(runspec('SpecCommand()')).to eq("script/test")
        end

        it "returns ruby with Bundler included" do
          expect(runspec('SpecCommand()')).to eq("ruby -rbundler/setup")
        end
      end
    end
  end
end
