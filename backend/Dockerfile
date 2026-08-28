FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

ENV PORT=5000
ENV HISTORY_FILE=/data/operations.json

EXPOSE 5000

CMD ["node", "server.js"]