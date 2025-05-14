#!/bin/bash

cd /home/debianuser/Projet_14-05-2025/fake-api || exit 1

git checkout main

# sauver les fichiers modifiés avant le pull
MODIFIED_BEFORE=$(git status -s)

git pull

# comparer après pull
MODIFIED_AFTER=$(git status -s)

if [ "$MODIFIED_BEFORE" != "$MODIFIED_AFTER" ]; then
    # Modifications détectées, tentative de restart du server sous pm2
    pm2 restart fake-api
    sleep 5
    pm2 show fake-api | grep "status" | grep -q "online"
    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') : Pull & restart effectué avec succès." >> ~/update_success.log
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') : Erreur lors du redémarrage du server après pull!" >> ~/update_error.log
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') : Aucun changement après git pull." >> ~/update_success.log
fi
