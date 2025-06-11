#!/bin/bash

cd /home/debianuser/Projet_14-05-2025/fake-api-500-user || exit 1

git checkout main

# Ajouter et commit/push automatique si modifications détectées AVANT le pull
if [[ -n $(git status --porcelain) ]]; then
    echo "Des modifications locales détectées, commit et push automatiques…"
    git add -A
    git commit -m "commit auto : sauvegarde locale avant pull"
    git push
fi

# Enregistrer l'état avant le pull pour journaliser les changements
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
