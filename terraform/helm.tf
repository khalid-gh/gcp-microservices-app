resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.18.2"
  namespace        = "argo-cd"
  create_namespace = true
  atomic           = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        image = {
          repository = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.gke-demo-images.repository_id}/argo-cd"
          tag        = "v3.6.2"
        }
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      applicationSet = {
        enabled = false
      }
      redis = {
        image = {
          repository = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.gke-demo-images.repository_id}/redis"
          tag        = "8.6.4-alpine"
        }
      }
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      repoServer = {
        env = [
          {
            name  = "HTTP_PROXY"
            value = "http://${google_compute_instance.bastion.network_interface[0].network_ip}:3128"
          },
          {
            name  = "HTTPS_PROXY"
            value = "http://${google_compute_instance.bastion.network_interface[0].network_ip}:3128"
          },
          {
            name  = "NO_PROXY"
            value = "localhost,127.0.0.1,.svc,.cluster.local,10.0.0.0/18,10.48.0.0/14,10.52.0.0/20,metadata.google.internal,169.254.169.254"
          }
        ]
      }
      configs = {
        repositories = {
          online-boutique = {
            name      = "online-boutique"
            url       = "us-docker.pkg.dev/online-boutique-ci/charts"
            type      = "helm"
            enableOCI = "true"
          }
        }
      }
      extraObjects = [
        yamldecode(file("${path.module}/../argocd/applications/online-boutique.yaml"))
      ]
    })
  ]

  depends_on = [google_artifact_registry_repository_iam_member.node-reader]
}
