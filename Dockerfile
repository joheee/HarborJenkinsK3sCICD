# --- Stage 1: Build the React Frontend ---
FROM node:20-alpine AS build
WORKDIR /app

# Copy package.json and package-lock.json first to cache dependencies
COPY package.json ./
COPY package-lock.json ./

# Use 'npm ci' for a clean, reliable install in CI/CD environments
# This will install your devDependencies like typescript and vite
RUN npm ci

# Copy the rest of your source code
COPY . .

# Build the React application for production
# This will create the 'dist' folder
RUN npm run build

# --- Stage 2: Serve the Static Files with Nginx ---
FROM nginx:alpine

# Copy the built static assets from the build stage to Nginx's public directory
# Using the 'dist' folder as you specified
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80, which Nginx listens on by default
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]