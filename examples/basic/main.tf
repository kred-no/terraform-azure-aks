//////////////////////////////////
// Variable(s)
//////////////////////////////////

variable "azure" {
  type = object({
    subscription_id = optional(string)
    tenant_id       = optional(string)
  })
  
  default = {}
}

variable "uid_seed" {
  type    = string
  default = "aks-basic-example"
}

//////////////////////////////////
// Provider
//////////////////////////////////

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure.subscription_id
  tenant_id       = var.azure.tenant_id
}

//////////////////////////////////
// Resource variables
//////////////////////////////////

locals {
  uid_seed = join("-", ["terraform-azure-aks", var.uid_seed])
  uid      = substr(uuidv5("dns", local.uid_seed), 0, 6)
}

//////////////////////////////////
// Create Module
//////////////////////////////////

module "AKS" {
  source = "./../../../terraform-azure-aks"
  
  flags = {
    create_acr = false
  }

  aks = {
    default_pool = {
      vm_size = "Standard_B2s" //  Min. req: 2x cpu & 4gb ram
    }
  }
}

// Generate local kubectl config file (for local testing)
resource "local_file" "KUBECONFIG" {
  filename = "kubeconfig.json"
  content  = try(
    module.AKS.aks_sensitive.kube_config_raw,
    "N/A"
  )
}

//////////////////////////////////
// Configure K8S provider
//////////////////////////////////

data "terraform_remote_state" "AKS" {
  depends_on = [
    module.AKS,
  ]

  backend = "local"
  
  config = {
    path = "./terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "AKS" {
  name                = data.terraform_remote_state.AKS.outputs.kubernetes_cluster_name
  resource_group_name = data.terraform_remote_state.AKS.outputs.resource_group_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.AKS.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.AKS.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.AKS.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.AKS.kube_config.0.cluster_ca_certificate)
}
