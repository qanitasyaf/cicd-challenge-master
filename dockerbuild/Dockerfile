# FROM eclipse-temurin:17-jdk-alpine
#
# WORKDIR /app
# COPY target/*.jar app.jar
#              ENTRYPOINT ["java", "-jar", "app.jar"]


FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests --batch-mode --no-transfer-progress

FROM eclipse-temurin:21-jre-alpine
ARG APP_DIR=app
WORKDIR /$APP_DIR
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java -jar app.jar"]

