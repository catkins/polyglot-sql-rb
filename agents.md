# agents.md — polyglot-rb

## Project Overview

Ruby bindings for [polyglot-sql](https://github.com/tobilg/polyglot), a Rust-based SQL transpiler supporting 30+ database dialects. Built with [Magnus](https://github.com/matsadler/magnus) for Rust ↔ Ruby FFI via native extensions.

## Architecture

Two-layer architecture following the `catkins/monty-rb` and `catkins/slatedb-rb` patterns:

### Rust Layer (`ext/polyglot_rb/src/`)

- `lib.rs` — Magnus init entry point, registers module-level functions with underscore prefixes (`_transpile`, `_parse`, etc.)
- `dialect.rs` — Maps Ruby string/symbol dialect names to `polyglot_sql::dialects::DialectType` enum values
- `errors.rs` — Defines Ruby exception hierarchy (`Polyglot::Error`, `ParseError`, `GenerateError`, `UnsupportedError`) using thread-local storage pattern

### Ruby Layer (`lib/`)

- `lib/polyglot.rb` — Main entry point, loads native extension, defines idiomatic Ruby API with keyword arguments
- `lib/polyglot/version.rb` — Gem version constant
- `lib/polyglot/validation_result.rb` — `ValidationResult` and `ValidationError` wrapper classes

### Key Design Decisions

- **JSON bridge for AST**: The `Expression` AST type (600+ variants) is serialized to/from JSON via `serde_json`. Ruby receives `Hash`/`Array` representations. This avoids mapping hundreds of Rust enum variants to Ruby classes.
- **Keyword arguments**: Ruby methods use keyword args (`from:`, `to:`, `dialect:`) while Rust methods use positional args with underscore prefixes.
- **Symbol/string dialect names**: Both `:postgres` and `"postgres"` are accepted; normalized via `.to_s` in Ruby and case-insensitive matching in Rust.

## Build & Test

```bash
# Install dependencies
bundle install

# Compile native extension + run tests
bundle exec rake

# Just compile
bundle exec rake compile

# Just run tests
bundle exec rake spec

# Lint
bundle exec standardrb

# Lint with auto-fix
bundle exec standardrb --fix
```

## Adding New Features

1. Add Rust function in `ext/polyglot_rb/src/lib.rs`
2. Register it with `module.define_singleton_method("_method_name", function!(method, N))?;`
3. Add Ruby wrapper in `lib/polyglot.rb` with keyword arguments and documentation
4. Add RSpec tests in `spec/`
5. Run `bundle exec rake` to compile and test

## Dependencies

- **polyglot-sql** — Core Rust SQL transpiler crate
- **magnus** — Rust ↔ Ruby FFI bridge
- **rb-sys** — Ruby native extension build system
- **serde_json** — JSON serialization for AST interchange

## Testing

- **RSpec** for Ruby-level tests (`spec/`)
- **StandardRB** for Ruby linting
- Tests cover: transpilation, parsing, generation, formatting, validation, error handling, dialect support
