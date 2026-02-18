#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("..", __dir__)
DIALECTS_RS = File.join(ROOT, "ext/polyglot_rb/src/dialect.rs")
README = File.join(ROOT, "README.md")
START_MARKER = "<!-- SUPPORTED_DIALECTS:START -->"
END_MARKER = "<!-- SUPPORTED_DIALECTS:END -->"
README_SECTION_REGEX = /#{Regexp.escape(START_MARKER)}.*?#{Regexp.escape(END_MARKER)}/m

DISPLAY_NAMES = {
  "bigquery" => "BigQuery",
  "clickhouse" => "ClickHouse",
  "cockroachdb" => "CockroachDB",
  "duckdb" => "DuckDB",
  "mysql" => "MySQL",
  "postgres" => "PostgreSQL",
  "risingwave" => "RisingWave",
  "singlestore" => "SingleStore",
  "sqlite" => "SQLite",
  "starrocks" => "StarRocks",
  "tidb" => "TiDB",
  "trino" => "Trino",
  "tsql" => "T-SQL"
}.freeze

def display_name(name)
  DISPLAY_NAMES.fetch(name) { name[0].upcase + name[1..] }
end

dialect_source = File.read(DIALECTS_RS)
dialects = dialect_source.scan(/canonical:\s*"([^"]+)"/).flatten

if dialects.empty?
  warn "No dialects found in #{DIALECTS_RS}"
  exit 1
end

dialect_lines = dialects.map { |dialect| "- #{display_name(dialect)}" }.join("\n")

readme = File.read(README)
start_index = readme.index(START_MARKER)
end_index = readme.index(END_MARKER)

if start_index.nil? || end_index.nil? || end_index <= start_index
  warn "README markers not found or invalid"
  exit 1
end

replacement = "#{START_MARKER}\n#{dialect_lines}\n#{END_MARKER}"
updated = readme.sub(README_SECTION_REGEX, replacement)
File.write(README, updated)
