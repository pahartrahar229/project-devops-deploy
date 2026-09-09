# syntax=docker/dockerfile:1

########################
# Stage 1: build frontend
########################
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

########################
# Stage 2: build backend (+ embed frontend static files)
########################
FROM eclipse-temurin:21-jdk-alpine AS backend-build
WORKDIR /app

COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle.kts settings.gradle.kts ./
RUN ./gradlew --no-daemon dependencies || true

COPY src ./src

COPY --from=frontend-build /app/frontend/dist ./src/main/resources/static

RUN ./gradlew --no-daemon test build -x jar || ./gradlew --no-daemon test
RUN ./gradlew --no-daemon build -x test

########################
# Stage 3: minimal runtime image
########################
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S app && adduser -S app -G app
USER app

COPY --from=backend-build /app/build/libs/*-SNAPSHOT.jar /app/app.jar

ENV JAVA_OPTS=""
EXPOSE 8080
EXPOSE 9090

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
