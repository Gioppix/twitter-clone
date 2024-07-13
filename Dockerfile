FROM rust:1.79
WORKDIR /app
ENV SQLX_OFFLINE=true
COPY . .
RUN cargo build --release
EXPOSE 3000
CMD ["./target/release/rps"]
