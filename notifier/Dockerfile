FROM node:22-alpine
WORKDIR /app
COPY server.js ./
USER node
ENV PORT=3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
