# Squall Parallel

Squall (`squall-parallel`) is an elegant, production-ready parallel execution engine for Ruby, engineered with high cohesion, loose coupling, and strict modularity.

It makes it trivial to run identical blocks of code concurrently across available workers using native Threads, multi-process Forks, or modern Ruby Ractors.

## Key Features

- **Multiple Execution Backends**:
  - `in_threads`: Lightweight concurrency for I/O-bound tasks with fail-fast exception propagation.
  - `in_processes`: Multi-process parallelism using UNIX pipes with automatic fallback to threads on platforms without fork (e.g., Windows) and leak-free resource protection.
  - `in_ractors`: Share-nothing actor parallelism for modern Ruby with automatic fallback on isolation errors.
- **Universal Input Producers**: Works seamlessly with `Array`, `Range`, `Queue`, and `Enumerator::Lazy`.
- **Expressive Enumerable Helpers**: `map`, `each`, `each_with_index`, `flat_map`, `any?`, `all?`.
- **Cooperative Early Termination**: Thread-safe cancellation token (`Squall::Cancellation`) with atomic event callbacks to abort remaining queued jobs immediately.
- **Fail-Fast Error Handling**: Immediate worker cancellation and exception re-raising upon unhandled task errors.
- **Progress Monitoring & ETA**: Built-in real-time percentage completion and rate estimation.
- **Rails & ActiveRecord Connection Safety**: Automatically clears connections before forking and re-establishes connection pools safely.

## Requirements

- Ruby >= 2.5.0 (Ruby 3.0+ for Ractors)
- Rails >= 3.0 (optional, full ActiveRecord connection management supported)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "squall-parallel"
```

## Quick Start Examples

### Map in Threads

```ruby
require "squall"

responses = Squall.map(urls, in_threads: 8) do |url|
  fetch_api(url)
end
```

### CPU-Bound Processing in Processes with Progress

```ruby
results = Squall.map(1..10_000, in_processes: 4, progress: true) do |number|
  calculate_fibonacci(number)
end
```

### Early Exit Detection

```ruby
has_admin = Squall.any?(users, in_threads: 4) do |user|
  user.admin?
end
```

## Architecture

- `Squall::WorkUnit`: Atomic unit of work with payload and original index.
- `Squall::Producers`: Polymorphic stream wrappers (Array, Range, Queue, Lazy).
- `Squall::Executors`: Polymorphic concurrency engines (Thread, Process, Ractor).
- `Squall::Cancellation`: Thread-safe coordination token for early termination.
- `Squall::ProgressMonitor`: Non-blocking progress and ETA evaluator.
- `Squall::RailsAdapter`: Thread and process isolation for ActiveRecord pools.

## License

MIT License. See LICENSE file for details.
