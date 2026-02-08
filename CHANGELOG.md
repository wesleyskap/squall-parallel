# Changelog

All notable changes to the Squall Parallel gem are documented in this file.
The format is based on Keep a Changelog and adheres to Semantic Versioning.

## [2.0.0] - 2026-03-08

### Added
- Complete modern rewrite with support for Ruby 3.4 and Rails 8.0.
- Squall::Executors::RactorExecutor for true share-nothing multi-core parallelism.
- Squall::Producers::LazyProducer for zero-overhead streaming of infinite or lazy collections.
- Squall::Cancellation token for thread-safe early exit on any? and all?.
- Squall::ProgressMonitor with live ETA and percentage calculations.
- Squall::RailsAdapter supporting multi-database connection recovery post-fork.
- CLI runner bin/squall for command-line benchmarking and batching.

## [1.5.0] - 2022-11-14

### Added
- Rails 7 connection handler cleanup hooks.
- Ractor experimental prototype support for Ruby 3.0+.
- Enhanced error handling with Squall::WorkerCrashError.

## [1.0.0] - 2018-05-20

### Added
- Initial production release for Ruby 2.3 and Rails 5.
- Multi-process fork execution via IO.pipe.
- Native thread worker pool with Thread::Queue.
- Core enumerable helpers: map, each, flat_map, any?, all?.
