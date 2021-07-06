variable "region" {
  type = string
  description = "AWS Region, where to deploy ELK cluster."
  default = "ap-northeast-1"
}

locals {
  common_prefix = "edu-spring-elk"
  elk_domain = "${local.common_prefix}-elk-domain"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}