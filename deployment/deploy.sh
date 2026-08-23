#!/usr/bin/env bash

set -euo pipefail

# ==========================================
# Application Configuration
# ==========================================

APP_HOME="/opt/cicd-demo-service"
RELEASES_DIR="$APP_HOME/releases"
CURRENT_LINK="$APP_HOME/current"

JAR_NAME="cicd-demo-service.jar"
SERVICE_NAME="cicd-demo-service"

# ==========================================
# Argument Validation
# ==========================================

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <artifact-path> <version>"
    exit 1
fi

ARTIFACT_PATH="$1"
VERSION="$2"

RELEASE_DIR="$RELEASES_DIR/$VERSION"

# ==========================================
# Deployment Validation
# ==========================================

echo "=== Deployment Validation ==="
echo "Artifact: $ARTIFACT_PATH"
echo "Version: $VERSION"
echo "Release directory: $RELEASE_DIR"

# Check artifact exists
if [ ! -f "$ARTIFACT_PATH" ]; then
    echo "ERROR: Artifact does not exist: $ARTIFACT_PATH"
    exit 1
fi

# Check artifact is readable
if [ ! -r "$ARTIFACT_PATH" ]; then
    echo "ERROR: Artifact is not readable: $ARTIFACT_PATH"
    exit 1
fi

# Prevent overwriting an existing immutable release
if [ -e "$RELEASE_DIR" ]; then
    echo "ERROR: Release version already exists: $VERSION"
    exit 1
fi

# ==========================================
# Identify Previous Release
# ==========================================

echo
echo "=== Current Release ==="

PREVIOUS_RELEASE=""

if [ -L "$CURRENT_LINK" ]; then
    PREVIOUS_RELEASE=$(readlink -f "$CURRENT_LINK")
fi

if [ -n "$PREVIOUS_RELEASE" ]; then
    echo "Previous release: $PREVIOUS_RELEASE"
else
    echo "No previous release found"
fi

echo
echo "Artifact validation successful."
echo "Release version is available for deployment."

# ==========================================
# Create New Release
# ==========================================

echo
echo "=== Creating Release ==="

mkdir -p "$RELEASE_DIR"

echo "Copying artifact..."

cp "$ARTIFACT_PATH" "$RELEASE_DIR/$JAR_NAME"

# Ensure correct ownership and permissions
chown deploy:deploy "$RELEASE_DIR/$JAR_NAME"
chmod 644 "$RELEASE_DIR/$JAR_NAME"

# ==========================================
# Verify Release Artifact
# ==========================================

echo
echo "=== Release Artifact ==="

ls -lh "$RELEASE_DIR/$JAR_NAME"

echo
echo "=== SHA-256 Checksum ==="

CHECKSUM=$(sha256sum "$RELEASE_DIR/$JAR_NAME" | awk '{print $1}')

echo "$CHECKSUM"

echo
echo "=== Release Created Successfully ==="
echo "Version: $VERSION"
echo "Release path: $RELEASE_DIR"
echo "Checksum: $CHECKSUM"

# ==========================================
# Activate New Release
# ==========================================

echo
echo "=== Activating Release ==="

ln -sfn \
    "$RELEASE_DIR" \
    "$CURRENT_LINK"

echo "Current release switched to:"
readlink -f "$CURRENT_LINK"

# ==========================================
# Restart Application
# ==========================================

echo
echo "=== Restarting Application ==="

sudo systemctl restart "$SERVICE_NAME"

echo "Service restart command completed."

# ==========================================
# Health Check Configuration
# ==========================================

APP_PORT="${APP_PORT:-8080}"
HEALTH_URL="http://localhost:${APP_PORT}/actuator/health"

MAX_ATTEMPTS=12
RETRY_INTERVAL=5

# ==========================================
# Health Check
# ==========================================

echo
echo "=== Waiting for Application Health ==="
echo "Health URL: $HEALTH_URL"

DEPLOYMENT_SUCCESS=false

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++))
do
    echo "Health check attempt $attempt/$MAX_ATTEMPTS..."

    if curl --silent --fail "$HEALTH_URL" | grep -q '"status":"UP"'; then
        echo
        echo "Application is healthy."

        DEPLOYMENT_SUCCESS=true
        break
    fi

    echo "Application is not healthy yet."

    if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$RETRY_INTERVAL"
    fi
done

# ==========================================
# Deployment Result
# ==========================================

if [ "$DEPLOYMENT_SUCCESS" = true ]; then
    echo
    echo "=========================================="
    echo "Deployment successful."
    echo "Version: $VERSION"
    echo "Release path: $RELEASE_DIR"
    echo "Checksum: $CHECKSUM"
    echo "=========================================="

    exit 0
fi

# ==========================================
# Automatic Rollback
# ==========================================

echo
echo "=========================================="
echo "ERROR: Deployment failed health check."
echo "Starting automatic rollback..."
echo "=========================================="

if [ -z "$PREVIOUS_RELEASE" ] || [ ! -d "$PREVIOUS_RELEASE" ]; then
    echo
    echo "ERROR: No valid previous release available for rollback."
    echo "Failed release retained at: $RELEASE_DIR"

    exit 1
fi

echo
echo "Previous release: $PREVIOUS_RELEASE"

echo
echo "=== Restoring Previous Release ==="

ln -sfn \
    "$PREVIOUS_RELEASE" \
    "$CURRENT_LINK"

echo "Current release restored to:"
readlink -f "$CURRENT_LINK"

echo
echo "=== Restarting Application After Rollback ==="

sudo systemctl restart "$SERVICE_NAME"

echo "Rollback restart command completed."

# ==========================================
# Verify Rollback Health
# ==========================================

echo
echo "=== Verifying Rollback Health ==="

ROLLBACK_SUCCESS=false

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++))
do
    echo "Rollback health check attempt $attempt/$MAX_ATTEMPTS..."

    if curl --silent --fail "$HEALTH_URL" | grep -q '"status":"UP"'; then
        echo
        echo "Rollback application is healthy."

        ROLLBACK_SUCCESS=true
        break
    fi

    echo "Rollback application is not healthy yet."

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
    echo "Previous release restored:"
    readlink -f "$CURRENT_LINK"
    echo "=========================================="

    echo
    echo "Deployment failed, but the previous release was restored."

    # Deployment failed even though rollback succeeded
    exit 1
else
    echo "=========================================="
    echo "ROLLBACK FAILED"
    echo "Manual investigation is required."
    echo "Current release:"
    readlink -f "$CURRENT_LINK"
    echo "=========================================="

    exit 1
fi