# syntax=docker/dockerfile:1
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S aman && adduser -S aman -G aman
WORKDIR /app
COPY --from=build /src/target/aman-backend-*.jar app.jar
RUN mkdir -p /data/documents && chown -R aman:aman /data /app
USER aman
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
