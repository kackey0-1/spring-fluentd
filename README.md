# spring-dockerize

## build
```shell
docker-compose build
```
## execute
```shell
docker-compose up -d 
```

## kafka connector
create our connector
```shell
$ curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
     "name":"kafka-json-data-logs-elasticsearch-connector",
     "config":{
        "connector.class":"io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
        "connection.url":"http://elasticsearch:9200",
        "tasks.max":"1",
        "topics":"kafka-json-data",
        "type.name":"_doc",
        "name":"quarkus-logs-elasticsearch-connector",
        "value.converter":"org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable":"false",
        "key.converter.schemas.enable":"false",
        "schemas.enable":"false",
        "schema.ignore":"true",
        "key.ignore":"true"
     }
  }'
```