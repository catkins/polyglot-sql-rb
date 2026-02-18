# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rb_sys/extensiontask"

RSpec::Core::RakeTask.new(:spec)

GEMSPEC = Gem::Specification.load("polyglot-sql.gemspec")

RbSys::ExtensionTask.new("polyglot_rb", GEMSPEC) do |ext|
  ext.lib_dir = "lib/polyglot"
  ext.ext_dir = "ext/polyglot_rb"
end

task default: %i[compile spec]
task test: :spec
