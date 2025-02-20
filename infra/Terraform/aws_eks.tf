# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.0"
#
#   cluster_name    = "${var.prefix}-eks-cluster-${random_id.env_display_id.hex}"
#   cluster_version = "1.30"
#
#   cluster_endpoint_public_access  = true
#
#   cluster_addons = {
#     coredns                = {}
#     eks-pod-identity-agent = {}
#     kube-proxy             = {}
#     vpc-cni                = {}
#   }
#
#   vpc_id                   = aws_vpc.main.id
#   subnet_ids               = [for subnet in aws_subnet.private_subnets : subnet.id]
#
#   # EKS Managed Node Group(s)
#   eks_managed_node_group_defaults = {
#     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#   }
#
#   eks_managed_node_groups = {
#     example = {
#       # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
#       ami_type       = "AL2023_x86_64_STANDARD"
#       instance_types = ["m5.xlarge"]
#
#       min_size     = 2
#       max_size     = 10
#       desired_size = 2
#     }
#   }
#
#   # Cluster access entry
#   # To add the current caller identity as an administrator
#   enable_cluster_creator_admin_permissions = true
#
#   access_entries = {
#     # One access entry with a policy associated
#     example = {
#       kubernetes_groups = []
#       principal_arn     = "arn:aws:iam::123456789012:role/something"
#
#       policy_associations = {
#         example = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#           access_scope = {
#             namespaces = ["default"]
#             type       = "namespace"
#           }
#         }
#       }
#     }
#   }
#
#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }


################################################################
# EKS IAM ROLES
################################################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.prefix}-eks-cluster-role-${random_id.env_display_id.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Action: "sts:AssumeRole",
      Effect: "Allow",
      Principal: {
        Service: "eks.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "${var.prefix}-eks-cluster-role"
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.prefix}-eks-node-role-${random_id.env_display_id.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Action: "sts:AssumeRole",
      Effect: "Allow",
      Principal: {
        Service: "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "${var.prefix}-eks-node-role-${random_id.env_display_id.hex}"
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_policy]
}
# 3. Amazon EKS Pod Identity
resource "aws_iam_role" "eks_pod_identity" {
  name = "eks-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}




########## POLICY ATTACHMENTS ###########################

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}



resource "aws_iam_role_policy_attachment" "eks_node_role_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Example policy attachment (customize as needed)
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.eks_pod_identity.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_pod_identity.name
}



resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "default"
  service_account = "my-service-account"
  role_arn        = aws_iam_role.eks_pod_identity.arn
}

################################################################
# EKS INFRA
################################################################
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.prefix}-eks-cluster-${random_id.env_display_id.hex}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
    endpoint_public_access = true
    endpoint_private_access = false
    public_access_cidrs = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.prefix}-eks-cluster"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = yamlencode([
      {
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = ["system:bootstrappers", "system:nodes"]
      }
    ])
    "mapUsers" = yamlencode([
      {
        rolarn = data.aws_caller_identity.current.arn
        username = data.aws_caller_identity.current.arn
        policy = "arn:aws:iam::aws:policy/AmazonEKSAdminPolicy"
      }
    ])
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix}-node-group-${random_id.env_display_id.hex}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
    subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
  capacity_type  = "ON_DEMAND"
  instance_types = ["m5n.2xlarge"]
  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }
  tags = {
    Name = "${var.prefix}-node-group-${random_id.env_display_id.hex}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_policy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    kubernetes_config_map.aws_auth
  ]
}
################################################################
# EKS add-ons
################################################################
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "coredns"

  depends_on = [aws_eks_addon.kube_proxy]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                 = "eks-pod-identity-agent"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "vpc-cni"
}



# resource "aws_eks_pod_identity_association" "admin_association" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   namespace       = "default"
#   service_account = "admin-service-account"
#   role_arn        = data.aws_caller_identity.current.arn
# }

