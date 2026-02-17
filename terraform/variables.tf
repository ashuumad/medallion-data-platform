# ============================================================
# terraform/variables.tf — Enterprise variables
# ============================================================

variable "subscription_id" {
  description = "Your Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Short project name — used in all resource names (max 8 chars)"
  type        = string
  default     = "medaln"

  validation {
    condition     = length(var.project_name) <= 8
    error_message = "Project name must be 8 characters or less (Azure storage name limit)."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# ── Environment-specific settings (auto-selected by workspace) ─
variable "env_config" {
  description = "Per-environment configuration"
  type = map(object({
    dbt_target        : string
    retention_days    : number
    enable_monitoring : bool
  }))

  default = {
    dev = {
      dbt_target        = "dev"
      retention_days    = 7
      enable_monitoring = false
    }
    qa = {
      dbt_target        = "qa"
      retention_days    = 14
      enable_monitoring = true
    }
    prod = {
      dbt_target        = "prod"
      retention_days    = 90
      enable_monitoring = true
    }
  }
}
