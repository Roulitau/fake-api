#!/bin/bash

ERROR_LOG_FILE="/chemin/vers/fake-api/error_service.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
SERVICES=("nginx" "pm2")

function restart_service {
    systemctl restart $1
    if systemctl is-active --quiet $1; then
        echo "$DATE : Service $1 relancé avec succès." >> "$ERROR_LOG_FILE"
    else
        echo "$DATE : Echec de relance de $1." >> "$ERROR_LOG_FILE"
        systemctl status $1 >> "$ERROR_LOG_FILE"
    fi
}

# Vérifier nginx
if ! systemctl is-active --quiet nginx; then
    echo "$DATE : nginx KO, tentative de relance." >> "$ERROR_LOG_FILE"
    restart_service nginx
fi

# Vérifier pm2 (en tant qu'utilisateur, souvent pm2 est global ou sous un user spécifique, à adapter!)
pm2 status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$DATE : pm2 KO, tentative de relance." >> "$ERROR_LOG_FILE"
    # Exemple si pm2 est dans le PATH de root
    restart_service pm2
fi

# Vérifier le server sur pm2
pm2 status fake-api | grep "online" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$DATE : fake-api PM2 KO, tentative restart." >> "$ERROR_LOG_FILE"
    pm2 restart fake-api
    pm2 status fake-api | grep "online" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$DATE : fake-api relancé avec succès." >> "$ERROR_LOG_FILE"
    else
        echo "$DATE : Echec du restart de fake-api sur pm2." >> "$ERROR_LOG_FILE"
    fi
fi

