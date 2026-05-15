# Stage 1: Build the React/Vite app
FROM node:24-alpine AS builder

WORKDIR /app

# Install pnpm for faster builds
RUN npm install -g pnpm

# Copy only dependency files first to speed up future builds
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --no-frozen-lockfile

# Copy the rest of your code
COPY . .

# These variables are passed in from your GitHub Action
ARG VITE_SERVER_URL
ARG VITE_APP_URL
ARG VITE_MOBILE_WIDTH
ARG VITE_TURNSTILE_SITEKEY
ARG VITE_RELEASE_TIMESTAMP
ARG VITE_APP_VERSION
ARG VITE_EMOJI_URL
ARG VITE_NERIMITY_CDN
ARG VITE_GOOGLE_CLIENT_ID
ARG VITE_GOOGLE_API_KEY

# Set them as environment variables for the build process
ENV VITE_SERVER_URL=$VITE_SERVER_URL \
    VITE_APP_URL=$VITE_APP_URL \
    VITE_MOBILE_WIDTH=$VITE_MOBILE_WIDTH \
    VITE_TURNSTILE_SITEKEY=$VITE_TURNSTILE_SITEKEY \
    VITE_RELEASE_TIMESTAMP=$VITE_RELEASE_TIMESTAMP \
    VITE_APP_VERSION=$VITE_APP_VERSION \
    VITE_EMOJI_URL=$VITE_EMOJI_URL \
    VITE_NERIMITY_CDN=$VITE_NERIMITY_CDN \
    VITE_GOOGLE_CLIENT_ID=$VITE_GOOGLE_CLIENT_ID \
    VITE_GOOGLE_API_KEY=$VITE_GOOGLE_API_KEY

# Build the app (output goes to /app/dist)
RUN pnpm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build output to Nginx's default folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy the custom Nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
