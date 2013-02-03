require "rake"
require "bundler"

Bundler::GemHelper.install_tasks

Bundler.require

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:rspec)

namespace :rcov do
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rcov = true
    t.rcov_opts = [%{--exclude "spec/*,gems/*"}]
  end
end

task :default => [:rspec]
