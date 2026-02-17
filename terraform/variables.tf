# ============================================================
# variables.tf — Input variables for the Medallion platform
# ============================================================
# These are like function parameters for your infrastructure.
# Values come from terraform.tfvars (which you create locally
# and NEVER commit to GitHub — it contains secrets).
# ============================================================

variable "subscription_id" {
  description = "Your Azure Subscription ID (find it in Azure Portal)"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Short name for this project — used in resource names (no spaces, lowercase)"
  type        = string
  default     = "medallion"

  validation {
    condition     = length(var.project_name) <= 10
    error_message = "Project name must be 10 characters or less (Azure storage account name limit)."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
  # Other options: "westus2", "westeurope", "australiaeast"
}
