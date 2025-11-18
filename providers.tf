locals {
  k8s_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "bash"
    # https://learn.microsoft.com/en-us/azure/aks/kubelogin-authentication#how-to-use-kubelogin-with-aks
    # This requires the az cli to be installed locally where Terraform is executed
    args = ["./kubelogin.sh", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}


provider "azurerm" {
  features {}
}

provider "azapi" {}

provider "helm" {
  alias = "main"

  helm_driver = var.helm_driver

  kubernetes {
    host                   = module.aks.host
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)

    exec {
      api_version = local.k8s_exec.api_version
      command     = local.k8s_exec.command
      args        = local.k8s_exec.args
    }
  }
}


provider "kubectl" {
  alias = "main"

  apply_retry_count      = 5
  host                   = module.aks.host
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  load_config_file       = false

  exec {
    api_version = local.k8s_exec.api_version
    command     = local.k8s_exec.command
    args        = local.k8s_exec.args
  }
}
