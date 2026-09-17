# "Outputs" print values after `terraform apply` finishes, and let other
# tools (like the app CI/CD pipeline's variable group — see the DevOps
# guide, Section 9) read real values this Terraform run generated, instead
# of hardcoding them a second time somewhere else.
#
# After running `terraform apply`, view these any time with:
#   terraform output

output "aks_cluster_name" {
  description = "The AKS cluster's name — needed by the app pipeline's KubernetesManifest task."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_resource_group" {
  description = "The resource group the AKS cluster lives in — also needed by the app pipeline."
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "The Container Registry's hostname (e.g. acrhelloworldprod.azurecr.io) — used to tag and push Docker images."
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "The Container Registry's short name (no .azurecr.io suffix) — needed by the app pipeline's Docker Registry service connection."
  value       = azurerm_container_registry.main.name
}
