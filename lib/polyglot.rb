# frozen_string_literal: true

require_relative "polyglot/version"

# Load the native extension
begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "polyglot/#{Regexp.last_match(1)}/polyglot_rb"
rescue LoadError
  require "polyglot/polyglot_rb"
end

require_relative "polyglot/validation_result"
require "json"

module Polyglot
  class << self
    # Transpile SQL from one dialect to another.
    #
    # @param sql [String] the SQL statement(s) to transpile
    # @param from [String, Symbol] the source dialect
    # @param to [String, Symbol] the target dialect
    # @return [Array<String>] the transpiled SQL statements
    #
    # @example
    #   Polyglot.transpile("SELECT NOW()", from: :postgres, to: :mysql)
    #   # => ["SELECT CURRENT_TIMESTAMP()"]
    #
    def transpile(sql, from:, to:)
      _transpile(sql, from.to_s, to.to_s)
    end

    # Parse SQL into an abstract syntax tree.
    #
    # @param sql [String] the SQL to parse
    # @param dialect [String, Symbol] the SQL dialect (default: :generic)
    # @return [Array<Hash>] the parsed AST expressions
    #
    # @example
    #   Polyglot.parse("SELECT 1", dialect: :postgres)
    #   # => [{"select" => {"expressions" => [...]}}]
    #
    def parse(sql, dialect: :generic)
      JSON.parse(_parse(sql, dialect.to_s))
    end

    # Parse a single SQL statement into an AST.
    #
    # @param sql [String] a single SQL statement
    # @param dialect [String, Symbol] the SQL dialect (default: :generic)
    # @return [Hash] the parsed AST expression
    # @raise [Polyglot::ParseError] if the SQL contains more or fewer than one statement
    #
    # @example
    #   ast = Polyglot.parse_one("SELECT 1", dialect: :postgres)
    #
    def parse_one(sql, dialect: :generic)
      JSON.parse(_parse_one(sql, dialect.to_s))
    end

    # Generate SQL from an AST expression.
    #
    # @param ast [Hash, String] the AST expression (Hash or JSON string)
    # @param dialect [String, Symbol] the target SQL dialect (default: :generic)
    # @return [String] the generated SQL
    #
    # @example
    #   ast = Polyglot.parse_one("SELECT 1", dialect: :postgres)
    #   Polyglot.generate(ast, dialect: :mysql)
    #
    def generate(ast, dialect: :generic)
      json = ast.is_a?(String) ? ast : JSON.generate(ast)
      _generate(json, dialect.to_s)
    end

    # Format (pretty-print) SQL.
    #
    # @param sql [String] the SQL to format
    # @param dialect [String, Symbol] the SQL dialect (default: :generic)
    # @return [String] the formatted SQL
    #
    # @example
    #   Polyglot.format("SELECT a, b FROM t WHERE x = 1", dialect: :postgres)
    #
    def format(sql, dialect: :generic)
      _format(sql, dialect.to_s)
    end

    # Validate SQL syntax.
    #
    # @param sql [String] the SQL to validate
    # @param dialect [String, Symbol] the SQL dialect (default: :generic)
    # @return [Polyglot::ValidationResult]
    #
    # @example
    #   result = Polyglot.validate("SELECT 1", dialect: :postgres)
    #   result.valid? # => true
    #
    # @example Invalid SQL
    #   result = Polyglot.validate("SELEC 1")
    #   result.valid? # => false
    #   result.errors.first.message # => "..."
    #
    def validate(sql, dialect: :generic)
      data = JSON.parse(_validate(sql, dialect.to_s))
      ValidationResult.new(data)
    end
  end
end
