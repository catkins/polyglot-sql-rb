# frozen_string_literal: true

module Polyglot
  class ValidationResult
    attr_reader :errors

    def initialize(data)
      @valid = data["valid"]
      @errors = (data["errors"] || []).map { |e| ValidationError.new(e) }
    end

    def valid?
      @valid
    end

    def to_h
      {
        valid: @valid,
        errors: @errors.map(&:to_h)
      }
    end

    def inspect
      "#<Polyglot::ValidationResult valid=#{@valid} errors=#{@errors.length}>"
    end
  end

  class ValidationError
    attr_reader :message, :line, :column, :severity, :code

    def initialize(data)
      @message = data["message"]
      @line = data["line"]
      @column = data["column"]
      @severity = data["severity"]
      @code = data["code"]
    end

    def error?
      @severity == "error"
    end

    def warning?
      @severity == "warning"
    end

    def to_h
      {
        message: @message,
        line: @line,
        column: @column,
        severity: @severity,
        code: @code
      }
    end

    def inspect
      "#<Polyglot::ValidationError #{@severity}: #{@message}>"
    end
  end
end
