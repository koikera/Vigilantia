FROM node:20-bullseye

RUN apt-get update && \
    apt-get install -y libstdc++6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY vigilantia_adm/ .

RUN npm install -g @angular/cli@19
RUN npm install -f


CMD ["ng", "serve", "--host", "0.0.0.0"]