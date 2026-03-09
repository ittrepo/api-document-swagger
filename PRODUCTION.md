# Production Deployment Guide: Apache VPS

This guide provides step-by-step instructions for hosting the API Documentation project on an existing Apache VPS under the domain `api.innotraveltech.com`.

---

## 1. Directory Structure

On your VPS, create a dedicated directory for the project. This ensures isolation from other projects.

```bash
# Recommended path
/var/www/api-docs/
├── openapi/          # Contains YAML files
├── redoc/            # Contains generated HTML
├── services/         # Contains index.html
└── .htaccess         # Optional: for specific rules
```

## 2. DNS Configuration

Point your domain and subdomain to the VPS IP address:

| Record Type | Host | Value |
| :--- | :--- | :--- |
| A | api | [VPS_IP_ADDRESS] |
| A | docs.api | [VPS_IP_ADDRESS] (Optional for separate docs domain) |

---

## 3. Apache Virtual Host Configuration

Create a new configuration file: `/etc/apache2/sites-available/api.innotraveltech.com.conf`.

### Strategy A: Integrated within `api.innotraveltech.com` (Recommended)
This serves the API documentation as a subpath (e.g., `api.innotraveltech.com/docs`).

```apache
<VirtualHost *:80>
    ServerName api.innotraveltech.com
    DocumentRoot /var/www/api-docs

    # Serve Redoc at /docs
    Alias /docs /var/www/api-docs/redoc/generated-docs.html

    # Serve the services directory at /services
    Alias /services /var/www/api-docs/services/index.html

    # Serve OpenAPI specs at /openapi
    <Directory "/var/www/api-docs/openapi">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    # Logging
    ErrorLog ${APACHE_LOG_DIR}/api_docs_error.log
    CustomLog ${APACHE_LOG_DIR}/api_docs_access.log combined
</VirtualHost>
```

### Strategy B: Separate Subdomain `docs.api.innotraveltech.com`
Useful if you want a cleaner separation of documentation from the actual API gateway.

```apache
<VirtualHost *:80>
    ServerName docs.api.innotraveltech.com
    DocumentRoot /var/www/api-docs/redoc

    DirectoryIndex generated-docs.html

    <Directory "/var/www/api-docs/redoc">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

---

## 4. SSL Certificate Setup (Certbot)

Run Certbot to enable HTTPS:

```bash
sudo apt update
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d api.innotraveltech.com -d docs.api.innotraveltech.com
```

Certbot will automatically update your virtual host file with SSL configurations and redirect HTTP to HTTPS.

---

## 5. Firewall Rules

Ensure ports 80 (HTTP) and 443 (HTTPS) are open:

```bash
sudo ufw allow 'Apache Full'
sudo ufw reload
```

---

## 6. Deployment Automation Script

Create a script `deploy.sh` on the VPS to pull changes and rebuild docs:

```bash
#!/bin/bash
# deploy.sh

cd /var/www/api-docs
git pull origin main

# Rebuild Redoc
npx @redocly/cli build-docs openapi/openapi.yaml -o redoc/generated-docs.html

# Fix permissions
sudo chown -R www-data:www-data /var/www/api-docs
```

---

## 7. Health Check Endpoints

Verify the deployment by checking these URLs:

1.  **Redoc:** `https://api.innotraveltech.com/docs` (Should load the static Redoc page)
2.  **OpenAPI Spec:** `https://api.innotraveltech.com/openapi/openapi.yaml` (Should be downloadable/viewable)
3.  **Services:** `https://api.innotraveltech.com/services/` (Should load the directory index)

---

## 8. Rollback Procedures

1.  **Git Rollback:** `git checkout [PREVIOUS_COMMIT_HASH]`
2.  **Config Rollback:** Keep backups of your `.conf` files. If a new config fails, revert to the backup and reload Apache: `sudo systemctl reload apache2`.

---

## 9. Testing Procedures

-   **Zero-Downtime Check:** Use `apache2ctl configtest` before reloading to ensure no syntax errors.
-   **Isolation Test:** Verify that other sites on the same VPS (e.g., `another-project.com`) still function correctly.
-   **SSL Test:** Use [SSLLabs](https://www.ssllabs.com/ssltest/) to verify certificate validity.
