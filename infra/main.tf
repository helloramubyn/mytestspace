# This is the heart of the infra repo: every Azure resource this project
# needs, described as code. Run `terraform plan` to preview what these
# blocks would create, and `terraform apply` to actually create them. See
# the DevOps guide (docs/DEVOPS-GUIDE.md), Section 7, for the full walkthrough.

# The "container" everything else lives inside. Azure groups related
# resources into a Resource Group so they can be viewed, billed, and deleted
# together.
resource "azurerm_resource_group" "main" {
  name     = "rg-helloworld-${var.environment}"   # e.g. "rg-helloworld-prod"
  location = var.location
}

# A private network for our resources to live inside. "10.0.0.0/16" is the
# overall range of private IP addresses available inside this network.
resource "azurerm_virtual_network" "main" {
  name                = "vnet-helloworld"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location   # follows the resource group automatically
  resource_group_name = azurerm_resource_group.main.name
}

# A "subnet" is a smaller slice carved out of the VNet above, dedicated to
# one purpose — here, the AKS cluster's nodes. "10.0.1.0/24" is a smaller
# range within the VNet's larger 10.0.0.0/16 range.
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# The Container Registry (ACR) — private storage for the Docker images the
# app CI/CD pipeline builds and pushes. AKS pulls images from here at
# runtime (see the "AKS -> ACR" dashed arrow in the guide's architecture diagram).
resource "azurerm_container_registry" "main" {
  name                = "acrhelloworld${var.environment}"   # ACR names must be globally unique and contain no hyphens
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"     # controls storage size and throughput limits; Standard is a reasonable default
  admin_enabled       = false           # we authenticate via Azure AD / service connections instead of a shared admin password
}

# Where logs and metrics get collected. AKS is wired up to send data here
# below (see the "oms_agent" block), and this is what Container Insights
# (Azure Portal -> your cluster -> Insights) reads from.
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-helloworld-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"     # pay-per-gigabyte-ingested pricing tier
  retention_in_days   = 30               # how long logs are kept before being automatically deleted
}

# The AKS cluster itself — the managed Kubernetes control plane, plus the
# virtual machines ("nodes") that actually run our application's pods.
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-helloworld-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "helloworld"       # becomes part of the cluster's auto-generated API server hostname

  # The pool of virtual machines that run our pods. Every AKS cluster needs
  # at least one node pool to actually have somewhere to schedule workloads.
  default_node_pool {
    name           = "default"
    node_count     = 2                       # start with 2 nodes for redundancy; see the guide's Cost/Scaling sections for autoscaling
    vm_size        = "Standard_D2s_v3"        # the VM "size" (CPU/RAM) each node uses
    vnet_subnet_id = azurerm_subnet.aks.id    # places the nodes inside the subnet created above
  }

  # Gives the cluster its own identity in Azure AD, so it can be granted
  # permissions (like the AcrPull role below) without a separate stored
  # username/password.
  identity {
    type = "SystemAssigned"
  }

  # Connects the cluster's built-in monitoring agent to the Log Analytics
  # workspace above — this is what makes Container Insights and log queries
  # work at all, with nothing extra to install.
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
}

# Without this, AKS nodes are NOT allowed to pull images from our ACR, and
# every pod will fail to start with an image-pull permission error. This
# explicitly grants the cluster's own identity ("kubelet identity", the one
# actually pulling images) the "AcrPull" role, scoped to just this one
# registry (least privilege — see the guide's Security section).
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id          = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
