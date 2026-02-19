#!/usr/bin/env python3
"""
scripts/export_to_adls.py
Export dbt output tables from local DuckDB to Azure ADLS Gen2 as Parquet.

Authenticates via DefaultAzureCredential, which picks up:
  AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID from env vars.

Required env vars:
  ADLS_ACCOUNT  — storage account name (e.g. stmedalndev)
  DUCKDB_PATH   — path to the local DuckDB file (default: /tmp/medallion_dev.duckdb)
"""

import io
import os
import sys

import duckdb
from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import DataLakeServiceClient

ADLS_ACCOUNT = os.environ.get("ADLS_ACCOUNT")
DUCKDB_PATH = os.environ.get("DUCKDB_PATH", "/tmp/medallion_dev.duckdb")
FILESYSTEM = "medallion"

# (duckdb_schema, duckdb_table, adls_directory)
EXPORTS = [
    ("main_bronze", "bronze_raw_customers", "bronze/customers"),
    ("main_bronze", "bronze_raw_orders",    "bronze/orders"),
    ("main_silver", "silver_orders",         "silver/orders"),
    ("main_gold",   "gold_sales_summary",    "gold/sales"),
]


def main() -> None:
    if not ADLS_ACCOUNT:
        print("ERROR: ADLS_ACCOUNT env var is required", file=sys.stderr)
        sys.exit(1)

    print(f"Connecting to DuckDB: {DUCKDB_PATH}")
    con = duckdb.connect(DUCKDB_PATH, read_only=True)

    print(f"Authenticating to ADLS: {ADLS_ACCOUNT}.dfs.core.windows.net")
    credential = DefaultAzureCredential()
    service_client = DataLakeServiceClient(
        account_url=f"https://{ADLS_ACCOUNT}.dfs.core.windows.net",
        credential=credential,
    )
    fs_client = service_client.get_file_system_client(FILESYSTEM)

    for schema, table, adls_dir in EXPORTS:
        fqn = f"{schema}.{table}"
        dest = f"{FILESYSTEM}/{adls_dir}/data.parquet"
        print(f"  Exporting {fqn} → {dest}")

        df = con.execute(f"SELECT * FROM {fqn}").df()

        buf = io.BytesIO()
        df.to_parquet(buf, index=False)
        buf.seek(0)

        file_client = fs_client.get_file_client(f"{adls_dir}/data.parquet")
        file_client.upload_data(buf.read(), overwrite=True)

        print(f"    {len(df)} rows written")

    con.close()
    print("Export complete.")


if __name__ == "__main__":
    main()
