//////////////////////////////////
// Helpers
//////////////////////////////////

resource "random_id" "MAIN" {
  byte_length = 2
  
  keepers = {
    postfix = var.postfix
  }
}

locals {
  /*postfix = length(
    random_id.MAIN.keepers.postfix
  ) > 0 ? random_id.MAIN.keepers.postfix : random_id.MAIN.hex*/

  postfix = length(var.postfix) > 0 ? var.postfix : random_id.MAIN.hex

  resource_group_name = try(
    length(var.resource_group.name) > 0, false
  ) ? var.resource_group.name : join("-",[var.prefix, local.postfix])
  
  virtual_network_name = try(
    length(var.virtual_network.name) > 0, false
  ) ? var.virtual_network.name : join("-",[var.prefix, "Spoke"])

  subnet_name = try(
    length(var.subnet.name) > 0, false
  ) ? var.subnet.name : join("-",[var.prefix, "AksSystemNodes"])
}

//////////////////////////////////
// Root Resources
//////////////////////////////////

resource "azurerm_resource_group" "MAIN" {
  count    = var.flags.create_rg ? 1 : 0

  name     = local.resource_group_name
  location = var.resource_group.location
}

data "azurerm_resource_group" "MAIN" {
  depends_on = [azurerm_resource_group.MAIN]
  name       = local.resource_group_name
}

resource "azurerm_virtual_network" "MAIN" {
  count               = var.flags.create_vnet ? 1 : 0

  name                = local.virtual_network_name
  address_space       = var.virtual_network.address_space
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
  tags                = var.tags
}

data "azurerm_virtual_network" "MAIN" {
  depends_on          = [azurerm_virtual_network.MAIN]
  name                = local.virtual_network_name
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

resource "azurerm_subnet" "MAIN" {
  count                = var.flags.create_subnet ? 1 : 0

  name                 = local.subnet_name
  address_prefixes     = var.subnet.address_prefixes
  resource_group_name  = data.azurerm_resource_group.MAIN.name
  virtual_network_name = data.azurerm_virtual_network.MAIN.name
}

data "azurerm_subnet" "MAIN" {
  depends_on           = [azurerm_subnet.MAIN]
  name                 = local.subnet_name
  virtual_network_name = data.azurerm_virtual_network.MAIN.name
  resource_group_name  = data.azurerm_resource_group.MAIN.name
}

//////////////////////////////////
// Azzure Kubernetes Service
//////////////////////////////////

resource "azurerm_kubernetes_cluster" "MAIN" {
  count = var.flags.create_aks ? 1 : 0
  
  name       = join("-", [var.prefix,"aks", local.postfix]) //Globally Unique
  dns_prefix = join("-", [var.prefix, "aks"])
  sku_tier   = var.aks.sku_tier
  
  http_application_routing_enabled = var.aks.http_application_routing_enabled
  
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = var.aks.default_pool.name
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    node_count          = var.aks.default_pool.node_count
    vm_size             = var.aks.default_pool.vm_size
    os_disk_size_gb     = var.aks.default_pool.os_disk_size_gb
    vnet_subnet_id      = data.azurerm_subnet.MAIN.id
  }

  node_resource_group = join("-", [data.azurerm_resource_group.MAIN.name, "aks"])
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
  tags                = var.tags
}

//////////////////////////////////
// Azure Container Registry
//////////////////////////////////

resource "azurerm_container_registry" "MAIN" {
  count = var.flags.create_acr ? 1 : 0

  name                = join("", [var.prefix, "acr"])
  sku                 = var.acr.sku
  resource_group_name = data.azurerm_resource_group.MAIN.name
  location            = data.azurerm_resource_group.MAIN.location
}

//////////////////////////////////
// RBAC | Role Assignments
//////////////////////////////////

// Assign read/pull from ACR role for AKS cluster
resource "azurerm_role_assignment" "ACR_PULL" {
  count = alltrue([
    var.flags.create_aks,
    var.flags.create_acr,
  ]) ? 1 : 0

  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
  scope                            = one(azurerm_container_registry.MAIN.*.id)
  principal_id                     = one(azurerm_kubernetes_cluster.MAIN.*.kubelet_identity.0.object_id) // System-assigned AKS identity
}
