# polyglot-sql

[![Build status](https://badge.buildkite.com/e9b6acd7cb9addaa60ca20a96e74f3934285e9ccbd969358f2.svg)](https://buildkite.com/catkins-test/polyglot-sql-rb)

Ruby bindings for [polyglot-sql](https://github.com/tobilg/polyglot) — a Rust-based SQL transpiler supporting 30+ database dialects.

## Installation

Add to your Gemfile:

```ruby
gem "polyglot-sql"
```

Requires Rust toolchain for compilation. Install via [rustup](https://rustup.rs/).

## Usage

### Transpile SQL Between Dialects

```ruby
require "polyglot"

# PostgreSQL to MySQL
Polyglot.transpile("SELECT NOW()", from: :postgres, to: :mysql)
# => ["SELECT CURRENT_TIMESTAMP()"]

# PostgreSQL to Snowflake
Polyglot.transpile("SELECT CAST(x AS TEXT)", from: :postgres, to: :snowflake)
# => ["SELECT CAST(x AS TEXT)"]
```

### Parse SQL to AST

```ruby
ast = Polyglot.parse("SELECT 1", dialect: :postgres)
# => [{"select" => {...}}]

ast = Polyglot.parse_one("SELECT 1", dialect: :postgres)
# => {"select" => {...}}
```

### Generate SQL from AST

```ruby
ast = Polyglot.parse_one("SELECT 1", dialect: :postgres)
Polyglot.generate(ast, dialect: :mysql)
# => "SELECT 1"
```

### Format SQL

```ruby
Polyglot.format("SELECT a, b FROM t WHERE x = 1", dialect: :postgres)
```

### Validate SQL

```ruby
result = Polyglot.validate("SELECT 1", dialect: :postgres)
result.valid?  # => true
result.errors  # => []

result = Polyglot.validate("SELEC 1")
result.valid?  # => false
result.errors.first.message  # => "..."
```

### List Supported Dialects

```ruby
Polyglot.dialects
# => ["generic", "athena", "bigquery", "clickhouse", ..., "tsql"]
```

## Supported Dialects

<!-- SUPPORTED_DIALECTS:START -->
- Generic
- Athena
- BigQuery
- ClickHouse
- CockroachDB
- Databricks
- Doris
- Dremio
- Drill
- Druid
- DuckDB
- Dune
- Exasol
- Fabric
- Hive
- Materialize
- MySQL
- Oracle
- PostgreSQL
- Presto
- Redshift
- RisingWave
- SingleStore
- Snowflake
- Solr
- Spark
- SQLite
- StarRocks
- Tableau
- Teradata
- TiDB
- Trino
- T-SQL
<!-- SUPPORTED_DIALECTS:END -->

## Error Handling

```ruby
Polyglot::Error            # Base error class
Polyglot::ParseError       # SQL parsing errors
Polyglot::GenerateError    # SQL generation errors
Polyglot::UnsupportedError # Unsupported dialect features
```

## Development

```bash
bundle install
bundle exec rake          # compile + test
bundle exec rake compile  # compile only
bundle exec rake spec     # test only
bundle exec standardrb    # lint
bundle exec rake docs:dialects  # sync README dialect list
```

## License

MIT
