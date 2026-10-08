#!/usr/bin/env bash


echo "=== 1. Construction de l'imag ==="
docker build -t demo-api:1.0 ./api

echo "=== 2. Création des réseaux isolés ==="
docker network create demo_front || true
docker network create demo_back || true

echo "=== 3. Lancement de la base (isolée sur demo_back) ==="
docker run -d \
  --name demo-db \
  --network demo_back \
  -v "$(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
  -e POSTGRES_USER=demo \
  -e POSTGRES_PASSWORD=demo \
  -e POSTGRES_DB=demo \
  postgres:16-alpine

echo "Attente que la base soit prête..."
until docker exec demo-db pg_isready -U demo > /dev/null 2>&1; do
  sleep 2
done

echo "=== 4. Lancement de l'API (connectée aux deux réseaux) ==="
# On la lance sur demo_back pour qu'elle accède à la BDD
docker run -d \
  --name demo-api \
  --network demo_back \
  -p 8080:3000 \
  -e PGHOST=demo-db \
  -e PGUSER=demo \
  -e PGPASSWORD=demo \
  -e PGDATABASE=demo \
  demo-api:1.0

# On connecte l'API au deuxième réseau : demo_front
docker network connect demo_front demo-api

sleep 3 # Pause pour laisser le serveur Node démarrer

echo "=== 5. Vérifications ==="

echo "-> 5.1 demo-api joint-il demo-db par son nom ?"
docker exec demo-api getent hosts demo-db

echo -e "\n-> 5.2 Un conteneur tiers sur demo_front peut-il joindre demo-db ? (Échec attendu)"
# L'ajout de "|| echo" permet de ne pas crasher le script quand la commande échoue
docker run --rm --network demo_front nicolaka/netshoot nc -zv demo-db 5432 || echo "Succès : Connexion refusée/impossible, la base est bien isolée !"

echo -e "\n-> 5.3 Adresses IPv4 des conteneurs :"
echo "Adresses de demo-db (normalement une seule sur demo_back) :"
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-db
echo "Adresses de demo-api (normalement deux : demo_front et demo_back) :"
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-api

echo -e "\n-> 5.4 Test de l'API depuis la machine hôte :"
curl -s localhost:8080/products
echo -e "\n"

echo "=== 6. Nettoyage ==="
docker rm -f demo-api demo-db
docker network rm demo_front demo_back
echo "Terminé !"
