# A Dockerfile is a recipe for building a "container image" — a self-contained
# package with everything our app needs to run (code, Java runtime, OS libs).
# We use a "multi-stage build": one stage to COMPILE the code, and a separate,
# smaller stage to actually RUN it. This keeps the final image small because
# it doesn't include Maven or the source code, only the compiled result.

# --- Build stage ---
# Start from an official image that already has Maven and Java 17 installed.
# "AS build" names this stage "build" so we can reference it later.
FROM maven:3.9-eclipse-temurin-17 AS build

# Sets the working directory inside the container — like doing "cd /app".
# Every command after this runs from inside /app.
WORKDIR /app

# Copy just the pom.xml file into the container first (not the source code yet).
COPY pom.xml .

# Download all the dependencies listed in pom.xml. We do this as its own step,
# BEFORE copying the source code, so Docker can cache this (slow) step and
# skip re-downloading dependencies every time we only change our Java code.
RUN mvn -B dependency:go-offline

# Now copy our actual source code into the container.
COPY src ./src

# Compile the code and package it into a runnable .jar file.
# -DskipTests skips running tests here (they already ran earlier in the CI
# pipeline) to make the Docker build faster.
RUN mvn -B clean package -DskipTests

# --- Runtime stage ---
# Start a brand-new, much smaller image that only has a Java Runtime (JRE),
# not the full JDK or Maven — we don't need those to just RUN the app.
# "alpine" is a minimal, lightweight Linux distribution, which keeps the
# final image small and reduces potential security vulnerabilities.
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Security best practice: create a dedicated non-root user ("spring") to run
# our app, instead of running as the all-powerful "root" user. If someone
# ever exploited our app, they'd be limited to this low-privilege account.
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy ONLY the finished .jar file from the "build" stage above into this
# final image — we leave behind Maven, source code, and build tools entirely.
COPY --from=build /app/target/hello-world-1.0.0.jar app.jar

# Documents that the container listens on port 8080. This is informational —
# it doesn't actually publish the port (Kubernetes handles that separately).
EXPOSE 8080

# The command that runs when a container is started from this image:
# start the Java program packaged inside app.jar.
ENTRYPOINT ["java", "-jar", "app.jar"]
