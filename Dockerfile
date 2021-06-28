FROM adoptopenjdk/openjdk11:slim
WORKDIR /app
COPY build/libs/dockerize-0.0.1.jar  ./dockerize-spring.jar
COPY ./docker-entrypoint.sh ./
ENV JAVA_OPTS="-Xmx256m -Xms256m"
EXPOSE 8080
ENTRYPOINT ["./docker-entrypoint.sh"]
