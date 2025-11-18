terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4.0"
    }

    azurerm = {
      source  = "jackkleeman/azurerm"
      version = "4.54.0-nodeprovisioning"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "= 2.17.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.19"
    }
  }
}
