Gem::Specification.new do |spec|
  spec.name          = "squall-parallel"
  spec.version       = "0.9.0"
  spec.authors       = ["Wesley Lima"]
  spec.email         = ["wesleyskap@gmail.com"]
  spec.summary       = "Parallel execution engine for Ruby 2.0 and Rails 4"
  spec.description   = "Run parallel blocks using threads, queues or processes with ActiveRecord 4 connection safety."
  spec.homepage      = "https://github.com/wesleyskap/squall-parallel"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.0.0"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
end
