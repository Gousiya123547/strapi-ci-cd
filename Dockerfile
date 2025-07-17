# Use Node.js 18 Alpine base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Install OS dependencies (incl. SQLite)
RUN apk add --no-cache libc6-compat python3 make g++ sqlite sqlite-dev

# Copy only package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the admin panel
RUN npm run build

# Expose Strapi’s default port
EXPOSE 1337

# Start Strapi in development mode
CMD ["npm", "run", "develop"]

