locals {
  cert_manager_issuers = {
    email                = "dns@nuon.co"
    server               = "https://acme-v02.api.letsencrypt.org/directory"
    public_issuer_name   = "public-issuer"
    internal_issuer_name = "internal-issuer"
  }
}

resource "kubectl_manifest" "internal_cluster_issuer" {
  provider = kubectl.main

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = local.cert_manager.namespace
      name      = local.cert_manager_issuers.internal_issuer_name
    }
    spec = {
      acme = {
        email  = local.cert_manager_issuers.email
        server = local.cert_manager_issuers.server
        privateKeySecretRef = {
          name = local.cert_manager_issuers.internal_issuer_name
        }
        solvers = [
          {
            selector = {
              dnsZones = [
                azurerm_private_dns_zone.internal.name,
              ]
            }
            dns01 = {
              azureDNS = {
                hostedZoneName    = azurerm_private_dns_zone.internal.name
                resourceGroupName = azurerm_private_dns_zone.internal.resource_group_name
                subscriptionID    = data.azurerm_client_config.current.subscription_id
                environment       = "AzurePublicCloud"
                managedIdentity = {
                  clientID = azurerm_user_assigned_identity.cert_manager.client_id
                }
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "public_cluster_issuer" {
  provider = kubectl.main

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = local.cert_manager.namespace
      name      = local.cert_manager_issuers.public_issuer_name
    }
    spec = {
      acme = {
        email  = local.cert_manager_issuers.email
        server = local.cert_manager_issuers.server
        privateKeySecretRef = {
          name = local.cert_manager_issuers.public_issuer_name
        }
        solvers = [
          {
            selector = {
              dnsZones = [
                azurerm_dns_zone.public.name,
              ]
            }
            dns01 = {
              azureDNS = {
                hostedZoneName    = azurerm_dns_zone.public.name
                resourceGroupName = azurerm_dns_zone.public.resource_group_name
                subscriptionID    = data.azurerm_client_config.current.subscription_id
                environment       = "AzurePublicCloud"
                managedIdentity = {
                  clientID = azurerm_user_assigned_identity.cert_manager.client_id
                }
              }
            }
          }
        ]
      }
    }
  })
  depends_on = [
    helm_release.cert_manager
  ]
}
