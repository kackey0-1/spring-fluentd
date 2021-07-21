variable "ENV" {}
variable "PREFIX" {}
variable "SUBNET_ID" {}
variable "SECURITY_GROUPS" {}
variable "ES_ENDPOINT" {}
variable "DEFAULT_TAGS" {}

resource "aws_lb" "es-alb" {
  load_balancer_type         = "application"
  security_groups            = [var.SECURITY_GROUPS]
  subnets                    = [var.SUBNET_ID]

  tags = merge(
    var.DEFAULT_TAGS,
    map("Name", "${var.PREFIX}-${var.ENV}-ES-ALB")
  )
}
