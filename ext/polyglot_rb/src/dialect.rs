use magnus::{Error, Ruby};
use polyglot_sql::dialects::DialectType;

struct DialectSpec {
    canonical: &'static str,
    dialect: DialectType,
    aliases: &'static [&'static str],
}

const DIALECT_SPECS: &[DialectSpec] = &[
    DialectSpec {
        canonical: "generic",
        dialect: DialectType::Generic,
        aliases: &[],
    },
    DialectSpec {
        canonical: "athena",
        dialect: DialectType::Athena,
        aliases: &[],
    },
    DialectSpec {
        canonical: "bigquery",
        dialect: DialectType::BigQuery,
        aliases: &[],
    },
    DialectSpec {
        canonical: "clickhouse",
        dialect: DialectType::ClickHouse,
        aliases: &[],
    },
    DialectSpec {
        canonical: "cockroachdb",
        dialect: DialectType::CockroachDB,
        aliases: &[],
    },
    DialectSpec {
        canonical: "databricks",
        dialect: DialectType::Databricks,
        aliases: &[],
    },
    DialectSpec {
        canonical: "doris",
        dialect: DialectType::Doris,
        aliases: &[],
    },
    DialectSpec {
        canonical: "dremio",
        dialect: DialectType::Dremio,
        aliases: &[],
    },
    DialectSpec {
        canonical: "drill",
        dialect: DialectType::Drill,
        aliases: &[],
    },
    DialectSpec {
        canonical: "druid",
        dialect: DialectType::Druid,
        aliases: &[],
    },
    DialectSpec {
        canonical: "duckdb",
        dialect: DialectType::DuckDB,
        aliases: &[],
    },
    DialectSpec {
        canonical: "dune",
        dialect: DialectType::Dune,
        aliases: &[],
    },
    DialectSpec {
        canonical: "exasol",
        dialect: DialectType::Exasol,
        aliases: &[],
    },
    DialectSpec {
        canonical: "fabric",
        dialect: DialectType::Fabric,
        aliases: &[],
    },
    DialectSpec {
        canonical: "hive",
        dialect: DialectType::Hive,
        aliases: &[],
    },
    DialectSpec {
        canonical: "materialize",
        dialect: DialectType::Materialize,
        aliases: &[],
    },
    DialectSpec {
        canonical: "mysql",
        dialect: DialectType::MySQL,
        aliases: &[],
    },
    DialectSpec {
        canonical: "oracle",
        dialect: DialectType::Oracle,
        aliases: &[],
    },
    DialectSpec {
        canonical: "postgres",
        dialect: DialectType::PostgreSQL,
        aliases: &["postgresql"],
    },
    DialectSpec {
        canonical: "presto",
        dialect: DialectType::Presto,
        aliases: &[],
    },
    DialectSpec {
        canonical: "redshift",
        dialect: DialectType::Redshift,
        aliases: &[],
    },
    DialectSpec {
        canonical: "risingwave",
        dialect: DialectType::RisingWave,
        aliases: &[],
    },
    DialectSpec {
        canonical: "singlestore",
        dialect: DialectType::SingleStore,
        aliases: &[],
    },
    DialectSpec {
        canonical: "snowflake",
        dialect: DialectType::Snowflake,
        aliases: &[],
    },
    DialectSpec {
        canonical: "solr",
        dialect: DialectType::Solr,
        aliases: &[],
    },
    DialectSpec {
        canonical: "spark",
        dialect: DialectType::Spark,
        aliases: &[],
    },
    DialectSpec {
        canonical: "sqlite",
        dialect: DialectType::SQLite,
        aliases: &[],
    },
    DialectSpec {
        canonical: "starrocks",
        dialect: DialectType::StarRocks,
        aliases: &[],
    },
    DialectSpec {
        canonical: "tableau",
        dialect: DialectType::Tableau,
        aliases: &[],
    },
    DialectSpec {
        canonical: "teradata",
        dialect: DialectType::Teradata,
        aliases: &[],
    },
    DialectSpec {
        canonical: "tidb",
        dialect: DialectType::TiDB,
        aliases: &[],
    },
    DialectSpec {
        canonical: "trino",
        dialect: DialectType::Trino,
        aliases: &[],
    },
    DialectSpec {
        canonical: "tsql",
        dialect: DialectType::TSQL,
        aliases: &[],
    },
];

pub fn dialect_from_name(name: &str) -> Result<DialectType, Error> {
    let normalized = name.to_lowercase().replace(['-', '_'], "");

    for spec in DIALECT_SPECS {
        if spec.canonical == normalized || spec.aliases.contains(&normalized.as_str()) {
            return Ok(spec.dialect);
        }
    }

    let ruby = Ruby::get().expect("Ruby runtime not available");
    Err(Error::new(
        ruby.exception_arg_error(),
        format!("unknown dialect: '{}'. Use Polyglot.dialects to see supported dialects", name),
    ))
}

pub fn dialect_names() -> Vec<String> {
    DIALECT_SPECS
        .iter()
        .map(|spec| spec.canonical.to_string())
        .collect()
}
