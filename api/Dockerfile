FROM node:22-alpine

WORKDIR /app

# Copie des fichiers de dépendances en premier pour optimiser le cache Docker
COPY package.json package-lock.json ./

# Installation des dépendances de production uniquement
RUN npm ci --omit=dev

# Copie du code source de l'application
COPY server.js db.js ./

EXPOSE 3000

CMD ["node", "server.js"]
