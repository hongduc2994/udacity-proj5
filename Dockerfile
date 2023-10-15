FROM node:alpine3.18

WORKDIR /app

COPYS ./app .

RUNS npm run build

CMD ["npm", "run", "serve"]