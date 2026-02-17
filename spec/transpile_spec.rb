# frozen_string_literal: true

RSpec.describe "Polyglot.transpile" do
  describe "dialect-specific transpilation" do
    it "transpiles PostgreSQL to MySQL" do
      result = Polyglot.transpile(
        "SELECT CAST(x AS TEXT)",
        from: :postgres,
        to: :mysql
      )
      expect(result.first).to be_a(String)
    end

    it "transpiles PostgreSQL to BigQuery" do
      result = Polyglot.transpile(
        "SELECT * FROM users LIMIT 10",
        from: :postgres,
        to: :bigquery
      )
      expect(result.first).to include("SELECT")
    end

    it "transpiles PostgreSQL to Snowflake" do
      result = Polyglot.transpile(
        "SELECT * FROM users",
        from: :postgres,
        to: :snowflake
      )
      expect(result.first).to include("SELECT")
    end

    it "transpiles MySQL to PostgreSQL" do
      result = Polyglot.transpile(
        "SELECT * FROM users LIMIT 10",
        from: :mysql,
        to: :postgres
      )
      expect(result.first).to include("SELECT")
    end

    it "transpiles DuckDB to PostgreSQL" do
      result = Polyglot.transpile(
        "SELECT * FROM users",
        from: :duckdb,
        to: :postgres
      )
      expect(result.first).to include("SELECT")
    end
  end

  describe "complex SQL transpilation" do
    it "transpiles JOINs" do
      sql = <<~SQL.strip
        SELECT u.name, o.total
        FROM users u
        JOIN orders o ON u.id = o.user_id
        WHERE o.total > 100
      SQL

      result = Polyglot.transpile(sql, from: :postgres, to: :mysql)
      expect(result.first).to include("JOIN")
    end

    it "transpiles subqueries" do
      sql = "SELECT * FROM (SELECT 1 AS x) AS t"
      result = Polyglot.transpile(sql, from: :generic, to: :postgres)
      expect(result.first).to include("SELECT")
    end

    it "transpiles GROUP BY with aggregations" do
      sql = <<~SQL.strip
        SELECT department, COUNT(*) AS cnt
        FROM employees
        GROUP BY department
        HAVING COUNT(*) > 5
      SQL

      result = Polyglot.transpile(sql, from: :postgres, to: :snowflake)
      expect(result.first).to include("GROUP BY")
    end

    it "transpiles CREATE TABLE" do
      sql = "CREATE TABLE users (id INT PRIMARY KEY, name TEXT)"
      result = Polyglot.transpile(sql, from: :postgres, to: :mysql)
      expect(result.first).to include("CREATE TABLE")
    end

    it "transpiles INSERT statements" do
      sql = "INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com')"
      result = Polyglot.transpile(sql, from: :generic, to: :postgres)
      expect(result.first).to include("INSERT")
    end
  end
end
