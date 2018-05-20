# frozen_string_literal: true

require_relative "lib/squall/version"

Gem::Specification.new do |spec|
  spec.name          = "squall-parallel"
  spec.version       = "1.0.0"
  spec.authors       = ["Wesley Lima"]
  spec.email         = ["wesleyskap@gmail.com"]
  spec.summary       = "Parallel execution engine for Ruby 2.3 and Rails 5"
  spec.description   = "Run blocks in parallel with threads or processes. Supports progress monitoring and early exit."
  spec.homepage      = "https://github.com/wesleyskap/squall-parallel"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.3.0"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
end
