# ============================================================
# outputs.tf — Values exported after terraform apply
# ============================================================
# After running "terraform apply", these values are printed
# so you can use them in your dbt and Dagster configs.
# ============================================================

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.medallion.name
}

output "storage_account_name" {
  description = "Name of the Azure Data Lake Storage account"
  value       = azurerm_storage_account.datalake.name
}

output "data_lake_endpoint" {
  description = "DFS endpoint for the data lake (use in your apps)"
  value       = azurerm_storage_account.datalake.primary_dfs_endpoint
}

output "bronze_path" {
  description = "Full path to the Bronze layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/bronze"
}

output "silver_path" {
  description = "Full path to the Silver layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/silver"
}

output "gold_path" {
  description = "Full path to the Gold layer"
  value       = "abfss://medallion@${azurerm_storage_account.datalake.name}.dfs.core.windows.net/gold"
}
