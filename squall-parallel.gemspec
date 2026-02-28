# frozen_string_literal: true

require_relative "lib/squall/version"

Gem::Specification.new do |spec|
  spec.name          = "squall-parallel"
  spec.version       = Squall::VERSION
  spec.authors       = ["Wesley Lima"]
  spec.email         = ["wesleyskap@gmail.com"]

  spec.summary       = "Elegant and robust parallel execution engine for Ruby"
  spec.description   = "Run blocks in parallel with threads, processes or ractors. Supports arrays, ranges, queues and lazy producers with Rails connection safety."
  spec.homepage      = "https://github.com/wesleyskap/squall-parallel"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.files = Dir["lib/**/*.rb", "bin/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.bindir = "bin"
  spec.executables = ["squall"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 12.0"
  spec.add_development_dependency "rspec", "~> 3.12"
end
