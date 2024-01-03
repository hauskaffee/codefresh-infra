data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "random_id" "generated" {
  byte_length = 6
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 19.21.0"

  cluster_name                              = lower("${var.owner}-k8s-${random_id.generated.id}")
  cluster_version                           = 1.28
  cluster_endpoint_public_access            = true
  iam_role_use_name_prefix                  = false
  node_security_group_use_name_prefix       = false
  cluster_encryption_policy_use_name_prefix = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  create_cloudwatch_log_group = false

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.xlarge"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 50
    min_size       = 0
    max_size       = 3
    desired_size   = 1

    iam_role_use_name_prefix = false
    use_name_prefix          = false

    schedules = {
      scale-up = {
        min_size     = 0
        max_size     = 3
        desired_size = 1
        time_zone    = "America/Los_Angeles"
        recurrence   = "0 6 * * 1-5"
      },
      scale-down = {
        min_size     = 0
        max_size     = 3
        desired_size = 0
        time_zone    = "America/Los_Angeles"
        recurrence   = "0 17 * * 1-5"
      }
    }
  }

  eks_managed_node_groups = {
    ng-1 = {
      name = "${var.owner}-ng-${random_id.generated.id}"
    }
  }

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.4.0"

  name = "${var.owner}-vpc-${random_id.generated.id}"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 100)]

  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

}
