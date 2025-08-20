#!/bin/bash
set -e

declare -A SERVICES
SERVICES["AIOStreams"]="aiostreams"
SERVICES["mediaflow-proxy"]="mediaflow_proxy"
SERVICES["streamvix"]="streamv"

BASE_DIR="/home/pi/stremio-selfhosted"
UPDATED_SERVICES=()

for REPO_NAME in "${!SERVICES[@]}"; do
    SERVICE_NAME=${SERVICES[$REPO_NAME]}
    REPO_DIR="$BASE_DIR/$REPO_NAME"
    BACKUP_BRANCH="backup-before-merge-$(date +%F-%H%M)"

    echo ""
    echo "🔁 [$SERVICE_NAME] Entrando in $REPO_DIR..."
    cd "$REPO_DIR"

    git reset --hard
    git clean -fd
    git checkout main
    git pull origin main
    git fetch upstream

    echo "🔒 Creo backup branch: $BACKUP_BRANCH"
    git checkout -b "$BACKUP_BRANCH"
    git checkout main

    echo "🔀 Merge con upstream/main..."
    if git merge --no-edit upstream/main; then
        echo "✅ Merge riuscito per $SERVICE_NAME"
        git push origin main
        git branch -D "$BACKUP_BRANCH"

        # Segna che questo servizio va rebuildato
        UPDATED_SERVICES+=("$SERVICE_NAME")
    else
        echo "❌ Merge fallito per $SERVICE_NAME. Aborting..."
        git merge --abort
        echo "📌 Rimasto su $BACKUP_BRANCH per recupero."
    fi
done

# Fase di build e up, se necessario
if [ ${#UPDATED_SERVICES[@]} -gt 0 ]; then
    echo ""
    echo "🔨 Ricompilazione immagini Docker per: ${UPDATED_SERVICES[*]}"
    cd "$BASE_DIR"
    docker compose build "${UPDATED_SERVICES[@]}"
    docker compose up -d --no-deps "${UPDATED_SERVICES[@]}"
    echo "🚀 Aggiornamento completato per: ${UPDATED_SERVICES[*]}"
else
    echo "✅ Nessun aggiornamento necessario. Tutto già aggiornato."
fi