# ---- Build ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Les dépendances changent rarement : on les met en cache avant de copier le code.
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src src
RUN mvn -q -B package -DskipTests

# ---- Exécution ----
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

RUN useradd --system --create-home examo
COPY --from=build /app/target/examo-backend-*.jar app.jar
RUN mkdir -p /app/storage && chown -R examo:examo /app
USER examo

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
