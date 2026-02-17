# ============================================================
# main.tf — Azure Infrastructure for Medallion Data Platform
# ============================================================
# This file DECLARES what Azure resources you want.
# Terraform figures out HOW to create them.
#
# To use:
#   terraform init
#   terraform plan
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

  # Store Terraform state in Azure (uncomment after first apply)
  # backend "azurerm" {
  #   resource_group_name  = "rg-medallion-tfstate"
  #   storage_account_name = "stmedaliontfstate"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ─────────────────────────────────────────
# Resource Group — a logical container
# ─────────────────────────────────────────
resource "azurerm_resource_group" "medallion" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# ─────────────────────────────────────────
# Storage Account — the data lake foundation
# ─────────────────────────────────────────
resource "azurerm_storage_account" "datalake" {
  name                     = "st${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.medallion.name
  location                 = azurerm_resource_group.medallion.location
  account_tier             = "Standard"
  account_replication_type = "LRS"          # Locally Redundant Storage (cheapest)
  account_kind             = "StorageV2"
  is_hns_enabled           = true           # Enables Data Lake Gen2 (hierarchical namespace)

  tags = local.common_tags
}

# ─────────────────────────────────────────
# Data Lake Filesystem (container)
# ─────────────────────────────────────────
resource "azurerm_storage_data_lake_gen2_filesystem" "medallion" {
  name               = "medallion"
  storage_account_id = azurerm_storage_account.datalake.id
}

# ─────────────────────────────────────────
# Medallion Layers — Bronze, Silver, Gold
# ─────────────────────────────────────────
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

# ─────────────────────────────────────────
# Local values (reusable within this file)
# ─────────────────────────────────────────
locals {
  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}
