# ReDoc Generation Process Guide

This guide explains how to use the existing tools in your project to generate and update your API documentation from OpenAPI (YAML) files.

## 1. The Build Script ([scripts/build-redoc.sh](file:///c:/Users/mdmah/Downloads/api-document-swagger/scripts/build-redoc.sh))

Your current [build-redoc.sh](file:///c:/Users/mdmah/Downloads/api-document-swagger/scripts/build-redoc.sh) script is the automation engine. It uses the **Redocly CLI** to convert your YAML files into a high-quality, standalone HTML document.

### How it works:
```bash
npx --yes @redocly/cli build-docs openapi/openapi.yaml -o redoc/generated-docs.html
```
- **`npx @redocly/cli build-docs`**: This command downloads and runs the latest Redocly tool.
- **[openapi/openapi.yaml](file:///c:/Users/mdmah/Downloads/api-document-swagger/openapi/openapi.yaml)**: This is the INPUT (your API specification).
- **`-o redoc/generated-docs.html`**: This specifies the OUTPUT file name.

## 2. Generating Documentation for Other Services

Since you have multiple services (Flight, Hotel, eSIM, etc.), you can run the same command for each one. 

### Commands for each service:
| Service | Command |
| :--- | :--- |
| **Combined** | `npx @redocly/cli build-docs openapi/openapi.yaml -o redoc/openapi.html` |
| **Flight** | `npx @redocly/cli build-docs openapi/flight.yaml -o redoc/flight-redoc.html` |
| **Hotel** | `npx @redocly/cli build-docs openapi/hotel.yaml -o redoc/hotel-redoc.html` |
| **eSIM** | `npx @redocly/cli build-docs openapi/esim.yaml -o redoc/esim.html` |
| **Visa** | `npx @redocly/cli build-docs openapi/Visa.yaml -o redoc/visa.html` |

> [!TIP]
> **Why use the CLI?**
> The CLI generates a **standalone** HTML file. This means all the styles and icons are embedded inside the file. You don't need an internet connection to view it once it's generated.

## 3. Automation: Generating Everything at Once

Use the `build-all-docs.sh` script to update all API documentation files and the central portal with a single command.

```bash
sh scripts/build-all-docs.sh
```

### What this script does:
1.  **Builds 8 Services**: Generates HTML for Flight, Hotel, eSIM, Visa, etc.
2.  **Instruments UI**: Automatically injects a **"Back to Home"** button into every generated page.
3.  **Updates Portal**: Ensures the `redoc/index.html` portal is ready for viewing.

## 4. Production Deployment

When deploying to production (e.g., `api.innotraveltech.com`), follow these steps:

1.  Pull the latest changes on your VPS.
2.  Run `sh scripts/build-all-docs.sh`.
3.  Ensure your Apache/Nginx configuration points to `redoc/index.html` as the main entry point.

Refer to [PRODUCTION.md](PRODUCTION.md) for detailed server configuration.
