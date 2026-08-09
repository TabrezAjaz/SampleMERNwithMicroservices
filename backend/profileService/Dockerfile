# profileService — Node.js microservice with MongoDB (port 3002)
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3002
CMD ["node", "index.js"]
