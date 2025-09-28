# --- Stage 1: Build the React Frontend ---
# Use a Node.js image to build the React application
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
# We use src/frontend to specify where your React app lives
COPY src/frontend/package.json ./
COPY src/frontend/package-lock.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the frontend source code
COPY src/ ./

# Build the React application for production
# This creates a 'build' folder with static assets
RUN npm run build

# --- Stage 2: Serve the Static Files with Nginx ---
# Use a very lightweight Nginx image to serve the built static files
FROM nginx:alpine

# Copy the static assets from the build stage to Nginx's public directory
# The 'build' folder from the previous stage is copied here
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80, which Nginx listens on by default
EXPOSE 80

# Command to run Nginx (default for nginx:alpine image)
CMD ["nginx", "-g", "daemon off;"]