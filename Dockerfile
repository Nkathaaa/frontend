# First stage: Build
FROM node:18-alpine AS builder
WORKDIR '/app'

# Set OpenSSL legacy mode to fix Webpack error
ENV NODE_OPTIONS="--openssl-legacy-provider"
COPY package.json package-lock.json ./
RUN npm install --frozen-lockfile

COPY . .
RUN npm run build

# DEBUG: List contents to verify dist exists
RUN ls -la /app

# Second stage: Runtime
FROM node:18-alpine
WORKDIR '/app'

COPY --from=builder /app/build ./build  
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
ENV NODE_ENV=production

FROM nginx:alpine
# Remove the default Nginx configuration
RUN rm -rf /usr/share/nginx/html/*
# Copy the build output to the default Nginx html folder
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]