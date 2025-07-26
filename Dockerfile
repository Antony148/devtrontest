################################# Build Container ###############################

# Use Maven with Eclipse Temurin 17 on Alpine for consistent build environment
FROM maven:3.9-eclipse-temurin-17-alpine as base

WORKDIR /build

COPY pom.xml .
RUN mvn -B -ntp dependency:go-offline

COPY src/ /build/src/
RUN mvn -B -ntp clean package -DskipTests

################################# Prod Container #################################

# Use Eclipse Temurin 17 JRE on Alpine for a slim production image
FROM eclipse-temurin:17.0.15_6-jre-alpine-3.21

RUN addgroup -S nonroot && adduser -S nonroot -G nonroot

WORKDIR /app

COPY --from=base /build/target/*.jar /app/demo.jar
RUN chown nonroot:nonroot /app/demo.jar

USER nonroot

EXPOSE 8080

CMD ["java", "-jar", "/app/demo.jar"]
