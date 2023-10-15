FROM node:alpine3.18

WORKDIR /app

        COPY ./app .

        RUN npm run build

CMD ["npm", "run", "serve"]