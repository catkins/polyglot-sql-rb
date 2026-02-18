use magnus::{function, Error, Object, RArray, Ruby};

mod dialect;
mod errors;

fn transpile(sql: String, from: String, to: String) -> Result<RArray, Error> {
    let ruby = Ruby::get().expect("Ruby runtime not available");
    let from_dialect = dialect::dialect_from_name(&from)?;
    let to_dialect = dialect::dialect_from_name(&to)?;

    let results = polyglot_sql::transpile(&sql, from_dialect, to_dialect)
        .map_err(errors::map_polyglot_error)?;

    let arr = ruby.ary_new_capa(results.len());
    for s in results {
        arr.push(ruby.str_new(&s))?;
    }
    Ok(arr)
}

fn parse(sql: String, dialect_name: String) -> Result<String, Error> {
    let dialect_type = dialect::dialect_from_name(&dialect_name)?;

    let expressions = polyglot_sql::parse(&sql, dialect_type)
        .map_err(errors::map_polyglot_error)?;

    serde_json::to_string(&expressions)
        .map_err(|e| errors::polyglot_error(format!("JSON serialization error: {e}")))
}

fn parse_one(sql: String, dialect_name: String) -> Result<String, Error> {
    let dialect_type = dialect::dialect_from_name(&dialect_name)?;

    let expression = polyglot_sql::parse_one(&sql, dialect_type)
        .map_err(errors::map_polyglot_error)?;

    serde_json::to_string(&expression)
        .map_err(|e| errors::polyglot_error(format!("JSON serialization error: {e}")))
}

fn generate(ast_json: String, dialect_name: String) -> Result<String, Error> {
    let dialect_type = dialect::dialect_from_name(&dialect_name)?;

    let expression: polyglot_sql::expressions::Expression = serde_json::from_str(&ast_json)
        .map_err(|e| errors::polyglot_error(format!("JSON deserialization error: {e}")))?;

    polyglot_sql::generate(&expression, dialect_type)
        .map_err(errors::map_polyglot_error)
}

fn format_sql(sql: String, dialect_name: String) -> Result<String, Error> {
    let dialect_type = dialect::dialect_from_name(&dialect_name)?;
    let dialect = polyglot_sql::dialects::Dialect::get(dialect_type);

    let expressions = polyglot_sql::parse(&sql, dialect_type)
        .map_err(errors::map_polyglot_error)?;

    let mut results = Vec::with_capacity(expressions.len());
    for expr in &expressions {
        let formatted = dialect
            .generate_pretty(expr)
            .map_err(errors::map_polyglot_error)?;
        results.push(formatted);
    }

    Ok(results.join(";\n"))
}

fn validate(sql: String, dialect_name: String) -> Result<String, Error> {
    let dialect_type = dialect::dialect_from_name(&dialect_name)?;

    let result = polyglot_sql::validate(&sql, dialect_type);

    serde_json::to_string(&result)
        .map_err(|e| errors::polyglot_error(format!("JSON serialization error: {e}")))
}

fn dialects() -> Vec<String> {
    dialect::dialect_names()
}

fn version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Polyglot")?;

    errors::define_exceptions(ruby, &module)?;

    module.define_singleton_method("_transpile", function!(transpile, 3))?;
    module.define_singleton_method("_parse", function!(parse, 2))?;
    module.define_singleton_method("_parse_one", function!(parse_one, 2))?;
    module.define_singleton_method("_generate", function!(generate, 2))?;
    module.define_singleton_method("_format", function!(format_sql, 2))?;
    module.define_singleton_method("_validate", function!(validate, 2))?;
    module.define_singleton_method("dialects", function!(dialects, 0))?;
    module.define_singleton_method("native_version", function!(version, 0))?;

    Ok(())
}
