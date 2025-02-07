# First stage: Build
FROM node:18-alpine AS builder
WORKDIR '/app'

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

EXPOSE 80

CMD ["node", "build/index.js"]
