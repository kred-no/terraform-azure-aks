//////////////////////////////////
// Required
//////////////////////////////////
// N/A

//////////////////////////////////
// Optional
//////////////////////////////////

variable "flags" {
  description = <<-HEREDOC
  Modify which resources are to be deployed:
  > create_rg: New resource group will be created (default: true)
  > create_vnet: New virtual network will be created (default: true)
  > create_subnet: New subnet will be created (default: true)
  > create_aks: Create Azure Kubernetes Service cluster (default: true)
  > create_acr: Create Azure Container Registry (default: false)
  HEREDOC
  
  type = object({
    create_rg     = optional(bool, true)
    create_vnet   = optional(bool, true)
    create_subnet = optional(bool, true)
    create_aks    = optional(bool, true)
    create_acr    = optional(bool, false)
  })

  default = {}
}

variable "prefix" {
  description = "Add a prefix to any resources managed by this module"

  type = string
  default = "tfaks"
}

variable "postfix" {
  description = "Add a unique identifier/postfix to resources which are globally unique"
  
  type = string
  default = ""
}

variable "resource_group" {
  type = object({
    name     = optional(string)
    location = optional(string, "West Europe")
  })
  
  default = {}
}

variable "virtual_network" {
  type = object({
    name          = optional(string)
    address_space = set(string)
  })
  
  default = {
    address_space = ["10.200.0.0/16"]
  }
}

variable "subnet" {
  type = object({
    name             = optional(string)
    address_prefixes = set(string)
  })
  
  default = {
    address_prefixes = ["10.200.0.0/27"]
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "acr" {
  description = "Azure Container Registry"

  type = object({
    sku = optional(string, "Basic")
  })

  default = {}
}

variable "aks" {
  type    = object({
    sku_tier                         = optional(string, "Free")
    http_application_routing_enabled = optional(bool, false)
    
    default_pool = optional(object({
      name            = optional(string, "default")
      os_sku          = optional(string, "CBLMariner")
      node_count      = optional(number, 1)
      vm_size         = optional(string, "Standard_D2_v2")
      os_disk_size_gb = optional(number, 30)
    }), {})
  })
  
  default = {}
}
