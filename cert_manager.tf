locals {
  cert_manager = {
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                = "cert-manager"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "cert_manager" {
  scope                = azurerm_dns_zone.public.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  name                = azurerm_user_assigned_identity.cert_manager.name
  resource_group_name = azurerm_user_assigned_identity.cert_manager.resource_group_name
  parent_id           = azurerm_user_assigned_identity.cert_manager.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${local.cert_manager.namespace}:${local.cert_manager.name}"
}

resource "helm_release" "cert_manager" {
  provider = helm.main

  namespace        = local.cert_manager.namespace
  create_namespace = true

  name       = local.cert_manager.name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.11.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    yamlencode({
      podLabels = {
        "azure.workload.identity/use" = "true"
      }

      serviceAccount = {
        labels = {
          "azure.workload.identity/use" = "true"
        }
      }

      resources = {
        requests = {
          cpu    = "10m",
          memory = "32Mi",
        }
      }
      tolerations = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NoSchedule"
        },
      ]
      webhook = {
        resources = {
          requests = {
            cpu    = "10m",
            memory = "32Mi",
          }
        }
        tolerations = [
          {
            key    = "CriticalAddonsOnly"
            value  = "true"
            effect = "NoSchedule"
          }
        ]
      }
      cainjector = {
        resources = {
          requests = {
            cpu    = "10m",
            memory = "32Mi",
          }
        }
        tolerations = [
          {
            key    = "CriticalAddonsOnly"
            value  = "true"
            effect = "NoSchedule"
          },
        ]
      }
      startupapicheck = {
        resources = {
          requests = {
            cpu    = "10m",
            memory = "32Mi",
          }
        }
        tolerations = [
          {
            key    = "CriticalAddonsOnly"
            value  = "true"
            effect = "NoSchedule"
          },
        ]
      }
    }),
  ]

  depends_on = [
    module.aks,
    kubectl_manifest.karpenter_nodepool_default
  ]
}
