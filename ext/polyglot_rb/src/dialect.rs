use magnus::{Error, Ruby};
use polyglot_sql::dialects::DialectType;

pub fn dialect_from_name(name: &str) -> Result<DialectType, Error> {
    let normalized = name.to_lowercase().replace(['-', '_'], "");

    match normalized.as_str() {
        "generic" => Ok(DialectType::Generic),
        "athena" => Ok(DialectType::Athena),
        "bigquery" => Ok(DialectType::BigQuery),
        "clickhouse" => Ok(DialectType::ClickHouse),
        "cockroachdb" => Ok(DialectType::CockroachDB),
        "databricks" => Ok(DialectType::Databricks),
        "doris" => Ok(DialectType::Doris),
        "dremio" => Ok(DialectType::Dremio),
        "drill" => Ok(DialectType::Drill),
        "druid" => Ok(DialectType::Druid),
        "duckdb" => Ok(DialectType::DuckDB),
        "dune" => Ok(DialectType::Dune),
        "exasol" => Ok(DialectType::Exasol),
        "fabric" => Ok(DialectType::Fabric),
        "hive" => Ok(DialectType::Hive),
        "materialize" => Ok(DialectType::Materialize),
        "mysql" => Ok(DialectType::MySQL),
        "oracle" => Ok(DialectType::Oracle),
        "postgres" | "postgresql" => Ok(DialectType::PostgreSQL),
        "presto" => Ok(DialectType::Presto),
        "redshift" => Ok(DialectType::Redshift),
        "risingwave" => Ok(DialectType::RisingWave),
        "singlestore" => Ok(DialectType::SingleStore),
        "snowflake" => Ok(DialectType::Snowflake),
        "solr" => Ok(DialectType::Solr),
        "spark" => Ok(DialectType::Spark),
        "sqlite" => Ok(DialectType::SQLite),
        "starrocks" => Ok(DialectType::StarRocks),
        "tableau" => Ok(DialectType::Tableau),
        "teradata" => Ok(DialectType::Teradata),
        "tidb" => Ok(DialectType::TiDB),
        "trino" => Ok(DialectType::Trino),
        "tsql" => Ok(DialectType::TSQL),
        _ => {
            let ruby = Ruby::get().expect("Ruby runtime not available");
            Err(Error::new(
                ruby.exception_arg_error(),
                format!("unknown dialect: '{}'. Use Polyglot.dialects to see supported dialects", name),
            ))
        }
    }
}

pub fn dialect_names() -> Vec<String> {
    vec![
        "generic", "athena", "bigquery", "clickhouse", "cockroachdb",
        "databricks", "doris", "dremio", "drill", "druid", "duckdb",
        "dune", "exasol", "fabric", "hive", "materialize", "mysql",
        "oracle", "postgres", "presto", "redshift", "risingwave",
        "singlestore", "snowflake", "solr", "spark", "sqlite",
        "starrocks", "tableau", "teradata", "tidb", "trino", "tsql",
    ]
    .into_iter()
    .map(|s| s.to_string())
    .collect()
}
