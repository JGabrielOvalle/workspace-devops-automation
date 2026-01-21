# ---------- STAGE 1: BUILD ----------
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copia o pom primeiro para cache de dependências
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Copia o código
COPY src ./src

# Build da aplicação
RUN mvn -B clean package -DskipTests


# ---------- STAGE 2: RUNTIME ----------
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Usuário não-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copia o JAR do estágio de build
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
