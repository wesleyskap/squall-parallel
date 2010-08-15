Gem::Specification.new do |spec|
  spec.name          = "squall-parallel"
  spec.version       = "0.1.0"
  spec.authors       = ["Wesley Lima"]
  spec.email         = ["wesleyskap@gmail.com"]
  spec.summary       = "Lightweight parallel runner for Ruby 1.9"
  spec.description   = "Run parallel blocks using threads or processes with Rails 3 connection safety."
  spec.homepage      = "https://github.com/wesleyskap/squall-parallel"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 1.9.2"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
end
