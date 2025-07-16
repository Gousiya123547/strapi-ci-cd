FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache libc6-compat python3 make g++ sqlite sqlite-dev

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "develop"]

