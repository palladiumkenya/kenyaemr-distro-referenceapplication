# KenyaEMR Reference Application

[![Build and Publish](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/actions/workflows/kenyaemr-distro-build.yml/badge.svg)](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/actions/workflows/kenyaemr-distro-build.yml)

This project holds the build configuration for the KenyaEMR reference application.

## Quick start

### Prerequisites
- Docker and Docker Compose installed
- Git installed
- At least 4GB RAM available for Docker
- A MySQL dump file of the KenyaEMR database (place it in the `mysql-dump` folder)

### Package the distribution and prepare the run

```bash
# Clone the repository
git clone https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication.git
cd kenyaemr-distro-referenceapplication

# Create mysql-dump directory if it doesn't exist
mkdir -p mysql-dump

# Place your KenyaEMR database dump file in the mysql-dump directory
# The dump file should be named with .sql extension
# Example: kenyaemr_dump.sql

# Build the distribution
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
- Modern UI: http://localhost/openmrs/spa
- Legacy UI: http://localhost/openmrs

Default credentials:
- Username: admin
- Password: Admin123

## Running Ethiopia EMR Instance

This section explains how to configure and run the application with Ethiopia EMR content packages instead of the default KenyaEMR packages.

### Prerequisites
- Follow the [Quick start](#quick-start) section to set up the basic environment
- Ensure you have the Ethiopia EMR database dump file (place it in the `mysql-dump` folder)

### Configuration Changes

Before running the Ethiopia instance, you need to modify the content package configuration:

#### 1. Update distro.properties
In `distro/distro.properties`, ensure the Ethiopia content package is enabled and KenyaHMIS is commented out:

```properties
# Comment out KenyaHMIS content package
# content.kenyahmis-package=${kenyahmis-package.version}
# content.kenyahmis-package.groupId=org.kenyahmis.content

# Enable Ethiopia content package
content.ethiopiaemr-package=${ethiopiaemr-package.version}
content.ethiopiaemr-package.groupId=org.ethiopiaemr.content
```

#### 2. Update pom.xml
In `distro/pom.xml`, ensure the Ethiopia dependency is enabled and KenyaHMIS is commented out:

```xml
<!-- Comment out KenyaHMIS dependency -->
<!--
<dependency>
  <groupId>org.kenyahmis.content</groupId>
  <artifactId>kenyahmis-package</artifactId>
  <version>${kenyahmis-package.version}</version>
  <type>zip</type>
</dependency>
-->

<!-- Enable Ethiopia dependency -->
<dependency>
  <groupId>org.ethiopiaemr.content</groupId>
  <artifactId>ethiopiaemr-package</artifactId>
  <version>${ethiopiaemr-package.version}</version>
  <type>zip</type>
</dependency>
```

### Build and Run

#### Option 1: Using Environment Variables (Recommended)

```bash
# Build with Ethiopia configuration
SPA_CONFIG_URLS=/openmrs/spa/config/configs/ethiopiaemr-package/openmrs.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/kenyaemr.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/translations/translations.json \
SPA_PAGE_TITLE='Ethiopia EMR' \
docker compose build

# Start the application
SPA_CONFIG_URLS=/openmrs/spa/config/configs/ethiopiaemr-package/openmrs.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/kenyaemr.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/translations/translations.json \
SPA_PAGE_TITLE='Ethiopia EMR' \
docker compose up -d
```

#### Option 2: Using .env File

Create a `.env` file in the project root:

```bash
# .env
SPA_CONFIG_URLS=/openmrs/spa/config/configs/ethiopiaemr-package/openmrs.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/kenyaemr.config.json,/openmrs/spa/config/configs/ethiopiaemr-package/translations/translations.json
SPA_PAGE_TITLE=Ethiopia EMR
```

Then run:
```bash
docker compose build
docker compose up -d
```

### Access the Application

The Ethiopia EMR UI is accessible at:
- Modern UI: http://localhost/openmrs/spa
- Legacy UI: http://localhost/openmrs

Default credentials:
- Username: admin
- Password: Admin123

### Switching Back to KenyaEMR

To switch back to KenyaEMR configuration:

1. Reverse the configuration changes in `distro.properties` and `pom.xml`
2. Use the default environment variables or remove the `.env` file
3. Rebuild and restart the application:

```bash
docker compose build
docker compose up -d
```

## Overview

This distribution consists of four main components:

* db - MariaDB database for storing KenyaEMR data (requires initial database dump)
* backend - OpenMRS backend with KenyaEMR modules and configurations
* frontend - Nginx container serving the KenyaEMR 3.x frontend
* gateway - Nginx reverse proxy that manages routing between frontend and backend services

## Configuration

This project uses the [Initializer](https://github.com/mekomsolutions/openmrs-module-initializer) module
to configure metadata. The Initializer configuration is maintained in a separate repository:

[KenyaHMIS Content Repository](https://github.com/palladiumkenya/openmrs-content-kenyahmis)

The configuration is organized as follows:
- `configuration/` - Contains all backend configurations
  - `frontend/` - Frontend-specific configurations
  - `backend/` - Backend-specific configurations

To help maintain organization, please follow these naming conventions:
- Use `-core_demo` suffix for demo data files
- Use `-core_data` suffix for core configuration files

## Troubleshooting

If you encounter any issues:

1. Check if all containers are running:
```bash
docker compose ps
```

2. View container logs:
```bash
docker compose logs [service-name]
```

3. Restart the application:
```bash
docker compose down
docker compose up -d
```

4. Reset the database (WARNING: This will delete all data):
```bash
docker compose down -v
docker compose up -d
```

5. Database initialization issues:
   - Ensure your database dump file is in the `mysql-dump` directory
   - The dump file should be a valid MySQL dump with .sql extension
   - Check the db container logs for any initialization errors:
   ```bash
   docker compose logs db
   ```

## Support

For support, please:
1. Check the [KenyaEMR documentation](https://wiki.openmrs.org/display/projects/KenyaEMR)
2. Report issues on the [GitHub repository](https://github.com/palladiumkenya/kenyaemr-distro-referenceapplication/issues)
