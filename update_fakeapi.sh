#!/bin/bash

DIR="/chemin/vers/fake-api"
LOG_FILE="$DIR/update.log"
ERROR_LOG_FILE="$DIR/error_update.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

cd "$DIR" || { echo "$DATE : Impossible d'accéder au dossier $DIR" >> "$ERROR_LOG_FILE"; exit 1; }

git checkout main
git fetch origin main

CHANGED_FILES=$(git diff --name-only ..origin/main)

if [ -n "$CHANGED_FILES" ]; then
    git pull
    FILES_AFTER=$(git diff --name-only HEAD@{1})

    # Redémarrer le server (ex: pm2 restart fake-api)
    pm2 restart fake-api
    # Vérifier si le process tourne
    pm2 status fake-api | grep "online" > /dev/null
    if [ $? -eq 0 ]; then
        echo "$DATE : MAJ détectée, fichiers modifiés : $FILES_AFTER. Server redémarré avec succès." >> "$LOG_FILE"
    else
        echo "$DATE : Erreur lors du restart du server." >> "$ERROR_LOG_FILE"
    fi
else
    echo "$DATE : Aucune mise à jour détectée." >> "$LOG_FILE"
fi
