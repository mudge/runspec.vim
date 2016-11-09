RSpec.describe "runspec.vim" do
  def runspec(command)
    VIM.command("echo runspec##{command}")
  end

  def touch(filepath)
    FileUtils.mkdir_p(File.dirname(filepath))
    FileUtils.touch(filepath)
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

    it "returns the current path if it ends in .feature" do
      expect(runspec('SpecPath("foo.feature")')).to eq("foo.feature")
      expect(runspec('SpecPath("bar/foo.feature")')).to eq("bar/foo.feature")
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

      context "and a features directory" do
        before do
          FileUtils.mkdir("features")
        end

        it "finds a spec with the same name" do
          FileUtils.touch("spec/foo_spec.rb")
          expect(runspec('SpecPath("foo.rb")')).to eq("spec/foo_spec.rb")
        end

        it "finds a feature with the same prefix" do
          touch("features/foo.feature")
          touch("features/step_definitions/foo_steps.rb")
          expect(runspec('SpecPath("features/step_definitions/foo_steps.rb")')).to eq("features/foo.feature")
        end

        it "finds a feature with the most similar name" do
          touch("features/users/foo.feature")
          touch("features/step_definitions/user/foo_steps.rb")
          expect(runspec('SpecPath("features/step_definitions/user/foo_steps.rb")')).to eq("features/users/foo.feature")
        end
      end
    end

    context "with a test directory" do
      before do
        FileUtils.mkdir("test")
      end

      it "finds a test with the same name" do
        touch("test/foo_test.rb")
        touch("foo.rb")
        expect(runspec('SpecPath("foo.rb")')).to eq("test/foo_test.rb")
      end

      it "finds a test with the most similar name" do
        touch("app/models/user.rb")
        touch("test/unit/user_test.rb")
        expect(runspec('SpecPath("app/models/user.rb")')).to eq("test/unit/user_test.rb")
      end

      it "finds a test from a lib directory" do
        touch("lib/app_name/something.rb")
        touch("test/app_name/something_test.rb")
        expect(runspec('SpecPath("lib/app_name/something.rb")')).to eq("test/app_name/something_test.rb")
      end

      context "and a features directory" do
        before do
          FileUtils.mkdir("features")
        end

        it "finds a test with the same name" do
          touch("test/foo_test.rb")
          touch("foo.rb")
          expect(runspec('SpecPath("foo.rb")')).to eq("test/foo_test.rb")
        end

        it "finds a feature with the same prefix" do
          touch("features/foo.feature")
          touch("features/step_definitions/foo_steps.rb")
          expect(runspec('SpecPath("features/step_definitions/foo_steps.rb")')).to eq("features/foo.feature")
        end

        it "finds a feature with the most similar name" do
          touch("features/users/foo.feature")
          touch("features/step_definitions/user/foo_steps.rb")
          expect(runspec('SpecPath("features/step_definitions/user/foo_steps.rb")')).to eq("features/users/foo.feature")
        end
      end
    end

    context "with a features directory" do
      before do
        FileUtils.mkdir("features")
      end

      it "finds a feature with the same prefix" do
        touch("features/foo.feature")
        touch("features/step_definitions/foo_steps.rb")
        expect(runspec('SpecPath("features/step_definitions/foo_steps.rb")')).to eq("features/foo.feature")
      end

      it "finds a feature with the most similar name" do
        touch("features/users/foo.feature")
        touch("features/step_definitions/user/foo_steps.rb")
        expect(runspec('SpecPath("features/step_definitions/user/foo_steps.rb")')).to eq("features/users/foo.feature")
      end
    end
  end

  describe "#TargetPath" do
    it "returns the current path if it doesn't contain _spec or _test" do
      expect(runspec('TargetPath("foo.rb")')).to eq("foo.rb")
      expect(runspec('TargetPath("bar/foo.rb")')).to eq("bar/foo.rb")
    end

    context "with a spec directory" do
      it "finds a target with the same name" do
        touch("foo.rb")
        expect(runspec('TargetPath("spec/foo_spec.rb")')).to eq("foo.rb")
      end

      it "finds a target with the most similar name" do
        touch("app/models/user.rb")
        expect(runspec('TargetPath("spec/models/user_spec.rb")')).to eq("app/models/user.rb")
      end
    end

    context "with a test directory" do
      it "finds a target with the same name" do
        touch("foo.rb")
        expect(runspec('TargetPath("test/foo_test.rb")')).to eq("foo.rb")
      end

      it "finds a target with the most similar name" do
        touch("app/models/user.rb")
        touch("test/unit/user_test.rb")
        expect(runspec('TargetPath("test/unit/user_test.rb")')).to eq("app/models/user.rb")
      end
    end

    context "with a features directory" do
      it "finds a target with the same name" do
        touch("features/step_definitions/foo_steps.rb")
        expect(runspec('TargetPath("features/foo.feature")')).to eq("features/step_definitions/foo_steps.rb")
      end
    end
  end

  describe "#SpecCommand" do
    context "with no Gemfile.lock" do
      it "uses script/test if it exists" do
        FileUtils.mkdir("script")
        FileUtils.touch("script/test")
        FileUtils.chmod(0755, "script/test")
        expect(runspec('SpecCommand("foo_test.rb")')).to eq("script/test")
      end

      it "returns a plain ruby command" do
        expect(runspec('SpecCommand("foo_test.rb")')).to eq("ruby")
      end

      it "includes lib on the load path if present" do
        FileUtils.mkdir("lib")
        expect(runspec('SpecCommand("foo_test.rb")')).to eq("ruby -Ilib")
      end

      it "includes spec on the load path if present" do
        FileUtils.mkdir("spec")
        expect(runspec('SpecCommand("foo_spec.rb")')).to eq("ruby -Ispec")
      end

      it "includes test on the load path if present" do
        FileUtils.mkdir("test")
        expect(runspec('SpecCommand("foo_test.rb")')).to eq("ruby -Itest")
      end

      it "uses cucumber for features" do
        expect(runspec('SpecCommand("foo.feature")')).to eq("cucumber")
      end
    end

    context "with a Gemfile.lock" do
      context "with Cucumber" do
        before do
          File.open("Gemfile.lock", "w") do |f|
            f.puts(<<-EOF)
GEM
  remote: https://rubygems.org/
  specs:
    builder (3.2.2)
    cucumber (2.4.0)
      builder (>= 2.1.2)
      cucumber-core (~> 1.5.0)
      cucumber-wire (~> 0.0.1)
      diff-lcs (>= 1.1.3)
      gherkin (~> 4.0)
      multi_json (>= 1.7.5, < 2.0)
      multi_test (>= 0.1.2)
    cucumber-core (1.5.0)
      gherkin (~> 4.0)
    cucumber-wire (0.0.1)
    diff-lcs (1.2.5)
    gherkin (4.0.0)
    multi_json (1.12.1)
    multi_test (0.1.2)

PLATFORMS
  ruby

DEPENDENCIES
  cucumber

BUNDLED WITH
   1.13.6
           EOF
          end
        end

        context "and binstubs" do
          before do
            FileUtils.mkdir("bin")
            FileUtils.touch("bin/cucumber")
            FileUtils.chmod(0755, "bin/cucumber")
          end

          it "returns bin/cucumber" do
            expect(runspec('SpecCommand("foo.feature")')).to eq("bin/cucumber")
          end
        end

        context "and no binstubs" do
          it "returns bundle exec cucumber" do
            expect(runspec('SpecCommand("foo.feature")')).to eq("bundle exec cucumber")
          end
        end
      end

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
            expect(runspec('SpecCommand("foo_spec.rb")')).to eq("script/test")
          end

          it "returns bin/rspec" do
            expect(runspec('SpecCommand("foo_spec.rb")')).to eq("bin/rspec")
          end
        end

        context "and no binstubs" do
          it "uses script/test if it exists" do
            FileUtils.mkdir("script")
            FileUtils.touch("script/test")
            FileUtils.chmod(0755, "script/test")
            expect(runspec('SpecCommand("foo_spec.rb")')).to eq("script/test")
          end

          it "returns bundle exec rspec" do
            expect(runspec('SpecCommand("foo_spec.rb")')).to eq("bundle exec rspec")
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
          expect(runspec('SpecCommand("foo_spec.rb")')).to eq("script/test")
        end

        it "returns ruby with Bundler included" do
          expect(runspec('SpecCommand("foo_spec.rb")')).to eq("ruby -rbundler/setup")
        end
      end
    end
  end
end
