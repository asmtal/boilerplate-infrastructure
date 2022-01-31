resource "kubernetes_namespace" "gke_namespace_project" {
  metadata {
    name = "project"
  }
}

resource "kubernetes_deployment" "gke_deployment_gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        app = "gateway"
      }
    }
    template {
      metadata {
        labels = {
          app = "gateway"
        }
      }
      spec {
        container {
          image = "nginx:1.21"
          name  = "nginx"

          resources {
            limits = {
              memory = "512M"
              cpu    = "1"
            }
            requests = {
              memory = "256M"
              cpu    = "50m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gke_service_gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "gateway"
    }
    port {
      protocol = "TCP"
      port     = 80
    }
  }
}
