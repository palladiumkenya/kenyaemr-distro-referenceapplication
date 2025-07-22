#!/bin/bash

# Script to create database snapshots from running containers for e2e testing
# Usage: ./create-e2e-images.sh [container_name_or_id] [tag_name]

set -e

# Default values
DEFAULT_TAG="snapshot"
IMAGE_NAME="kenyahmis/openmrs-reference-application-3-database-withdata"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [container_name_or_id] [tag_name]"
    echo ""
    echo "Arguments:"
    echo "  container_name_or_id    Name or ID of the running database container"
    echo "  tag_name               Tag for the snapshot image (default: snapshot)"
    echo ""
    echo "Examples:"
    echo "  $0 my-db-container"
    echo "  $0 abc123def production-snapshot"
    echo "  $0 kenyahmis_openmrs-reference-application-3-database-withdata_1 test-data"
    echo ""
    echo "To find running containers:"
    echo "  docker ps | grep database"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Parse arguments
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

CONTAINER_ID_OR_NAME=$1
TAG_NAME=${2:-$DEFAULT_TAG}

# Validate container exists and is running
if ! docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" | grep -q "$CONTAINER_ID_OR_NAME"; then
    print_error "Container '$CONTAINER_ID_OR_NAME' is not running or does not exist."
    echo ""
    print_info "Available running containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    exit 1
fi

# Get container ID and name
CONTAINER_INFO=$(docker ps --format "{{.ID}}\t{{.Names}}" | grep "$CONTAINER_ID_OR_NAME")
CONTAINER_ID=$(echo "$CONTAINER_INFO" | cut -f1)
CONTAINER_NAME=$(echo "$CONTAINER_INFO" | cut -f2)

print_info "Found container: $CONTAINER_NAME (ID: $CONTAINER_ID)"

# Check if container is a database container
if ! echo "$CONTAINER_NAME" | grep -q "database\|mysql\|mariadb"; then
    print_warning "Container '$CONTAINER_NAME' doesn't appear to be a database container."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled."
        exit 0
    fi
fi

# Create snapshot
FULL_IMAGE_NAME="$IMAGE_NAME:$TAG_NAME"

print_info "Creating snapshot from container $CONTAINER_ID..."
print_info "Target image: $FULL_IMAGE_NAME"

# Create the snapshot
docker commit "$CONTAINER_ID" "$FULL_IMAGE_NAME"

if [ $? -eq 0 ]; then
    print_info "Snapshot created successfully!"
    
    # Show image info
    print_info "Image details:"
    docker images "$FULL_IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    # Show next steps
    echo ""
    print_info "Next steps:"
    echo "1. Update docker-compose-snapshot.yml to use: $FULL_IMAGE_NAME"
    echo "2. Run: docker-compose -f docker-compose-snapshot.yml up -d"
    echo ""
    print_info "To use this snapshot in your e2e tests, update the db service in docker-compose-snapshot.yml:"
    echo "  db:"
    echo "    image: $FULL_IMAGE_NAME"
    echo "    # ... rest of configuration"
    
else
    print_error "Failed to create snapshot from container $CONTAINER_ID"
    exit 1
fi

# Optional: Show how to push to registry
echo ""
print_info "To push this snapshot to a registry:"
echo "  docker tag $FULL_IMAGE_NAME your-registry/$FULL_IMAGE_NAME"
echo "  docker push your-registry/$FULL_IMAGE_NAME" 