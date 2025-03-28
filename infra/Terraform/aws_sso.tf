# data "aws_ssoadmin_instances" "example" {}


resource "aws_eks_access_entry" "non_prod_user_entry" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::550017254839:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_nonprod-administrator_4097a148d8b5d061"
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "non_prod_cluster_admin_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::550017254839:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_nonprod-administrator_4097a148d8b5d061"
  access_scope {
    type = "cluster"
  }
}

