# Use the official Bun image
FROM oven/bun:latest

# Set the working directory
WORKDIR /app

# Copy package.json, lockfile, env, and prisma schema
COPY package.json bun.lockb .env ./
COPY prisma ./prisma/

# Install dependencies
RUN bun install --frozen-lockfile

# Generate Prisma Client (needs schema and dependencies)
RUN bunx prisma generate
# DO NOT run migrations here

# Copy the rest of the application code
COPY . .

# Declare the volume mount point for the database
VOLUME /app/db

# Expose the port the app runs on
EXPOSE 3000

# Command to run migrations and then the application
CMD ["sh", "-c", "bunx prisma migrate deploy && bun index.ts"]