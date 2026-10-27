# Examo

Application de préparation au CEPD (examen togolais) : sujets officiels, correction
par IA, lecture à voix haute. Le dépôt regroupe les deux projets :

- **`examo_app/`** — application mobile Flutter (élève).
- **`examo_backend/`** — API Spring Boot (sujets, corrections, IA, synthèse vocale).

## Déploiement avec Docker (recommandé)

Prérequis : [Docker Desktop](https://www.docker.com/products/docker-desktop/).

```bash
cp .env.example .env     # renseigner les valeurs (voir ci-dessous)
docker compose up --build
```

Au démarrage, `docker-compose.yml` (à la racine) lance deux services :

| Service   | Rôle                                      | Port exposé |
|-----------|--------------------------------------------|-------------|
| `db`      | PostgreSQL 17, base `examo`                | interne uniquement |
| `backend` | API Spring Boot (build depuis `examo_backend/`) | `8080` |

L'API est alors disponible sur `http://localhost:8080`. Les sujets officiels
(`examo_backend/src/main/resources/exams/`) sont importés automatiquement en base
au premier démarrage.

### Variables d'environnement (`.env`)

| Variable             | Obligatoire | Rôle                                                              |
|-----------------------|:-----------:|--------------------------------------------------------------------|
| `DB_PASSWORD`         | oui         | Mot de passe PostgreSQL (le conteneur refuse de démarrer sans elle) |
| `DB_USERNAME`         | non         | Identifiant PostgreSQL (`examo` par défaut)                        |
| `ANTHROPIC_API_KEY`   | non         | Correction de copie par IA et explications. Vide = fonctionnalité désactivée proprement (reste du site inchangé). |
| `ELEVENLABS_API_KEY`  | non         | Lecture à voix haute (dictées + bouton « Écouter la question »). Vide = repli automatique sur la synthèse vocale du téléphone. |

### Données persistantes

- `db_data` — la base PostgreSQL.
- `backend_storage` — fichiers importés et cache audio généré par ElevenLabs
  (un texte n'est synthétisé qu'une seule fois, puis réutilisé pour tous les élèves).

Ces volumes survivent à `docker compose down` ; utiliser `docker compose down -v`
pour tout réinitialiser.

## Développement sans Docker

### Backend

Nécessite un PostgreSQL local (base `examo`) et Java 17.

```bash
cd examo_backend
cp secrets.properties.example secrets.properties   # puis renseigner les vraies valeurs
./mvnw spring-boot:run
```

`secrets.properties` est ignoré par git — c'est l'équivalent local de `.env` pour
Docker, lu via `spring.config.import=optional:file:./secrets.properties` dans
`application.properties`.

### App Flutter

```bash
cd examo_app
flutter pub get
flutter run
```

Par défaut, l'app cible `http://10.0.2.2:8080` depuis un émulateur Android et
`http://localhost:8080` ailleurs. Pour viser un autre backend (ex. en production) :

```bash
flutter run --dart-define=API_BASE_URL=https://api.examo.tg
```

## Secrets

Aucune clé API n'est commitée. `secrets.properties` (dev local) et `.env` (Docker)
sont tous deux dans `.gitignore` — copier le fichier `.example` correspondant et
renseigner ses propres valeurs.
