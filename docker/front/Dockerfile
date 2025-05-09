FROM node:20-bullseye

WORKDIR /app

COPY vigilantia_adm/ .

RUN npm install -g @angular/cli@19
RUN npm install -f


CMD ["ng", "serve", "--host", "0.0.0.0"]