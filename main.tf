terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
  config = yamldecode(file("./config.yaml"))
}

module "load_balancer" {
  source = "./modules/load_balancer"
  config            = yamldecode(file("./config.yaml"))
  
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  asg_name          = module.autoscaling.asg_name
}

module "autoscaling" {
  source = "./modules/autoscaling"
  config = yamldecode(file("./config.yaml"))

  private_subnet_ids     = module.vpc.private_subnet_ids
  nat_gateway_id         = module.vpc.nat_gateway_id
  private_route_table_id = module.vpc.private_route_table_id
  alb_sg                 = module.load_balancer.alb_sg
  vpc_id                 = module.vpc.vpc_id
}
