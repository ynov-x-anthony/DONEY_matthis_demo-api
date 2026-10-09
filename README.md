






# Instruction demandé dans Quete 7

# Demo API avec Docker Compose

Ce projet déploie une API Node.js connectée à une base de données PostgreSQL, avec une interface Adminer pour l'administration de la base. Le tout est orchestré avec Docker Compose.

## 🛠️ Prérequis

- Avoir [Docker](https://docs.docker.com/get-docker/) et le plugin Docker Compose installés.
- Sur Windows : utiliser un terminal WSL ou Git Bash (pour la bonne gestion des chemins des volumes).

## 🚀 Installation et démarrage

1. **Préparer les variables d'environnement et le mot de passe (secret) :**
   ```bash
   cp .env.example .env
   echo -n "demo" > db_password.txt
   ```

2. **Construire et lancer la stack en arrière-plan :**
   ```bash
   docker compose up -d --build
   ```

## 🔗 URLs d'accès

Une fois les conteneurs démarrés, les services sont accessibles ici :
- **API (Node.js) :** http://localhost:8080/products
- **Adminer (Interface BDD) :** http://localhost:8081
  - Système : PostgreSQL
  - Serveur : `db`
  - Utilisateur : `demo`
  - Mot de passe : `demo`
  - Base de données : `demo`

## ✅ Vérification du statut

Voici l'extrait de la commande testée pour prouver le bon fonctionnement de la stack, avec la base de données en état "healthy" grâce au healthcheck :

**Commande testée :** `docker compose ps`

**Résultat :**
```text
NAME                 IMAGE                 COMMAND                  SERVICE   STATUS                  PORTS
demo-api-adminer-1   adminer:4             "entrypoint.sh php -…"   adminer   Up 2 minutes            0.0.0.0:8081->8080/tcp
demo-api-api-1       demo-api-multi        "docker-entrypoint.s…"   api       Up 2 minutes            0.0.0.0:8080->3000/tcp
demo-api-db-1        postgres:16-alpine    "docker-entrypoint.s…"   db        Up 2 minutes (healthy)  5432/tcp
```

## 🧹 Maintenance et nettoyage

- **Arrêter les conteneurs sans perdre les données :**
  ```bash
  docker compose down
  ```

- **Repartir de zéro (⚠️ supprime les conteneurs ET efface le volume de la base de données) :** 
  ```bash
  docker compose down -v
  ```














































# demo-api

Le fil rouge des quêtes Docker : une mini-API "catalogue" que tu vas
conteneuriser, faire persister, mettre en réseau, orchestrer et sécuriser,
une quête à la fois.

Le métier est volontairement trivial (`Node` + `Express` + `PostgreSQL`,
un catalogue de produits) : toute la difficulté est sur **Docker**, jamais
sur le code applicatif.

## Point de départ

Ce dossier est ce que tu clones **avant ta première quête Docker**. Il n'y a
volontairement **aucun fichier Docker** dedans, ni `Dockerfile`, ni
`compose.yml` : ce sont précisément les fichiers que tu vas écrire, quête
après quête, en faisant grossir ce dépôt.

Sans conteneur, cette API ne démarre pas telle quelle : elle a besoin d'un
PostgreSQL joignable pour répondre. C'est normal, et c'est tout le sujet de
la première quête que de la faire tourner dans Docker.

## Récupérer ce starter dans ton propre repo

Ce dépôt est un **starter en lecture seule** : tu ne pousses jamais
directement ici. Avant de démarrer la première quête :

1. **Clone** ce repo starter :
   ```bash
   git clone git@github.com:ynov-x-anthony/docker-demo-api-starter.git NOM_prenom_demo-api
   cd NOM_prenom_demo-api
   ```
2. **Supprime le remote `origin`** (il pointe vers le starter, pas vers toi) :
   ```bash
   git remote remove origin
   ```
3. **Crée ton propre repo** sur GitHub, dans l'organisation `ynov-x-anthony`,
   en respectant la nomenclature **`NOM_prenom_demo-api`** (ex. :
   `DUPONT_jean_demo-api`), puis ajoute-le comme nouveau remote et pousse :
   ```bash
   git remote add origin git@github.com:ynov-x-anthony/NOM_prenom_demo-api.git
   git push -u origin main
   ```

À partir de là, c'est **ton** repo : chaque quête s'y ajoute par des commits,
et c'est lui qui sera évalué, pas le starter.

## Ce que contient le repo

| Fichier | Rôle |
|---|---|
| `api/server.js` | l'API Express (`/`, `/version`, `/health`, `/ready`, `/products`) |
| `api/db.js` | connexion PostgreSQL, entièrement pilotée par des variables d'environnement |
| `api/package.json`, `api/package-lock.json` | dépendances (`express`, `pg`) |
| `db/init.sql` | création de la table `products` + quelques données de démo |

## Les routes de l'API

| Méthode | Route | Effet |
|---|---|---|
| `GET` | `/` | infos application + version |
| `GET` | `/version` | numéro de version courant |
| `GET` | `/health` | liveness, ne touche pas la base |
| `GET` | `/ready` | readiness, teste la connexion à la base |
| `GET` | `/products` | liste des produits |
| `POST` | `/products` | crée un produit : `{ "name": "...", "price_cents": 1234 }` |

## Ta progression, quête après quête

| Quête | Ce que tu ajoutes au repo |
|---|---|
| Découverte de Docker | rien ici, tu manipules des images publiques et un `psql` en conteneur |
| Le Dockerfile | `api/Dockerfile`, `api/.dockerignore` : l'API tourne enfin dans un conteneur |
| Les volumes | un volume nommé pour la persistance de PostgreSQL |
| Les réseaux | des réseaux dédiés, la base jamais exposée directement |
| Compose | `compose.yml`, `.env.example` : tous les services démarrent ensemble |
| Dockerfile et sécurité | ton `Dockerfile` durci : utilisateur non-root, `HEALTHCHECK` |
| Builds multi-étapes et gestion des secrets | `api/Dockerfile.multi` : image allégée, secrets hors de l'image |
| Analyse de vulnérabilité avec Trivy | un pipeline CI qui scanne ton image et bloque sur les failles critiques |

## Prérequis machine (macOS / Linux / Windows)

- **Docker Engine + Compose v2** : le plugin intégré, invoqué en deux mots
  `docker compose` (pas l'ancien binaire autonome `docker-compose` v1).
  `docker compose version` doit répondre `v2.x` ou une version supérieure
  (v3, v4, v5…). Ce qui compte, c'est que ce ne soit pas du v1 legacy.
- macOS / Windows : **Docker Desktop** (ou Colima / Rancher Desktop).
  Sous Windows, backend **WSL 2** : travaille depuis un terminal **WSL**.
- `git`, `curl`. Node est nécessaire **seulement** si tu régénères
  `package-lock.json` (`cd api && npm install`, déjà commité ici).
