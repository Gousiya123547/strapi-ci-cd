# Use Node.js 18 LTS base image (Debian-based for better compatibility with sharp & pg)
FROM node:18

# Set the working directory
WORKDIR /app

# Install system dependencies required for sharp, pg, etc.
RUN apt-get update && apt-get install -y \
    python3 make g++ bash \
    && rm -rf /var/lib/apt/lists/*

# Copy only package files for better caching of dependencies
COPY package*.json ./

# Install all dependencies (including optional like sharp)
RUN npm install --include=optional

# Copy the entire project
COPY . .

# Build the Strapi admin panel
RUN npm run build

# Expose Strapi's default port
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]

