#!/usr/bin/env bash

set -euo pipefail

# ==========================================
# Application Configuration
# ==========================================

APP_HOME="/opt/cicd-demo-service"
RELEASES_DIR="$APP_HOME/releases"

APP_PORT="${APP_PORT:-8080}"
HEALTH_URL="http://localhost:${APP_PORT}/actuator/health"

MAX_ATTEMPTS=12
RETRY_INTERVAL=5


# ==========================================
# Argument Validation
# ==========================================

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION="$1"
RELEASE_DIR="$RELEASES_DIR/$VERSION"


# ==========================================
# Release Validation
# ==========================================

echo "=== Rollback Validation ==="
echo "Target version: $VERSION"
echo "Release directory: $RELEASE_DIR"

if [ ! -d "$RELEASE_DIR" ]; then
    echo "ERROR: Release does not exist: $VERSION"
    exit 1
fi

if [ ! -f "$RELEASE_DIR/cicd-demo-service.jar" ]; then
    echo "ERROR: Application JAR does not exist in release: $VERSION"
    exit 1
fi


# ==========================================
# Current Release
# ==========================================

echo
echo "=== Current Release ==="

CURRENT_RELEASE=""

if [ -L "$APP_HOME/current" ]; then
    CURRENT_RELEASE=$(readlink -f "$APP_HOME/current")
fi

if [ -n "$CURRENT_RELEASE" ]; then
    echo "Current release: $CURRENT_RELEASE"
else
    echo "No current release found."
fi


# ==========================================
# Switch Release
# ==========================================

echo
echo "=== Switching Release ==="

ln -sfn \
    "$RELEASE_DIR" \
    "$APP_HOME/current"

echo "Current release switched to:"
readlink -f "$APP_HOME/current"


# ==========================================
# Restart Application
# ==========================================

echo
echo "=== Restarting Application ==="

sudo systemctl restart cicd-demo-service

echo "Service restart command completed."


# ==========================================
# Health Check
# ==========================================

echo
echo "=== Waiting for Application Health ==="
echo "Health URL: $HEALTH_URL"

ROLLBACK_SUCCESS=false

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++))
do
    echo "Health check attempt $attempt/$MAX_ATTEMPTS..."

    if curl --silent --fail "$HEALTH_URL" | grep -q '"status":"UP"'; then
        echo
        echo "Application is healthy."

        ROLLBACK_SUCCESS=true
        break
    fi

    echo "Application is not healthy yet."

    if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$RETRY_INTERVAL"
    fi
done


# ==========================================
# Rollback Result
# ==========================================

echo

if [ "$ROLLBACK_SUCCESS" = true ]; then
    echo "=========================================="
    echo "ROLLBACK SUCCESSFUL"
    echo "Version: $VERSION"
    echo "Current release:"
    readlink -f "$APP_HOME/current"
    echo "=========================================="

    exit 0
fi

echo "=========================================="
echo "ROLLBACK FAILED"
echo "Application did not become healthy."
echo "Current release:"
readlink -f "$APP_HOME/current"
echo "=========================================="

exit 1