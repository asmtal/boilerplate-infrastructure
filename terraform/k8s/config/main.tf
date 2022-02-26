resource "kubernetes_namespace" "gke_namespace_project" {
  metadata {
    name = "project"
  }
}

## ---------- Deployments ----------

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
          name  = "frontend"

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

resource "kubernetes_deployment" "gke_deployment_backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          image = "${var.region}-docker.pkg.dev/${var.project}/project/backend:latest"
          name  = "backend"

          env {
            name  = "MYSQL_HOST"
            value = var.sql.database_host
          }

          env {
            name  = "MYSQL_USER"
            value = "root"
          }

          env {
            name  = "MYSQL_PASSWORD"
            value = var.sql.database_password
          }

          env {
            name  = "MYSQL_DATABASE"
            value = var.sql.database_name
          }

          env {
            name  = "PORT"
            value = 80
          }

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

## ---------- Services ----------

resource "kubernetes_service" "gke_service_frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "frontend"
    }
    port {
      protocol = "TCP"
      port     = 80
    }
  }
}

resource "kubernetes_service" "gke_service_backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "backend"
    }
    port {
      protocol = "TCP"
      port     = 80
    }
  }
}

## ---------- Ingress ----------

resource "kubernetes_ingress" "gke_ingress_gateway" {
  wait_for_load_balancer = true
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gke_namespace_project.metadata.0.name
  }
  spec {
    backend {
      service_name = kubernetes_service.gke_service_frontend.metadata.0.name
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/api/*"
          backend {
            service_name = kubernetes_service.gke_service_backend.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}
