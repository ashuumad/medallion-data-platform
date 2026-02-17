# ============================================================
# terraform/outputs.tf — Environment-aware outputs
# ============================================================

output "environment" {
  description = "Current deployment environment"
  value       = terraform.workspace
}

output "resource_group_name" {
  description = "Resource group for this environment"
  value       = azurerm_resource_group.medallion.name
}

output "storage_account_name" {
  description = "Storage account name for this environment"
  value       = azurerm_storage_account.datalake.name
}

output "bronze_path" {
  description = "Full ADLS path to Bronze layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/bronze"
}

output "silver_path" {
  description = "Full ADLS path to Silver layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/silver"
}

output "gold_path" {
  description = "Full ADLS path to Gold layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/gold"
}

output "dbt_storage_config" {
  description = "Paste this into your dbt profiles.yml for this environment"
  value = <<-EOT
    ${terraform.workspace}:
      type: duckdb
      path: 'abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/dbt.duckdb'
      threads: 4
  EOT
}
