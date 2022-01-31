resource "kubernetes_namespace" "gke_namespace_project" {
  metadata {
    name = "project"
  }
}

resource "kubernetes_deployment" "gke_deployment_frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          image = "${var.region}-docker.pkg.dev/${var.project}/project/frontend:latest"
          name  = "frontend-nginx"

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

resource "kubernetes_service" "gke_service_frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "frontend"
    }
    port {
      protocol = "TCP"
      port     = 80
    }
  }
}
