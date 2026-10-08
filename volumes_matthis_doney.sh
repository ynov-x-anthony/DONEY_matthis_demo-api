#!/usr/bin/env bash
set -e

echo "=== 1. Construction de l'image de l'API ==="
docker build -t demo-api:1.0 ./api

echo "=== 2. Création du réseau Docker ==="
docker network create demo-net || true

echo "=== 3. Création du volume nommé ==="
docker volume create demo_pgdata

echo "=== 4. Lancement de la base de données PostgreSQL ==="
docker run -d \
  --name demo-db \
  --network demo-net \
  -v demo_pgdata:/var/lib/postgresql/data \
  -v "$(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
  -e POSTGRES_USER=demo \
  -e POSTGRES_PASSWORD=demo \
  -e POSTGRES_DB=demo \
  postgres:16-alpine

echo "=== 5. Attente que la base soit prête ==="
until docker exec demo-db pg_isready -U demo > /dev/null 2>&1; do
  echo "En attente de PostgreSQL..."
  sleep 2
done
echo "PostgreSQL est opérationnel !"

echo "=== 6. Lancement de l'API connectée à la base ==="
docker run -d \
  --name api \
  --network demo-net \
  -p 8080:3000 \
  -e PGHOST=demo-db \
  -e PGUSER=demo \
  -e PGPASSWORD=demo \
  -e PGDATABASE=demo \
  demo-api:1.0

# Petite pause pour s'assurer que l'API a démarré
sleep 3

echo "=== 7. Ajout d'un produit via l'API ==="
curl -s -X POST -H 'content-type: application/json' \
  -d '{"name":"Casquette Démo","price_cents":1200}' \
  localhost:8080/products
echo -e "\n"

echo "=== 8. Test de la persistance : Suppression et recréation de la base ==="
echo "Suppression brutale du conteneur demo-db..."
docker rm -f demo-db

echo "Recréation du conteneur demo-db rattaché au même volume demo_pgdata..."
docker run -d \
  --name demo-db \
  --network demo-net \
  -v demo_pgdata:/var/lib/postgresql/data \
  -v "$(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
  -e POSTGRES_USER=demo \
  -e POSTGRES_PASSWORD=demo \
  -e POSTGRES_DB=demo \
  postgres:16-alpine

echo "Attente de la disponibilité de la base recréée..."
until docker exec demo-db pg_isready -U demo > /dev/null 2>&1; do
  sleep 2
done

echo "=== 9. Vérification finale de la persistance ==="
echo "--- État du volume ---"
docker volume ls | grep demo_pgdata

echo "--- Liste des produits via l'API (La Casquette Démo doit être présente) ---"
curl -s localhost:8080/products
echo -e "\n"

echo "=== Nettoyage de fin de script ==="
docker rm -f api demo-db
docker network rm demo-net
# docker volume rm demo_pgdata  # Commenté pour préserver le volume si besoin
