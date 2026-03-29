# Production Installation: api.innotraveltech.com

This README provides the installation steps for deploying the API Documentation project to a production Apache VPS.

---

## 1. Initial Setup

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/innotraveltech/api-docs.git /var/www/api-docs
    ```

2.  **Install Dependencies:**
    Ensure Node.js is installed to use the Redocly CLI for building documentation.
    ```bash
    npm install -g @redocly/cli
    ```

## 2. Generate Production Assets

1.  **Build Documentation:**
    ```bash
    cd /var/www/api-docs
    sh scripts/build-all-docs.sh
    ```

2.  **Set Permissions:**
    ```bash
    sudo chown -R www-data:www-data /var/www/api-docs
    sudo chmod -R 755 /var/www/api-docs
    ```

## 3. Configure Apache Virtual Host

1.  **Create Config File:** `/etc/apache2/sites-available/api.innotraveltech.com.conf`
2.  **Add Configuration:** Refer to the [PRODUCTION.md](PRODUCTION.md) guide for the specific virtual host configuration block.
3.  **Enable Site:**
    ```bash
    sudo a2ensite api.innotraveltech.com.conf
    sudo a2enmod proxy proxy_http rewrite ssl headers
    sudo systemctl reload apache2
    ```

## 4. Setup SSL (HTTPS)

1.  **Run Certbot:**
    ```bash
    sudo certbot --apache -d api.innotraveltech.com
    ```

## 5. Verification Checklist

- [ ] `https://api.innotraveltech.com/docs` loads Redoc.
- [ ] `https://api.innotraveltech.com/services/` loads the service directory.
- [ ] `https://api.innotraveltech.com/openapi/openapi.yaml` is accessible.
- [ ] All other websites on the VPS remain online.

---

For detailed configuration options and rollback instructions, see [PRODUCTION.md](PRODUCTION.md).
