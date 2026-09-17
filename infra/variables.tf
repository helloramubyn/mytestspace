# "Variables" are Terraform's way of avoiding hardcoded values repeated
# everywhere, and of making this same configuration reusable for a second
# environment later (e.g. a "staging" copy) just by changing values, not code.
#
# Each variable below has a "default", so the whole project still works with
# zero extra setup — but you can override any of them without editing this
# file, e.g. by running:
#   terraform apply -var="environment=staging"
# or by pointing the pipeline at a different set of values per environment.

variable "location" {
  description = "The Azure region every resource in this project gets created in."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "A short label for which environment this is (prod, staging, dev). Used in resource names."
  type        = string
  default     = "prod"
}
