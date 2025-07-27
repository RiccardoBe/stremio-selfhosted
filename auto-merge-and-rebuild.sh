#!/bin/bash
set -e

REPO_DIR="./AIOStreams"
SERVICE_NAME="aiostreams"

echo "🔁 Entrando in $REPO_DIR..."
cd "$REPO_DIR"

# Ensure clean state
git reset --hard
git clean -fd

# Checkout main e fetch upstream
git checkout main
git pull origin main
git fetch upstream

# Backup prima del merge
git checkout -b backup-before-merge-$(date +%F-%H%M)

# Torna su main
git checkout main

# Merge
if git merge --no-edit upstream/main; then
    echo "✅ Merge riuscito, pushing sul fork..."
    git push origin main

    echo "🔨 Ricompilo immagine Docker..."
    cd ../
    docker compose build "$SERVICE_NAME"
    docker compose up -d --no-deps "$SERVICE_NAME"

    echo "🚀 Done."
else
    echo "❌ Merge fallito. Aborting..."
    git merge --abort
    exit 1
fi