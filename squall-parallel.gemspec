# frozen_string_literal: true

require_relative "lib/squall/version"

Gem::Specification.new do |spec|
  spec.name          = "squall-parallel"
  spec.version       = "1.5.0"
  spec.authors       = ["Wesley Lima"]
  spec.email         = ["wesleyskap@gmail.com"]
  spec.summary       = "Parallel execution engine with Ruby 3 Ractors and Rails 7 support"
  spec.description   = "Run blocks in parallel with threads, processes or ractors."
  spec.homepage      = "https://github.com/wesleyskap/squall-parallel"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
end
