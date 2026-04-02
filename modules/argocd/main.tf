resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.7.3"
  atomic           = true

  # No se tiene en un archivo diferente ya que es basntante simple
  # y nos permite tener todo centrado
  values = [
    yamlencode({
      configs = {
        params = {
          "server.insecure" = true
        }
      }

      # Recursos conservadores para t3.small
      server = {
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "200m", memory = "128Mi" }
        }
      }
      repoServer = {
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }
      applicationSet = {
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "100m", memory = "128Mi" }
        }
      }
      dex = {
        enabled = false
      }
    })
  ]
}
