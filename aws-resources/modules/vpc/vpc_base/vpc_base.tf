variable "ENV" {}
variable "PREFIX" {}
variable "AWS_REGION" {}
variable "SUBNET" {}
variable "AZ" {}
variable "INSTANCE_KEY_PATH" {}
variable "DEFAULT_TAGS" {}

locals {
  instance_pub_key = "${var.INSTANCE_KEY_PATH}.pub"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-VPC"))
  )
}

resource "aws_key_pair" "instance_key" {
  key_name   = basename(var.INSTANCE_KEY_PATH)
  public_key = file(local.instance_pub_key)

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-INSTANCE-KEY"))
  )
}

resource "aws_subnet" "nginx_public_0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.AZ[0]
  map_public_ip_on_launch = true

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-PUBLIC-0-SN"))
  )
}


resource "aws_subnet" "es_private_0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.AZ[0]

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-PRIVATE-0-SN"))
  )
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-IGW"))
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-PUBLIC-RT"))
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_nat_gw_0.id
  }

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-PRIVATE-RT"))
  )
}

resource "aws_route_table_association" "nginx_pub_0" {
  subnet_id      = aws_subnet.nginx_public_0.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "es_private_0" {
  subnet_id      = aws_subnet.es_private_0.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "natgw_eip" {
  vpc = true

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-NATGW_EIP"))
  )
}
resource "aws_nat_gateway" "public_nat_gw_0" {
  subnet_id     = aws_subnet.nginx_public_0.id
  allocation_id = aws_eip.natgw_eip.id

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-PUBLIC-0-NATGW"))
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


output "es_subnet" {
  description = "Subnet reserved for elastic search"
  value       = aws_subnet.es_private_0.id
}

output "nginx_subnet" {
  description = "Subnet reserved for elastic search"
  value       = aws_subnet.nginx_public_0.id
}

output "route_tables" {
  description = "route tables"
  value       = [aws_route_table.public_rt.id, aws_route_table.private_rt.id]
}

output "instance_key" {
  description = "key pair for aws instances"
  value       = aws_key_pair.instance_key.key_name
}

output "subnet_map" {
  description = "subnets created in this vpc"
  value       = {
    "nginx" = [aws_subnet.nginx_public_0.id]
    "es" = [aws_subnet.es_private_0.id]
    "spring" = [aws_subnet.es_private_0.id]
  }
}

output "natgw_map" {
  description = "nat gatway created in this vpc"
  value = {
    "public0" = aws_nat_gateway.public_nat_gw_0.id
  }
}
