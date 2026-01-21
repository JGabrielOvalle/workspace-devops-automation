# Estágio 1: Build
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Cache de dependências
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Código
COPY src ./src

# Build
RUN mvn -B clean package -DskipTests

# Estágio 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# (opcional) healthcheck: alpine runtime normalmente não vem com wget/curl
# Se quiser manter, instale wget:
# USER root
# RUN apk add --no-cache wget
# USER spring:spring
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
