variable "nuon_id" {
  type        = string
  description = "The nuon id for this install. Used for naming purposes."
}

variable "location" {
  type        = string
  description = "The location to launch the cluster in"
}

// NOTE: if you would like to create an internal load balancer, with TLS, you will have to use the public domain.
variable "internal_root_domain" {
  type        = string
  description = "The internal root domain."
}

variable "public_root_domain" {
  type        = string
  description = "The public root domain."
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version to use for the AKS cluster."
  default     = "1.33"
}

variable "vnet_name" {
  type        = string
  description = "The name of the existing Virtual Network created by Bicep."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name where the existing Virtual Network is located."
}

variable "private_subnet_names" {
  type        = string
  description = "The subnets to deploy private resources into."
}

variable "public_subnet_names" {
  type        = string
  description = "The subnets to deploy public resources into."
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault."
}

variable "kyverno_policy_dir" {
  type        = string
  description = "Path to a directory with kyverno policy manifests."
  default     = "./kyverno-policies"
}

variable "karpenter_default_nodepool_spec" {
  type        = any
  default     = null
  description = "If specified, override the included `default` nodepool spec."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "List of custom tags to add to the install resources. Used for taxonomic purposes."
}

variable "helm_driver" {
  type        = string
  description = "One of 'configmap' or 'secret'"
  default     = "secret"
}
