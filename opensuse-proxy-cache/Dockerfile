# 1. PLANNER STAGE
# We use the official Rust image to compute a lock-like file for our dependencies
FROM rust:1.92-bookworm AS chef
WORKDIR /app
RUN cargo install cargo-chef --locked

# Copy source code (see .dockerignore)
COPY . .
# Prepare the recipe (a file describing dependencies)
RUN cargo chef prepare --recipe-path recipe.json

# 2. CACHER STAGE
# We build our dependencies here. This layer is CACHED until Cargo.toml/lock changes.
FROM rust:1.92-bookworm AS cacher
WORKDIR /app
RUN cargo install cargo-chef --locked
COPY --from=chef /app/recipe.json recipe.json
# Build dependencies - this is the caching magic!
RUN cargo chef cook --release --recipe-path recipe.json

# 3. BUILDER STAGE
# Now we build the actual application
FROM rust:1.92-bookworm AS builder
WORKDIR /app
# Copy compiled dependencies from the cacher stage
COPY --from=cacher /app/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
# Copy source code
COPY . .
# Build the binary
RUN cargo build --release  -p opensuse-proxy-cache

# 4. RUNTIME STAGE
# We use a minimal Linux image to run the binary.
# debian:bookworm-slim is a safe choice (uses glibc).
# For smaller images (but harder debugging), use gcr.io/distroless/cc-debian12
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Install OpenSSL if your app needs it (very common in Rust web apps)
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates curl \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /app/target/release/opensuse-proxy-cache /bin/

EXPOSE 8080
EXPOSE 8443
WORKDIR /

HEALTHCHECK --interval=15s --timeout=2s --start-period=8m CMD sh -c "curl -f http://localhost:8080/_status || exit 1"
STOPSIGNAL SIGINT

CMD ["/bin/opensuse-proxy-cache"]
