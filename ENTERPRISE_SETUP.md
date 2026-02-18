# ============================================================
# ENTERPRISE SETUP GUIDE
# ============================================================
# Follow these steps to enable the full DEV → QA → PROD flow
# ============================================================

## Step 0: Create an Azure Account & Subscription

### Option A — Free Account (recommended for learning/dev)
  1. Go to https://azure.microsoft.com/free/
  2. Sign up with a Microsoft account
     → You get $200 credit for 30 days + 12 months of free services
  3. After sign-up, open Azure Portal: https://portal.azure.com

### Option B — Pay-As-You-Go (for production workloads)
  1. Go to https://azure.microsoft.com/pricing/purchase-options/pay-as-you-go/
  2. Link a credit card — you only pay for what you use

### Install & authenticate the Azure CLI
  # Install (macOS)
  brew install azure-cli

  # Log in
  az login

  # Confirm your subscription is active
  az account show

  # Copy your Subscription ID — you'll need it in the steps below
  az account show --query id -o tsv

### (Optional) Create a dedicated subscription for this project
  # Enterprise best practice: isolate workloads in separate subscriptions
  # Requires an Azure AD account with billing permissions
  az account create \
    --display-name "Medallion Data Platform" \
    --offer-type MS-AZR-0017P   # Pay-As-You-Go offer type

## Step 1: Set Up GitHub Environments (Approval Gates)

Go to your GitHub repo:
  Settings → Environments → New environment

Create THREE environments:
  1. Name: "dev"    → No approval required (auto-deploys)
  2. Name: "qa"     → Required reviewers: [add yourself]
  3. Name: "prod"   → Required reviewers: [add yourself]
                      Wait timer: 5 minutes (gives you time to cancel)

## Step 2: Set Up GitHub Secrets

Go to: Settings → Secrets and variables → Actions → New secret

Add these secrets:

  AZURE_SUBSCRIPTION_ID
  └── Your Azure subscription ID
      Find it: az account show --query id

  AZURE_CREDENTIALS
  └── Service principal JSON for DEV/QA
      Create it:
        az ad sp create-for-rbac \
          --name "sp-medallion-devqa" \
          --role Contributor \
          --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
          --sdk-auth
      Copy the entire JSON output as the secret value

  AZURE_CREDENTIALS_PROD
  └── Separate service principal for PROD (security best practice)
      az ad sp create-for-rbac \
          --name "sp-medallion-prod" \
          --role Contributor \
          --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
          --sdk-auth

  AZURE_SUBSCRIPTION_ID_PROD
  └── Can be the same subscription or a separate PROD subscription

## Step 3: Set Up Git Branches

  git checkout -b develop         # your main development branch
  git push origin develop

  # Feature work flow:
  git checkout -b feature/my-new-model   # develop here
  git push origin feature/my-new-model   # triggers DEV pipeline
  
  # To promote to QA:
  # Open PR: feature/my-new-model → main
  # QA pipeline runs, reviewer gets email to approve
  
  # To promote to PROD:
  # Merge PR to main
  # PROD pipeline runs, reviewer gets email to approve

## Step 4: Set Up Terraform Remote State (One Time)

Before running Terraform for the first time, create the
state storage manually (this stores Terraform's memory):

  az group create --name rg-medallion-tfstate --location centralus

  az storage account create \
    --name stmedtfstateaa \
    --resource-group rg-medallion-tfstate \
    --sku Standard_LRS \
    --kind StorageV2 \
    --location centralus

  az storage container create \
    --name tfstate \
    --account-name stmedtfstateaa \
    --auth-mode login

## Step 5: Initialize Terraform Workspaces

  cd terraform
  terraform init
  terraform workspace new dev
  terraform workspace new qa
  terraform workspace new prod
  terraform workspace select dev   # start with dev

## Your Git Flow

  feature/* branch
       │
       │  push → 🔧 DEV pipeline auto-runs
       │
       ▼
  Pull Request → main
       │
       │  open PR → 🧪 QA pipeline
       │             └── reviewer gets email
       │             └── approves → QA deploys
       │             └── QA tests pass → comment on PR
       │
       ▼
  Merge to main
       │
       │  merge → 🚀 PROD pipeline
       │           └── reviewer gets email
       │           └── approves → PROD deploys
       │
       ▼
  Production ✅
