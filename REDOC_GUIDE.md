# Redoc Build and Customization Guide

This guide provides instructions for building a single, unified Redoc documentation site from multiple OpenAPI specification files and customizing its appearance.

---

## The Problem: Why `sh` Fails

The command `sh scripts/build-redoc.sh` fails on Windows because `.sh` files are shell scripts intended for Linux or macOS environments. The Windows command prompt does not know how to execute them.

## The Solution: Bundling Specs

Instead of a simple script, we will use a professional workflow that works on any system. The process involves two steps:

1.  **Bundle**: Combine all your separate OpenAPI files (`flight.yaml`, `hotel.yaml`, etc.) into a single, temporary `bundle.yaml` file.
2.  **Build**: Generate the final `generated-docs.html` from that single bundled file.

This approach ensures all your services appear in one documentation site with a shared navigation menu.

---

## Step 1: Create a Redocly Configuration File

First, create a configuration file named `.redocly.yaml` in the root of your project. This file tells Redocly how to bundle your APIs.

**File: `.redocly.yaml`**
```yaml
# .redocly.yaml
apis:
  main: # This is an alias for your bundled API
    root: openapi/esim.yaml # The entrypoint file
    styleguide:
      rules:
        no-unresolved-refs: error
    features.openapi:
      htmlTemplate: ./docs/index.html
      theme:
        colors:
          primary:
            main: "#3232F0"
        typography:
          headings:
            fontFamily: "'Lato', sans-serif"
          fontFamily: "'Lato', sans-serif"
```

This file does two things:
- Defines `openapi/esim.yaml` as the root file for bundling.
- Includes a `theme` section where you can customize colors, fonts, and more.

---

## Step 2: Create a `package.json` for Scripts

To make the commands easy to run, create a `package.json` file in your project root.

**File: `package.json`**
```json
{
  "name": "api-documentation",
  "version": "1.0.0",
  "description": "API documentation for flight, hotel, and eSIM services.",
  "scripts": {
    "docs:bundle": "npx @redocly/cli bundle main -o openapi/bundle.yaml",
    "docs:build": "npm run docs:bundle && npx @redocly/cli build-docs openapi/bundle.yaml -o redoc/generated-docs.html"
  },
  "author": "",
  "license": "ISC"
}
```

This file defines two scripts:
- `docs:bundle`: Bundles all specs into `openapi/bundle.yaml`.
- `docs:build`: Runs the bundle script, then builds the final HTML.

---

## Step 3: Run the Build

Now, you can build everything with one simple command that works on any platform:

```bash
npm run docs:build
```

This will:
1.  Read your `.redocly.yaml` file.
2.  Bundle all connected OpenAPI files into `openapi/bundle.yaml`.
3.  Build the final `redoc/generated-docs.html` using the theme options you defined.

---

## How to Customize Redoc

-   **Appearance (Colors, Fonts, etc.)**: Modify the `theme` section in the **`.redocly.yaml`** file. You can find all available theme options in the [official Redocly documentation](https://redocly.com/docs/api-reference-docs/configuration/theming/).

-   **Content (Descriptions, Endpoints)**: All content is pulled directly from your `.yaml` OpenAPI files. To change descriptions, summaries, or examples, you must edit the source files (`esim.yaml`, `flight.yaml`, etc.).

-   **Adding a New Service**:
    1.  Add the new spec file (e.g., `openapi/new-service.yaml`).
    2.  Reference it from one of your existing files (e.g., add a `$ref` in `esim.yaml` to a path in `new-service.yaml`).
    3.  Re-run `npm run docs:build`. The bundler will automatically include it.
