# Twitter "clone"

A Twitter-like application built with Rust, PostgreSQL, and HTMX.

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Rust and Cargo

### Setup and Running

1. Start the service using Docker Compose:

   ```
   docker compose up
   ```

   This will start the application and its dependencies.

2. Before building with Docker Compose, ensure that the types are up to date:

   a. Start the default database:

   - Run the task "Spawn default database"

   b. Generate types:

   - Run the task "Generate types"

3. To update the database after making changes:
   - Run the task "Create/update init.sql"

### Development

For hot reloading during development:

1. Ensure the default database is active
2. Run the task "Cargo Watch"

This will automatically reload the application when changes are detected.

## Technologies Used

- Rust
- PostgreSQL
- HTMX
- Rocket
- SQLx
- Askama
- Maud
