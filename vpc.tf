data "aws_availability_zones" "zones" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.zones.names
  private_subnets = [var.privatesubcidr_1, var.privatesubcidr_2, var.privatesubcidr_3]
  public_subnets  = [var.publicsubcidr_1, var.publicsubcidr_2, var.publicsubcidr_3]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_tags = {
    Name = var.vpc_name
  }
}