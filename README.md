# API Documentation Project

A self-hosted, production-ready API documentation system using a single OpenAPI 3.0 source of truth, Swagger UI for internal testing, and Redoc for clean public docs. Static, easy to maintain, and deployable on any web server.

## Folder Structure

```
project-root/
├── openapi/
│   └── openapi.yaml
├── swagger/
│   └── docker-compose.yml
├── redoc/
│   └── generated-docs.html
├── scripts/
│   └── build-redoc.sh
└── README.md
```

## Prerequisites

- Docker (for Swagger UI)
- Node.js 16+ or Redocly CLI installed globally

## How To Run Swagger UI

- Change into `swagger/` and start the service:

```
cd swagger
docker compose up -d
```

- Open: `http://localhost:8080`.
- The UI auto-loads `../openapi/openapi.yaml` as the API definition.

## How To Build Redoc Docs

- Run the provided build script from the project root:

```
sh scripts/build-redoc.sh
```

- Output: `redoc/generated-docs.html` (single HTML file). Re-run this when `openapi/openapi.yaml` changes.
- Alternative without the script:

```
npx @redocly/cli build-docs openapi/openapi.yaml -o redoc/generated-docs.html
```

## Deployment

- Copy these items to your web root:
  - `redoc/generated-docs.html`
  - `openapi/openapi.yaml`

- Example Nginx snippet:

```
server {
  listen 80;
  server_name docs.example.com;
  root /var/www/api-docs;

  location /docs {
    alias /var/www/api-docs/redoc;
    index generated-docs.html;
  }

  location /openapi {
    alias /var/www/api-docs/openapi;
  }
}
```

- For Apache, place both files under `DocumentRoot` and ensure `generated-docs.html` is reachable. No server-side execution required.

## Update Workflow

1. Edit `openapi/openapi.yaml`.
2. Test interactively with Swagger UI at `http://localhost:8080`.
3. Rebuild Redoc static file:
   - `sh scripts/build-redoc.sh`
4. Commit and deploy the updated `openapi.yaml` and `generated-docs.html`.

## Architecture Notes

- Single source of truth: `openapi/openapi.yaml`.
- Swagger UI is containerized for consistency and quick local testing.
- Redoc builds a single-file HTML suitable for static hosting and CDN caching.
- Paths and filenames are stable to simplify automation and CI/CD.

## Security

- Endpoints use Bearer token authentication (`bearerAuth`).
- Do not embed secrets in the repository or the OpenAPI examples.

## Troubleshooting

- Swagger UI not loading spec: verify the volume mount in `swagger/docker-compose.yml` and that `openapi/openapi.yaml` exists.
- Redoc build issues: ensure Node.js is installed or install Redocly CLI globally.


<!-- 
- http://localhost:8080/?urls.primaryName=Flight%20API
- Hotel:

http://localhost:8080/?urls.primaryName=Hotel%20API
- eSIM:

http://localhost:8080/?urls.primaryName=eSIM%20API -->