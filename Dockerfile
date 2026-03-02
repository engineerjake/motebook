# Use official Java 21 JDK image
FROM eclipse-temurin:21-jdk-jammy

# Install necessary build tools (git, gradle, etc.)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy project files
COPY gradle gradle
COPY gradlew .
COPY gradlew.bat .
COPY settings.gradle .
COPY gradle.properties .
COPY build.gradle .

# Fix Windows line endings on gradlew so it runs correctly in Linux
RUN sed -i 's/\r//' gradlew && chmod +x gradlew

# Download the Gradle distribution at image build time so it doesn't
# need to be re-downloaded on every JAR build
RUN ./gradlew --version

COPY src src

# Run the build command (requires gradlew in the root)
# The output JAR will be in build/libs/
CMD ["./gradlew", "build"]