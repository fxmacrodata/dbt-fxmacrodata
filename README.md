# FXMacroData for dbt

Build warehouse models over FXMacroData data loaded by your ingestion pipeline.
This native dbt package provides a lossless staging model, numeric and timed-record
views, a discoverable public operation catalog, and data tests for row counts,
response envelopes and unknown publication times.

[Explore FXMacroData](https://fxmacrodata.com/?utm_source=github&utm_medium=referral&utm_campaign=dbt-fxmacrodata&utm_content=readme)

## Add the package

Use dbt Core 1.11.15 or later with `sqlparse>=0.6.0,<0.7.0`. The reference runtime
is dbt Core 1.11.15, dbt-duckdb 1.11.0 and DuckDB 1.4.3. Install your warehouse
adapter using its normal setup instructions before adding this package.

Add the package to your project's `packages.yml`, pinned to a release tag:

```yaml
packages:
  - git: https://github.com/fxmacrodata/dbt-fxmacrodata.git
    revision: v0.1.0
```

Alternatively, extract this package beside your dbt project and reference it with
`- local: ../dbt-fxmacrodata`.

Configure the relation containing your ingested records in your project's
`dbt_project.yml`:

```yaml
vars:
  fxmacrodata_schema: macro_data
  fxmacrodata_table: fxmacrodata_records
  # fxmacrodata_database defaults to target.database
```

Then install and build:

```sh
dbt deps
dbt build --select package:fxmacrodata
```

The package uses your existing dbt warehouse profile. It does not need an
FXMacroData API credential or call the service from SQL. Load records first with
a customer-side FXMacroData connector, using the shared public-contract row
schema described below. Keep API keys in the ingestion platform's secret manager
and warehouse credentials in your normal dbt profile or environment.

## Models

| Resource | Contents |
| --- | --- |
| `stg_fxmacrodata` | Every ingested record, including null-record envelope rows. |
| `fxmacrodata_numeric_records` | Records with a numeric `value`. |
| `fxmacrodata_timed_records` | Records with an original `announcement_datetime`. |
| `fxmacrodata_operation_catalog` | Public REST operations and packaged MCP tools, with JSON input schemas. |

The source relation needs these columns: `operation`, `source_url`, `record_id`,
`currency`, `indicator`, `date`, `announcement_datetime`, `value`, `value_text`,
`record_json` and `response_json`. `value` is nullable numeric; the remaining
columns are nullable strings. Identity, operation, provenance and JSON envelope
columns must be present. Original JSON fields are never parsed away or replaced.

`record_id` is content identity, so repeated snapshots can share an identity.
The package preserves the rows you loaded and does not silently deduplicate them.
`date` remains the original observation date. Unknown publication times stay null;
calendar schedules and period dates are not converted into observed release times.
The operation catalog describes capabilities, not which operations you have loaded
or which your API plan permits. MCP tool names use an `mcp_` prefix.

## Use the models in your project

Add a model that attaches release context to your own positions:

```sql
select
    positions.currency,
    positions.position_usd,
    events.indicator,
    events.announcement_datetime,
    events.record_json
from {{ ref('positions') }} positions
join {{ ref('fxmacrodata_timed_records') }} events
  on positions.currency = events.currency
where events.operation = 'release_calendar'
```

Choose one operation without rewriting the standard projection:

```sql
{{ fxmacrodata.fxmacrodata_records(operation='indicator_history') }}
```

Explore available operation arguments in the seeded catalog:

```sql
select name, description, input_schema_json
from {{ ref('fxmacrodata_operation_catalog') }}
order by name
```

The package uses dbt's native cross-database type macros and standard SQL. DuckDB
is the reference validation adapter. Validate the package with your warehouse
adapter before scheduling it; output materialization and source relation names
remain configurable through normal dbt settings. The package does not download
history, infer announcements, or create data-provider infrastructure.
