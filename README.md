# Squall Parallel

Squall is a lightweight parallel execution library for Ruby 1.9.2+.

It allows running blocks in parallel across multiple worker processes (via fork) or native threads.

## Requirements

- Ruby >= 1.9.2
- Rails >= 3.0 (optional)

## Installation

Add to Gemfile:
```ruby
gem 'squall-parallel', '~> 0.1.0'
```

## Basic Usage

```ruby
require 'squall'

results = Squall.map([1, 2, 3, 4], :in_threads => 2) do |x|
  x * 10
end
```

## Multi-Process Forking
Squall can use multi-process forks to bypass the MRI Global VM Lock for CPU tasks:
```ruby
Squall.map(1..100, :in_processes => 4) { |n| n ** 2 }
```
