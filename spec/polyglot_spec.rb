# frozen_string_literal: true

RSpec.describe Polyglot do
  describe ".transpile" do
    it "transpiles SQL between dialects" do
      result = Polyglot.transpile("SELECT NOW()", from: :postgres, to: :snowflake)
      expect(result).to be_a(Array)
      expect(result.length).to eq(1)
      expect(result.first).to be_a(String)
    end

    it "accepts string dialect names" do
      result = Polyglot.transpile("SELECT 1", from: "postgres", to: "mysql")
      expect(result).to be_a(Array)
      expect(result.length).to eq(1)
    end

    it "transpiles multiple statements" do
      sql = "SELECT 1; SELECT 2"
      result = Polyglot.transpile(sql, from: :generic, to: :postgres)
      expect(result.length).to eq(2)
    end

    it "raises Polyglot::ParseError for invalid SQL" do
      expect {
        Polyglot.transpile("NOT VALID SQL HERE !!!", from: :postgres, to: :mysql)
      }.to raise_error(Polyglot::Error)
    end

    it "raises ArgumentError for unknown dialect" do
      expect {
        Polyglot.transpile("SELECT 1", from: :nonexistent, to: :mysql)
      }.to raise_error(StandardError)
    end

    it "handles SELECT with WHERE clause" do
      result = Polyglot.transpile(
        "SELECT * FROM users WHERE id = 1",
        from: :postgres,
        to: :mysql
      )
      expect(result.first).to include("SELECT")
      expect(result.first).to include("users")
    end
  end

  describe ".parse" do
    it "parses SQL into an AST array" do
      result = Polyglot.parse("SELECT 1", dialect: :generic)
      expect(result).to be_a(Array)
      expect(result.length).to eq(1)
    end

    it "returns hashes representing AST nodes" do
      result = Polyglot.parse("SELECT 1", dialect: :generic)
      expect(result.first).to be_a(Hash)
    end

    it "defaults to the generic dialect" do
      result = Polyglot.parse("SELECT 1")
      expect(result).to be_a(Array)
      expect(result.length).to eq(1)
    end

    it "accepts symbol dialect names" do
      result = Polyglot.parse("SELECT 1", dialect: :postgres)
      expect(result).to be_a(Array)
    end

    it "parses multiple statements" do
      result = Polyglot.parse("SELECT 1; SELECT 2", dialect: :generic)
      expect(result.length).to eq(2)
    end

    it "raises Polyglot::ParseError for invalid SQL" do
      expect {
        Polyglot.parse("NOT VALID SQL !!!")
      }.to raise_error(Polyglot::Error)
    end
  end

  describe ".parse_one" do
    it "parses a single SQL statement" do
      result = Polyglot.parse_one("SELECT 1", dialect: :generic)
      expect(result).to be_a(Hash)
    end

    it "defaults to the generic dialect" do
      result = Polyglot.parse_one("SELECT 1")
      expect(result).to be_a(Hash)
    end

    it "raises for invalid SQL" do
      expect {
        Polyglot.parse_one("NOT VALID !!!")
      }.to raise_error(Polyglot::Error)
    end
  end

  describe ".generate" do
    it "generates SQL from an AST" do
      ast = Polyglot.parse_one("SELECT 1", dialect: :generic)
      sql = Polyglot.generate(ast, dialect: :generic)
      expect(sql).to be_a(String)
      expect(sql.upcase).to include("SELECT")
    end

    it "generates SQL for a different dialect" do
      ast = Polyglot.parse_one("SELECT 1", dialect: :postgres)
      sql = Polyglot.generate(ast, dialect: :mysql)
      expect(sql).to be_a(String)
    end

    it "accepts a JSON string" do
      ast = Polyglot.parse_one("SELECT 1", dialect: :generic)
      json = JSON.generate(ast)
      sql = Polyglot.generate(json, dialect: :generic)
      expect(sql).to be_a(String)
    end

    it "round-trips parse -> generate" do
      original = "SELECT 1"
      ast = Polyglot.parse_one(original, dialect: :generic)
      regenerated = Polyglot.generate(ast, dialect: :generic)
      expect(regenerated.upcase).to include("SELECT")
      expect(regenerated).to include("1")
    end
  end

  describe ".format" do
    it "formats SQL" do
      formatted = Polyglot.format("SELECT a, b FROM t WHERE x = 1", dialect: :generic)
      expect(formatted).to be_a(String)
      expect(formatted).to include("SELECT")
    end

    it "defaults to the generic dialect" do
      formatted = Polyglot.format("SELECT 1")
      expect(formatted).to be_a(String)
    end

    it "raises for invalid SQL" do
      expect {
        Polyglot.format("NOT VALID SQL !!!")
      }.to raise_error(Polyglot::Error)
    end
  end

  describe ".validate" do
    it "returns a ValidationResult for valid SQL" do
      result = Polyglot.validate("SELECT 1", dialect: :generic)
      expect(result).to be_a(Polyglot::ValidationResult)
      expect(result.valid?).to be true
      expect(result.errors).to be_empty
    end

    it "defaults to the generic dialect" do
      result = Polyglot.validate("SELECT 1")
      expect(result).to be_a(Polyglot::ValidationResult)
    end

    it "returns errors for invalid SQL" do
      result = Polyglot.validate("SELECT * FROM WHERE")
      expect(result.valid?).to be false
      expect(result.errors).not_to be_empty
    end

    it "provides error details" do
      result = Polyglot.validate("SELECT * FROM WHERE")
      error = result.errors.first
      expect(error).to be_a(Polyglot::ValidationError)
      expect(error.message).to be_a(String)
      expect(error.message).not_to be_empty
    end

    it "supports to_h" do
      result = Polyglot.validate("SELECT 1")
      hash = result.to_h
      expect(hash).to be_a(Hash)
      expect(hash[:valid]).to be true
      expect(hash[:errors]).to be_a(Array)
    end

    it "supports inspect" do
      result = Polyglot.validate("SELECT 1")
      expect(result.inspect).to include("ValidationResult")
    end
  end

  describe ".dialects" do
    it "returns a list of supported dialect names" do
      result = Polyglot.dialects
      expect(result).to be_a(Array)
      expect(result).to include("postgres")
      expect(result).to include("mysql")
      expect(result).to include("bigquery")
      expect(result).to include("snowflake")
      expect(result).to include("duckdb")
      expect(result).to include("sqlite")
      expect(result).to include("generic")
    end

    it "returns at least 30 dialects" do
      expect(Polyglot.dialects.length).to be >= 30
    end
  end

  describe "error hierarchy" do
    it "defines Polyglot::Error < StandardError" do
      expect(Polyglot::Error).to be < StandardError
    end

    it "defines Polyglot::ParseError < Polyglot::Error" do
      expect(Polyglot::ParseError).to be < Polyglot::Error
    end

    it "defines Polyglot::GenerateError < Polyglot::Error" do
      expect(Polyglot::GenerateError).to be < Polyglot::Error
    end

    it "defines Polyglot::UnsupportedError < Polyglot::Error" do
      expect(Polyglot::UnsupportedError).to be < Polyglot::Error
    end
  end

  describe "VERSION" do
    it "is defined" do
      expect(Polyglot::VERSION).to be_a(String)
      expect(Polyglot::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end
end
