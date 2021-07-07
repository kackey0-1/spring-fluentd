# spring-dockerize

## build
```shell
docker-compose build
```
## execute
```shell
docker-compose up -d 
```

## Structure
- Spring Boot
- Kafka Connect
- Kafka
- ElasticSearch
- Kibana

## 
```shell
Outputs:

elasticsearch = {
  "es_arn" = "arn:aws:es:ap-northeast-1:424041797444:domain/edu-logging-elasticsearch"
  "es_endpoint" = "vpc-edu-logging-elasticsearch-5jn2vhouuci3qqnzpf4w4mwyeq.ap-northeast-1.es.amazonaws.com"
  "kibana_public_url" = "https://ec2-35-75-195-103.ap-northeast-1.compute.amazonaws.com"
  "kibana_vpc_url" = "https://vpc-edu-logging-elasticsearch-5jn2vhouuci3qqnzpf4w4mwyeq.ap-northeast-1.es.amazonaws.com/_plugin/kibana/"
  "user_pool" = "EDU-LOGGING_DEV_USER_POOL"
}
nginx = {
  "private_ip" = "10.0.1.187"
  "public_ip" = "35.75.195.103"
  "ssh_cmd" = "ssh -i ./keypair/nginx-key ec2-user@i-088e1433f4fc9bc93"
}
tags = tomap({
  "Environment" = "DEV"
  "Project" = "EDU-LOGGING"
})
```
