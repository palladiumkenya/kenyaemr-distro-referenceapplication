# KenyaEMR Reference Application

[![Build and Publish](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/actions/workflows/kenyaemr-distro-build.yml/badge.svg)](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/actions/workflows/kenyaemr-distro-build.yml)

This project holds the build configuration for the KenyaEMR reference application.

## Table of Contents

- [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Maven Settings Configuration](#maven-settings-configuration)
  - [Package and Run](#package-the-distribution-and-prepare-the-run)
  - [Run the Application](#run-the-application)
- [Overview](#overview)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

## Quick start

### Prerequisites

- Docker and Docker Compose installed (Docker Compose version 3.7 or higher)
- Git installed
- At least 4GB RAM available for Docker
- A MySQL dump file of the KenyaEMR database (place it in the `mysql-dump` folder)
- Maven installed (for local development)
- GitHub account with Personal Access Token (required for Maven dependencies)

### Maven Settings Configuration

**Important:** This step must be completed before running `docker compose build` as the build process requires GitHub Packages authentication.

#### Step 1: Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token" → "Generate new token (classic)"
3. Give your token a descriptive name (e.g., "KenyaEMR Maven Access")
4. Select the following scopes:
   - `read:packages` (to download packages from GitHub Packages)
5. Click "Generate token" and copy the token value

#### Step 2: Configure Maven Settings

1. Locate your Maven settings file:

   - **Linux/Mac**: `~/.m2/settings.xml`
   - **Windows**: `%USERPROFILE%\.m2\settings.xml`

2. If the file doesn't exist, create it with this content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>github</id>
            <username>YOUR_GITHUB_USERNAME</username>
            <password>YOUR_GITHUB_TOKEN</password>
        </server>
    </servers>
</settings>
```

3. Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username
4. Replace `YOUR_GITHUB_TOKEN` with the token you created in Step 1

#### Step 3: Copy Settings to Project Directory

```bash
# Navigate to the project directory
cd kenyaemr-distro-referenceapplication

# Copy your Maven settings file to the project directory
cp ~/.m2/settings.xml maven-settings.xml

# On Windows, use:
# copy %USERPROFILE%\.m2\settings.xml maven-settings.xml
```

**Security Note:** The `maven-settings.xml` file is already included in `.gitignore` to prevent accidentally committing your credentials.

### Package the distribution and prepare the run

```bash
# Clone the repository
git clone https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication.git
cd kenyaemr-distro-referenceapplication

# Complete Maven settings configuration (see section above)
# This step is REQUIRED before building

# Create mysql-dump directory if it doesn't exist
mkdir -p mysql-dump

# Place your KenyaEMR database dump file in the mysql-dump directory
# The dump file should be named with .sql extension
# Example: kenyaemr_dump.sql

# Build the distribution (requires Maven settings to be configured first)
docker compose build
```

### Run the application

```bash
# Start the application
docker compose up -d

# To view logs
docker compose logs -f
```

The KenyaEMR UI is accessible at:

- Modern UI (SPA): http://localhost/openmrs/spa
- Legacy UI: http://localhost/openmrs

Default credentials:

- Username: admin
- Password: Admin123

**Environment Variables:**
The application uses the following environment variables (with defaults):

- `OMRS_DB_USER` (default: openmrs)
- `OMRS_DB_PASSWORD` (default: openmrs)
- `MYSQL_ROOT_PASSWORD` (default: openmrs)
- `TAG` (default: qa) - Docker image tag

## Overview

This distribution consists of four main components:

- **db** - MySQL 8.0 database for storing KenyaEMR data (requires initial database dump)
- **backend** - OpenMRS backend with KenyaEMR modules and configurations
- **frontend** - Nginx container serving the KenyaEMR 3.x frontend with SPA configuration
- **gateway** - Nginx reverse proxy that manages routing between frontend and backend services

## Configuration

**Frontend Configuration:**
The frontend is configured with:

- SPA Path: `/openmrs/spa`
- API URL: `/openmrs`
- Config URLs: Multiple configuration files for KenyaHMIS package
- Default Locale: English

**Backend Configuration:**

- Auto database updates enabled
- Web admin module enabled
- Module configurations managed through volumes

**Database Configuration:**

- MySQL 8.0 with UTF8MB4 character set
- Native password authentication
- Automatic initialization from SQL dumps in `mysql-dump/` directory

This project uses the [Initializer](https://github.com/mekomsolutions/openmrs-module-initializer) module
to configure metadata. The Initializer configuration is maintained in a separate repository:

[KenyaHMIS Content Repository](https://github.com/palladiumkenya/openmrs-content-kenyahmis)

The configuration is organized as follows:

- `configuration/` - Contains all backend configurations
  - `frontend/` - Frontend-specific configurations
  - `backend/` - Backend-specific configurations

To help maintain organization, please follow these naming conventions:

- Use `-openmrs.json` suffix config related to openmrs apps
- Use `-kenyaemr.json` suffix for config related to kenyaemr apps

## Troubleshooting

If you encounter any issues:

1. **Build fails with authentication errors:**

   - Verify your GitHub token has `read:packages` permission
   - Ensure `maven-settings.xml` exists in the project root with correct credentials
   - Check that your GitHub token hasn't expired

2. Check if all containers are running:

```bash
docker compose ps
```

3. View container logs:

```bash
docker compose logs [service-name]
```

4. Restart the application:

```bash
docker compose down
docker compose up -d
```

5. Reset the database (WARNING: This will delete all data):

```bash
docker compose down -v
docker compose up -d
```

6. Database initialization issues:

   - Ensure your database dump file is in the `mysql-dump` directory
   - The dump file should be a valid MySQL dump with .sql extension
   - MySQL 8.0 is used with `mysql_native_password` authentication
   - Check the db container logs for any initialization errors:

   ```bash
   docker compose logs db
   ```

7. **Environment variable configuration:**
   - Create a `.env` file in the project root to customize database credentials:
   ```bash
   OMRS_DB_USER=your_username
   OMRS_DB_PASSWORD=your_password
   MYSQL_ROOT_PASSWORD=your_root_password
   TAG=qa
   ```

## Support

For support, please:

1. Check the [KenyaEMR documentation](https://wiki.openmrs.org/display/projects/KenyaEMR)
2. Report issues on the [GitHub repository](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/issues)
