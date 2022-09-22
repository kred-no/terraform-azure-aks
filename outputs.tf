output "aks" {
  depends_on = [azurerm_kubernetes_cluster.MAIN]
  
  description = "Non-sensitive deployment outputs."
  sensitive   = false
  
  value = {
    fqdn = one(azurerm_kubernetes_cluster.MAIN.*.fqdn)
  }
}

output "aks_sensitive" {
  depends_on = [azurerm_kubernetes_cluster.MAIN]
  
  description = "Sensitive deployment outputs."
  sensitive   = true

  value = {
    client_certificate = one(azurerm_kubernetes_cluster.MAIN.*.kube_config.0.client_certificate)
    kube_config_raw    = one(azurerm_kubernetes_cluster.MAIN.*.kube_config_raw)
  }
}

output "acr" {
  depends_on = [azurerm_container_registry.MAIN]
  
  description = "ACR non-sensitive deployment outputs."
  sensitive   = false
  
  value = {
    server = one(azurerm_container_registry.MAIN.*.login_server)
  }
}

output "acr_sensitive" {
  depends_on = [azurerm_container_registry.MAIN]
  description = "ACR sensitive deployment outputs."
  sensitive   = true

  value = {
    id = one(azurerm_container_registry.MAIN.*.id)
  }
}
