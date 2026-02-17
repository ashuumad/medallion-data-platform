# ============================================================
# terraform/main.tf — Enterprise Medallion Platform
# ============================================================
# Supports DEV / QA / PROD environments via Terraform workspaces
#
# Usage:
#   terraform workspace new dev
#   terraform workspace new qa
#   terraform workspace new prod
#   terraform workspace select dev
#   terraform apply
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  # Remote state — one container, separate state files per workspace
  backend "azurerm" {
    resource_group_name  = "rg-medallion-tfstate"
    storage_account_name = "stmedtfstate"
    container_name       = "tfstate"
    key                  = "medallion.terraform.tfstate"
    # Terraform automatically uses workspace name as prefix:
    # e.g. dev/medallion.terraform.tfstate
    #      qa/medallion.terraform.tfstate
    #      prod/medallion.terraform.tfstate
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ── Current workspace (dev / qa / prod) ──────────────────────
locals {
  env         = terraform.workspace   # "dev", "qa", or "prod"
  is_prod     = local.env == "prod"

  common_tags = {
    project     = var.project_name
    environment = local.env
    managed_by  = "terraform"
  }
}

# ── Resource Group — one per environment ─────────────────────
resource "azurerm_resource_group" "medallion" {
  name     = "rg-${var.project_name}-${local.env}"
  location = var.location
  tags     = local.common_tags
}

# ── Storage Account — one per environment ────────────────────
resource "azurerm_storage_account" "datalake" {
  name                     = "st${var.project_name}${local.env}"
  resource_group_name      = azurerm_resource_group.medallion.name
  location                 = azurerm_resource_group.medallion.location
  account_tier             = local.is_prod ? "Standard" : "Standard"
  account_replication_type = local.is_prod ? "GRS" : "LRS"  # prod gets geo-redundancy
  account_kind             = "StorageV2"
  is_hns_enabled           = true   # Data Lake Gen2

  # Prod gets soft delete protection
  dynamic "blob_properties" {
    for_each = local.is_prod ? [1] : []
    content {
      delete_retention_policy {
        days = 30
      }
    }
  }

  tags = local.common_tags
}

# ── Main Filesystem ───────────────────────────────────────────
resource "azurerm_storage_data_lake_gen2_filesystem" "medallion" {
  name               = "medallion"
  storage_account_id = azurerm_storage_account.datalake.id
}

# ── Medallion Layer Directories ───────────────────────────────
resource "azurerm_storage_data_lake_gen2_path" "bronze" {
  path               = "bronze"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "silver" {
  path               = "silver"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "gold" {
  path               = "gold"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

# ── Sub-directories per layer (organized by domain) ──────────
resource "azurerm_storage_data_lake_gen2_path" "bronze_orders" {
  path               = "bronze/orders"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "silver_orders" {
  path               = "silver/orders"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "gold_sales" {
  path               = "gold/sales"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.medallion.name
  storage_account_id = azurerm_storage_account.datalake.id
  resource           = "directory"
}
