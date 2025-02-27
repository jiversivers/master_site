#!/bin/bash

echo "Setting up production environment..."

ENV="$1"
source "$ENV"

# Define path for production .env
PROD_ENV="$DEPLOY_DIR/.env"

# Extract all uncommented lines (common settings)
grep -v '^#' "$ENV" > "$PROD_ENV"

# Extract uncommented production settings and append them
grep '^## Production settings' -A 1000 "$ENV" | sed 's/^# //' >> "$PROD_ENV"
