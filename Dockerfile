# Use Node.js 18 base image
FROM node:18

# Set the working directory
WORKDIR /app

# Install system dependencies required for sharp, pg, etc.
RUN apt-get update && apt-get install -y \
    python3 make g++ bash \
    && rm -rf /var/lib/apt/lists/*

# Copy package files for better caching
COPY package*.json ./

# Install all dependencies (including optional like sharp)
RUN npm install --include=optional

# Copy the entire project
COPY . .

# Build the Strapi admin panel
RUN npm run build

# Expose Strapi's default port
EXPOSE 1337

# Start Strapi using the local binary
CMD ["node", "node_modules/.bin/strapi", "start"]

