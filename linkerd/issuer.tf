resource "kubectl_manifest" "linkerd_trust_root_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "linkerd-trust-root-issuer"
      namespace = "linkerd"
    }
    spec = {
      selfSigned = {}
    }
  })

  depends_on = [
    helm_release.linkerd_crds
  ]
}

resource "kubectl_manifest" "linkerd_trust_anchor" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-trust-anchor"
      namespace = "linkerd"
    }
    spec = {
      isCA        = true
      commonName  = "root.linkerd.cluster.local"
      secretName  = "linkerd-trust-anchor"
      duration    = "87600h0m0s" // 10 years
      renewBefore = "78840h0m0s" // 9 years
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }
      issuerRef = {
        kind = "Issuer"
        name = "linkerd-trust-root-issuer"
      }
    }
  })

  depends_on = [
    kubectl_manifest.linkerd_trust_root_issuer,
    helm_release.linkerd_crds
  ]
}

resource "kubectl_manifest" "linkerd_identity_issuer_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "linkerd-identity-issuer"
      namespace = "linkerd"
    }
    spec = {
      ca = {
        secretName = "linkerd-trust-anchor"
      }
    }
  })

  depends_on = [
    helm_release.linkerd_crds,
    kubectl_manifest.linkerd_trust_anchor,
  ]
}


resource "kubectl_manifest" "linkerd_identity_issuer_certificate" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-identity-issuer"
      namespace = "linkerd"
    }
    spec = {
      isCA       = true
      commonName = "identity.linkerd.cluster.local"
      secretName = "linkerd-identity-issuer"
      // these need to be written out in full or kubernetes_manifest errors
      duration    = "48h0m0s"
      renewBefore = "25h0m0s"
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }
      issuerRef = {
        kind = "Issuer"
        name = "linkerd-identity-issuer"
      }
      dnsNames = [
        "identity.linkerd.cluster.local"
      ]
      usages = [
        "cert sign",
        "crl sign",
        "server auth",
        "client auth",
      ]
    }
  })

  depends_on = [
    helm_release.linkerd_crds,
    kubectl_manifest.linkerd_identity_issuer_issuer
  ]
}

resource "kubectl_manifest" "linkerd_identity_trust_roots" {
  yaml_body = yamlencode({
    apiVersion = "trust.cert-manager.io/v1alpha1"
    kind       = "Bundle"
    metadata = {
      name = "linkerd-identity-trust-roots"
    }
    spec = {
      sources = [
        {
          secret = {
            name = "linkerd-identity-issuer"
            key  = "ca.crt"
          }
        }
      ]
      target = {
        configMap = {
          key = "ca-bundle.crt"
        }
        namespaceSelector = {
          matchLabels = {
            "kubernetes.io/metadata.name" = "linkerd"
          }
        }
      }
    }
  })

  depends_on = [
    kubectl_manifest.linkerd_identity_issuer_certificate,
    helm_release.cert_manager_trust
  ]
}
