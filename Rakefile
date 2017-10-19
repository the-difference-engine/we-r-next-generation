# Rakefile

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ["lib", "spec"]
  t.name = "spec"
  # t.warning = true
  # t.verbose = true
  t.test_files = FileList['spec/**/*_spec.rb']
end

Rake::TestTask.new do |t|
  t.libs = ["lib", "spec"]
  t.name = "spec:e2e"
  t.test_files = FileList['spec/e2e/**/*_spec.rb']
end

Rake::TestTask.new do |t|
  t.libs = ["lib", "spec"]
  t.name = "spec:units"
  t.test_files = FileList['spec/unit/**/*_spec.rb']
end

task :default => :spec
