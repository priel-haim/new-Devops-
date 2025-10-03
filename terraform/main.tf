locals {
  name = "${var.project}-eks"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = local.name }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  for_each                = toset(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  tags = { Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each   = toset(var.private_subnets)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  tags       = { Tier = "private" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.5"
  cluster_name    = local.name
  cluster_version = "1.30"
  vpc_id          = aws_vpc.this.id
  subnet_ids      = [for s in aws_subnet.private : s.id] ++ [for s in aws_subnet.public : s.id]

  eks_managed_node_groups = {
    public = {
      subnet_ids = [for s in aws_subnet.public : s.id]
      min_size   = 1
      max_size   = 2
      desired_size = 1
      instance_types = ["t3.small"]
    }
    private = {
      subnet_ids = [for s in aws_subnet.private : s.id]
      min_size   = 1
      max_size   = 2
      desired_size = 1
      instance_types = ["t3.small"]
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "interview-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  encryption_configuration { encryption_type = "AES256" }
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "ecr_url" { value = aws_ecr_repository.app.repository_url }
output "node_role_arn" { value = module.eks.eks_managed_node_groups["public"].iam_role_arn }


