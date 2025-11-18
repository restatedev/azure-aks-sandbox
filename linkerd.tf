module "linkerd" {
  providers = {
    kubectl = kubectl.main
    helm    = helm.main
  }

  source = "./linkerd"

  depends_on = [
    module.aks,
    helm_release.cert_manager,                   // Certificate crd
    kubectl_manifest.karpenter_nodepool_default, // so we have nodes to run on
  ]
}
