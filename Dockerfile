# Use Node.js 18 LTS
FROM node:18

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 make g++ bash sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --include=optional --production

# Copy project files
COPY . .

# Ensure SQLite database file exists
RUN [ ! -f /app/data.db ] && touch /app/data.db || true

# Environment variables for Strapi
ENV APP_KEYS="key1,key2,key3,key4"
ENV API_TOKEN_SALT="randomSaltValue"
ENV ADMIN_JWT_SECRET="adminJwtSecretKey"
ENV JWT_SECRET="jwtSecretKey"
ENV NODE_ENV=production
ENV DATABASE_CLIENT=sqlite
ENV DATABASE_FILENAME=/app/data.db

# Build Strapi admin panel
RUN npm run build

# Expose port
EXPOSE 1337

# Start Strapi (fallback to sleep for debugging)
CMD ["sh", "-c", "npm run start || sleep 3600"]

