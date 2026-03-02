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
COPY . .

# Fix Windows line endings on gradlew so it runs correctly in Linux
RUN sed -i 's/\r//' gradlew && chmod +x gradlew

# Run the build command (requires gradlew in the root)
# The output JAR will be in build/libs/
CMD ["./gradlew", "build"]