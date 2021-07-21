variable "ENV" {}
variable "PREFIX" {}
variable "PEM_KEY" {}
variable "INSTANCE_TYPE" {}
variable "INSTANCE_VOLUME" {}
variable "SUBNET_ID" {}
variable "SECURITY_GROUPS" {}
variable "AWS_REGION" {}
variable "COGNITO_DOMAIN" {}
variable "DEFAULT_TAGS" {}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210701.0-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_policy" "ssm_ec2_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "es_ec2_policy" {
  name = "EC2-ES-POLICY"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
      "Effect": "Allow",
      "Action": ["es:*"],
      "Resource": "arn:aws:es:ap-northeast-1:585898325337:domain/edu-logging-elasticsearch/*"
    }
  ]
}
EOF
}

data "template_file" "userdata" {
  template = file("../common/configure_spring.sh")
}

resource "aws_iam_role" "spring_role" {
  name = "${var.PREFIX}-${var.ENV}-SPRING-INSTANCE-ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "ec2.amazonaws.com",
          "es.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-SPRING-INSTANCE-ROLE"))
  )
}

resource "aws_iam_instance_profile" "spring_profile" {
  name = "${var.PREFIX}-${var.ENV}-SPRING-INSTANCE-PROFILE"
  role = aws_iam_role.spring_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_role" {
  role       = aws_iam_role.spring_role.name
  policy_arn = data.aws_iam_policy.ssm_ec2_role.arn
}

resource "aws_iam_role_policy_attachment" "es_ec2_role" {
  role       = aws_iam_role.spring_role.name
  policy_arn = aws_iam_policy.es_ec2_policy.arn
}

resource "aws_instance" "spring" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.small"
  iam_instance_profile = aws_iam_instance_profile.spring_profile.id
  key_name = var.PEM_KEY
  vpc_security_group_ids = var.SECURITY_GROUPS
  subnet_id = var.SUBNET_ID

  root_block_device {
    volume_type = "gp2"
    volume_size = var.INSTANCE_VOLUME
  }

  user_data = data.template_file.userdata.rendered

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-SPRING-EC2"))
  )

  lifecycle { create_before_destroy = true }
}

output "spring_instance" {
  description = "spring instance"
  value       =  aws_instance.spring
}

output "spring_es_role" {
  description = "spring es role arn"
  value = aws_iam_role.spring_role.arn
}

output "spring_ip" {
  description = "spring ip"
  value       =  {
    "Private IP" = "ssh -i ./keypair/instance-key ec2-user@${aws_instance.spring.private_ip}"
  }
}
