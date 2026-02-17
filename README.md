# 🏗️ Cloud-Native Data Engineering Playground
### Medallion Architecture · Azure · Terraform · dbt · Dagster

> **Welcome!** This repo is your personal learning lab for modern data engineering.
> Everything is declarative — you describe *what* you want, the tools figure out *how*.

---

## 🗺️ Your Learning Roadmap

```
Week 1 → Understand the architecture & run it locally
Week 2 → Deploy real Azure infrastructure with Terraform
Week 3 → Build Bronze→Silver→Gold pipelines with dbt
Week 4 → Orchestrate everything with Dagster
Week 5 → Wire up CI/CD with GitHub Actions
```

---

## 🏛️ Architecture Overview

```
                        ┌─────────────────────────────────────┐
                        │           Azure Cloud                │
                        │                                      │
  Raw Data              │  ┌──────────────────────────────┐   │
  (CSV, API, etc.)  ──► │  │  Azure Data Lake Storage Gen2│   │
                        │  │                              │   │
                        │  │  📁 bronze/  (raw data)      │   │
                        │  │  📁 silver/  (cleaned data)  │   │
                        │  │  📁 gold/    (business data) │   │
                        │  └──────────────────────────────┘   │
                        │           ▲        │                 │
                        │           │        ▼                 │
                        │  ┌────────┴────────────────────┐    │
                        │  │   dbt (SQL Transformations)  │    │
                        │  │   Bronze → Silver → Gold     │    │
                        │  └──────────────────────────────┘   │
                        │           ▲                          │
                        │           │                          │
                        │  ┌────────┴────────────────────┐    │
                        │  │   Dagster (Orchestrator)     │    │
                        │  │   Schedules & monitors jobs  │    │
                        │  └──────────────────────────────┘   │
                        │           ▲                          │
                        └───────────┼──────────────────────────┘
                                    │
                        ┌───────────┴──────────────────────────┐
                        │   GitHub Actions (CI/CD)             │
                        │   Runs on every git push             │
                        └──────────────────────────────────────┘
```

---

## 📦 What's In This Repo

| Folder | Tool | What it does |
|--------|------|-------------|
| `terraform/` | Terraform | Creates Azure infrastructure (storage, etc.) |
| `dbt/` | dbt Core | SQL transforms: Bronze → Silver → Gold |
| `dagster/` | Dagster | Schedules and monitors your pipelines |
| `.github/workflows/` | GitHub Actions | Automates everything on push |
| `data/sample/` | — | Sample CSV data to play with |
| `docs/` | — | Extra learning notes |

---

## 🚀 Quick Start (Step by Step)

### Step 1: Prerequisites — Install These First

```bash
# 1. Python (download from python.org if you don't have it)
python --version  # should show 3.9+

# 2. Install all Python tools at once
pip install -r requirements.txt

# 3. Terraform (download from terraform.io)
terraform --version

# 4. Azure CLI (download from docs.microsoft.com/cli/azure)
az --version
```

### Step 2: Set Up Azure (One Time)

```bash
# Login to Azure
az login

# See your subscription ID
az account show --query id

# Copy your subscription ID into terraform/terraform.tfvars
```

### Step 3: Provision Azure Infrastructure

```bash
cd terraform
terraform init          # downloads Azure provider
terraform plan          # shows what will be created (safe, no changes yet)
terraform apply         # creates real Azure resources (type 'yes' to confirm)
```

### Step 4: Run dbt Transformations

```bash
cd dbt
dbt deps                # install dbt packages
dbt seed                # load sample data
dbt run                 # run Bronze → Silver → Gold
dbt test                # test data quality
```

### Step 5: Launch Dagster UI

```bash
cd dagster
dagster dev             # opens browser UI at http://localhost:3000
```

---

## 💰 Estimated Azure Cost

| Resource | Monthly Cost |
|----------|-------------|
| Azure Data Lake Storage Gen2 (10GB) | ~$0.20 |
| Azure Resource Group | Free |
| **Total** | **~$1–5/month** |

> 💡 **New to Azure?** You get **$200 free credit** for 30 days when you sign up!

---

## 🧠 Key Concepts Explained Simply

### What is Medallion Architecture?
Think of it like a water purification system:
- **🟤 Bronze** = Tap water straight from the source (raw, unfiltered)
- **⚪ Silver** = Filtered water (cleaned, validated, duplicates removed)
- **🟡 Gold** = Bottled mineral water (ready to drink, business-ready)

### What is "Declarative"?
- **Imperative** (old way): "Open the cupboard, take out a glass, turn on the tap, fill it..."
- **Declarative** (new way): "I want a glass of water." ✅
- Terraform, dbt, and Dagster are all declarative — you describe the *outcome*, not the steps.

### What is IaC (Infrastructure as Code)?
Your cloud infrastructure (storage buckets, databases) is described in text files (`.tf`).
This means you can version-control it, review it, and recreate it anywhere.

---

## 📚 Next Steps After You're Comfortable

1. Add real data sources (APIs, databases)
2. Add Azure Synapse Analytics for SQL querying at scale
3. Add data visualization with Power BI
4. Learn about slowly changing dimensions (SCDs) in dbt

---

## 🆘 Getting Help

- **dbt docs**: https://docs.getdbt.com
- **Dagster docs**: https://docs.dagster.io
- **Terraform Azure**: https://registry.terraform.io/providers/hashicorp/azurerm
- **Azure free account**: https://azure.microsoft.com/free
