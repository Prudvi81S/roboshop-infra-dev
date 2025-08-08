resource "aws_key_pair" "eks" {
  key_name   = "eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxSOzGEDubih7/iVwwei7oA1O6VGkakFCyUc/+1VltJjuWlpvSrN48SKENy9PfelVYSjCshjowEjxMugmaV7EIjgan8zwj9gxWhUyxMeVJtiUdEnuP0fSA9XjLeZys+OM0YYKW6PQevHEqvQsf0vV/4ybPrGwjnENQkkDCmUbAao4gYw/074aoc393pN8prQnYWAGm82Q2lruzPvmf4asZ0M7NlJmPba7V+0gvHKf0SYC3+4r7HeAklcvfGuwS6x9kSNZiUAK6eMU0Rcuhh7t+1gUJkG91ff3GDlLOOcPYE4q4tMyvz5kwJSw1WiOoKhSpeLons6bkCLKu6Lk12BIh vishw@DESKTOP-407NF1M"

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"


  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 3
    #   max_size      = 10
    #   desired_size  = 3
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size      = 3
      max_size      = 10
      desired_size  = 3
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}