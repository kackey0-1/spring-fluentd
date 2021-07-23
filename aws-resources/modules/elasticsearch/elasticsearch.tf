module "cognito" {
  source     = "./cognito"
  ENV        = var.ENV
  AWS_REGION = var.AWS_REGION
  PREFIX = var.PREFIX
  DEFAULT_TAGS = var.DEFAULT_TAGS
}

module "elasticsearch_domain" {
  source          = "./elasticsearch-domain"
  ENV             = var.ENV
  PREFIX          = var.PREFIX
  AWS_REGION      = var.AWS_REGION
  SECURITY_GROUPS = var.SECURITY_GROUPS
  SUBNET_IDS      = var.SUBNET_IDS
  COGNITO_MAP     = module.cognito.cognito_map
  ES_ROLES        = [module.spring.spring_es_role, module.nginx.nginx_es_role]
  ES_INSTANCE     = var.ES_INSTANCE
  ES_VOLUME_GB    = var.ES_VOLUME_GB
  ES_ENCRYPTION   = var.ES_ENCRYPTION
  DEFAULT_TAGS    = var.DEFAULT_TAGS
}

module "nginx" {
  source          = "./nginx"
  ENV             = var.ENV
  AWS_REGION      = var.AWS_REGION
  PREFIX          = var.PREFIX
  PEM_KEY         = var.NGINX_KEY
  SUBNET_ID       = var.NGINX_SUBNET_ID
  SECURITY_GROUPS = var.NGINX_SECURITY_GROUPS
  INSTANCE_TYPE   = var.NGINX_INSTANCE
  INSTANCE_VOLUME = var.NGINX_VOLUME_GB
  ES_ENDPOINT     = module.elasticsearch_domain.es_domain.endpoint
  COGNITO_DOMAIN  = lookup(module.cognito.cognito_map, "domain")
  DEFAULT_TAGS    = var.DEFAULT_TAGS
}


module "spring" {
  source          = "./spring"
  ENV             = var.ENV
  AWS_REGION      = var.AWS_REGION
  PREFIX          = var.PREFIX
  PEM_KEY         = var.SPRING_KEY
  SUBNET_ID       = var.SPRING_SUBNET_ID
  SECURITY_GROUPS = var.SPRING_SECURITY_GROUP
  INSTANCE_TYPE   = var.SPRING_INSTANCE
  INSTANCE_VOLUME = var.SPRING_VOLUME_GB
  COGNITO_DOMAIN  = lookup(module.cognito.cognito_map, "domain")
  ES_ENDPOINT     = module.elasticsearch_domain.es_domain.endpoint
  DEFAULT_TAGS    = var.DEFAULT_TAGS
}

//module "alb" {
//  source          = "./alb"
//  ENV             = var.ENV
//  PREFIX          = var.PREFIX
//  SUBNET_ID       = var.NGINX_SUBNET_ID
//  SECURITY_GROUPS = var.SECURITY_GROUPS
//  ES_ENDPOINT     = module.elasticsearch_domain.es_domain.endpoint
//  DEFAULT_TAGS    = var.DEFAULT_TAGS
//}


output "nginx_instance" {
  description = "nginx instance"
  value       = module.nginx.nginx_instance
}

output "nginx_public_ip" {
  description = "nginx public ip"
  value       = module.nginx.nginx_ip.public_ip
}

output "spring_ip" {
  description = "spring instance"
  value       = module.spring.spring_ip
}


output "elasticsearch" {
  description = "elasticsearch info"
  value       =  {
    "es_arn" = module.elasticsearch_domain.es_domain.arn
    "es_endpoint" = module.elasticsearch_domain.es_domain.endpoint
    "kibana_vpc_url" = "https://${module.elasticsearch_domain.es_domain.kibana_endpoint}"
    "kibana_public_url" = "https://${module.nginx.nginx_ip.public_dns}"
    "user_pool" = "${var.PREFIX}_${var.ENV}_USER_POOL"
  }
}
