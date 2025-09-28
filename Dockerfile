# --- Stage 1: Build the React Frontend ---
# Use the more stable 'slim' variant to avoid memory issues with npm
FROM node:20-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to cache dependencies
COPY package.json ./
COPY package-lock.json ./

# Use 'npm ci' for a clean, reliable install in CI/CD environments
RUN npm ci

# Copy the rest of your source code
COPY . .

# Build the React application for production
RUN npm run build

# --- Stage 2: Serve the Static Files with Nginx ---
FROM nginx:alpine

# Copy the built static assets from the build stage to Nginx's public directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80, which Nginx listens on by default
EXPOSE 80

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]