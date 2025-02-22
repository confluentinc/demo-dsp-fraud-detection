resource "null_resource" "kube_config" {
  provisioner "local-exec" {
    command = <<EOT
aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name}
kubectl config set-context --current --namespace=${var.webapp_namespace}
EOT
  }
}

resource "kubernetes_config_map" "fraud_demo_config" {
  metadata {
    name = "${var.webapp_name}-config" # Replace with your ConfigMap name
    namespace = "${var.webapp_namespace}"     # Change to desired namespace
  }

  data = {
    DB_NAME   = var.oracle_db_name
    DB_USER   = var.oracle_db_username
    DB_HOST   = aws_db_instance.oracle_db.address #
    DB_PORT   = "${var.oracle_db_port}"
    DB_PASSWORD = var.oracle_db_password
    ADMIN_USER_USERNAME = "admin"
    ADMIN_USER_EMAIL = "admin@admin.com"
    ADMIN_USER_PASSWORD = "admin"
  }
  depends_on = [aws_db_instance.oracle_db, aws_eks_cluster.eks_cluster, aws_eks_access_policy_association.caller_cluster_admin_policy]
}

resource "kubernetes_deployment" "fraud_demo" {
  metadata {
    name = "${var.webapp_name}"
    namespace = "${var.webapp_namespace}"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "${var.webapp_name}"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "${var.webapp_name}"
        }
      }

      spec {
        container {
          name  = "${var.webapp_name}"
          image = "public.ecr.aws/v3a9u0p7/demo/fraud-webapp:latest"
          image_pull_policy = "Always"
          command = [
            "/bin/sh",
            "-c"
          ]

          args = [
            <<-EOT
              python /opt/fraud_detection/manage.py makemigrations &&
              python /opt/fraud_detection/manage.py migrate &&
              python /opt/fraud_detection/manage.py collectstatic --no-input &&
              python /opt/fraud_detection/manage.py load_users &&
              python /opt/fraud_detection/manage.py create_default_super_user &&
              gunicorn -c /opt/fraud_detection/gunicorn.conf.py fraud_detection.wsgi:application
            EOT
          ]

          port {
            name           = "gunicornport"
            container_port = 8000
          }

          liveness_probe {
            http_get {
              path = "/health/"
              port = 8000
            }

            initial_delay_seconds = 3
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/health/"
              port = 8000
            }

            initial_delay_seconds = 20
            period_seconds        = 3
            timeout_seconds       = 3
            failure_threshold     = 5
          }

          env {
            name = "DB_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "DB_NAME"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "DB_USER"
              }
            }
          }

          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "DB_HOST"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "DB_PORT"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }

          env {
            name = "ADMIN_USER_USERNAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "ADMIN_USER_USERNAME"
              }
            }
          }

          env {
            name = "ADMIN_USER_EMAIL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "ADMIN_USER_EMAIL"
              }
            }
          }

          env {
            name = "ADMIN_USER_PASSWORD"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.fraud_demo_config.metadata[0].name
                key  = "ADMIN_USER_PASSWORD"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_eks_access_policy_association.caller_cluster_admin_policy, aws_db_instance.oracle_db]
}

resource "kubernetes_service" "fraud_demo_service" {
  metadata {
    name = "service-${var.webapp_name}"
    namespace = "${var.webapp_namespace}"
  }

  spec {
    type = "NodePort"
    selector = {
      "app.kubernetes.io/name" = kubernetes_deployment.fraud_demo.metadata[0].name
    }
    port {
      protocol = "TCP"
      port        = 8080
      target_port = 8000
    }
  }
  depends_on = [kubernetes_deployment.fraud_demo, aws_eks_access_policy_association.caller_cluster_admin_policy]

}

resource "kubernetes_ingress_class" "fraud_demo_load_balancer_controller" {
  metadata {
    labels = {
       "app.kubernetes.io/name" = "LoadBalancerController"
    }
    name = "alb"
  }
  spec {
    controller = "eks.amazonaws.com/alb"
  }
}


resource "kubernetes_ingress_v1" "fraud_demo_load_balancer" {
  wait_for_load_balancer = true
  metadata {
    name = "ingress-${var.webapp_name}"
    namespace = "${var.webapp_namespace}"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  spec {
    ingress_class_name = kubernetes_ingress_class.fraud_demo_load_balancer_controller.metadata[0].name
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.fraud_demo_service.metadata[0].name
            port {
              number = kubernetes_service.fraud_demo_service.spec[0].port[0].port
            }
            }
          }
        }
      }
    }
  }

}

# Display load balancer hostname (typically present in AWS)
output "demo_details" {
  value = {
    fraud_ui = kubernetes_ingress_v1.fraud_demo_load_balancer.status.0.load_balancer.0.ingress.0.hostname
  }
}
