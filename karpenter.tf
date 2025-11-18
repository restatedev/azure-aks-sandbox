resource "kubectl_manifest" "karpenter_aksnodeclass_default" {
  provider = kubectl.main

  yaml_body = yamlencode({
    apiVersion = "karpenter.azure.com/v1beta1"
    kind       = "AKSNodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      tags = local.default_tags
    }
  })

  depends_on = [
    module.aks
  ]
}

locals {
  default_nodepool_default_spec = {
    limits = {
      cpu    = 100
      memory = "200Gi"
    }
    template = {
      spec = {
        expireAfter = "732h"
        nodeClassRef = {
          group = "karpenter.azure.com"
          kind  = "AKSNodeClass"
          name  = "default"
        }
        requirements = [
          {
            key      = "kubernetes.io/arch"
            operator = "In"
            values = [
              "amd64",
            ]
          },
          {
            key      = "kubernetes.io/os"
            operator = "In"
            values = [
              "linux",
            ]
          },
          {
            key      = "karpenter.sh/capacity-type"
            operator = "In"
            values = [
              "on-demand",
            ]
          },
          {
            key      = "karpenter.azure.com/sku-family"
            operator = "In"
            values = [
              "D"
            ]
          },
          {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values = [
              "${var.location}-1",
              "${var.location}-2",
              "${var.location}-3",
            ]
          },
        ]
      }
    }
    # https://karpenter.sh/v1.0/concepts/disruption/
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "5m"
      budgets = [
        // only allow one node to be disrupted at once
        {
          nodes = "1",
        },
      ]
    }
  }
  # terraform's dumb type system gets confused if we use a ternary (x ? x : y)
  # to choose between these, so we have do trick it with a conditional list
  # index. bad terraform.
  default_nodepool_spec = [
    var.karpenter_default_nodepool_spec,
    local.default_nodepool_default_spec,
  ][var.karpenter_default_nodepool_spec != null ? 0 : 1]
}

resource "kubectl_manifest" "karpenter_nodepool_default" {
  provider = kubectl.main

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1" # we are on v1 now
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = local.default_nodepool_spec
  })

  depends_on = [
    module.aks,
    kubectl_manifest.karpenter_aksnodeclass_default,
  ]
}
