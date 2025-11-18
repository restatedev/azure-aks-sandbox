resource "kubectl_manifest" "premium2_storage_class" {
  provider = kubectl.main

  yaml_body = yamlencode({
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "premium2"
    }
    parameters = {
      skuName = "PremiumV2_LRS"
      fsType  = "xfs",
    }
    provisioner          = "disk.csi.azure.com"
    reclaimPolicy        = "Delete"
    volumeBindingMode    = "WaitForFirstConsumer"
    allowVolumeExpansion = true
  })

  depends_on = [
    module.aks
  ]
}
