# terraform-azure-aks
Azure Kubernetes deployment

## documentation

  * [AKS-Baseline](https://github.com/mspnp/aks-baseline)
  * [ARM-Templates](https://learn.microsoft.com/en-us/azure/templates/)
  * [RBAC Builtin Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
  * [Terraform Examples](https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/aks/README.md)

## Topology

  * Resource Group
  * Virtual Network
  * Subnet
  * Azure Kubernetes Service (AKS) Nodes
  * Azure Container Registry (ACR)
  * RBAC assignment: ACR-Read (NOTE: Requires Azure AD Role w/correct permissions for terraform operator)

  