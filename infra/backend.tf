# This file tells Terraform WHERE to store its "state file" — the record of
# what infrastructure it has already created, used to work out what needs to
# change on the next run. This has to be a SHARED location (not a file on one
# person's laptop), so that you, a teammate, and the infra pipeline are all
# reading and writing the exact same source of truth.
#
# We use an "azurerm" backend, which stores the state file inside an Azure
# Storage Account — specifically as a blob (a file) called "helloworld.tfstate"
# inside the "tfstate" container of the "sttfstatehelloworld" storage account.
#
# IMPORTANT: this storage account is NOT created by Terraform itself — it has
# to exist before Terraform can even start, because Terraform needs somewhere
# to put its state before it can manage anything else ("chicken and egg"). It
# is created once, by hand, with these Azure CLI commands (see the DevOps
# guide, Section 7, for the full explanation):
#
#   az group create --name rg-terraform-state --location eastus
#   az storage account create --name sttfstatehelloworld --resource-group rg-terraform-state --sku Standard_LRS
#   az storage container create --name tfstate --account-name sttfstatehelloworld

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"    # the resource group holding the storage account below
    storage_account_name = "sttfstatehelloworld"     # must be globally unique across ALL of Azure — rename this if it's taken
    container_name        = "tfstate"                  # the "folder" inside the storage account
    key                    = "helloworld.tfstate"        # the actual filename of the state file
  }
}
