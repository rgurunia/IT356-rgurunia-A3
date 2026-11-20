#Defines the provider and region
provider "aws" {
  region = "us-east-2"
}

# This module defines and creates the VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
#Defines name and IPv4
  name = "school-vpc-01"
  cidr = "10.0.0.0/23"
#AZs and how many subnets there are
  azs             = ["eu-east-2a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
