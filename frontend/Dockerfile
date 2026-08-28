FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

ENV PORT=8080
ENV BACKEND_URL=http://backend:5000

EXPOSE 8080

CMD ["node", "server.js"]