# A "provider" is a plugin that teaches Terraform how to talk to a specific
# cloud or service's API. We only need one here: "azurerm", the official
# provider for Microsoft Azure. Terraform downloads this plugin automatically
# the first time you run `terraform init`.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"   # where Terraform downloads the plugin from (the official HashiCorp registry)
      version = "~> 3.0"                # "~> 3.0" means "any 3.x version" — protects us from an unexpected breaking 4.0 upgrade
    }
  }
}

# Every provider needs to be "configured" — even with no settings, as here.
# `features {}` is required by the azurerm provider even when empty; it's
# where you'd opt into provider-wide behavior if you ever needed to.
provider "azurerm" {
  features {}
}
