#!/bin/bash

LOGFILE=~/services_error.log

function check_and_restart {
    SERVICE=$1
    RESTART_CMD=$2
    STATUS_CMD=$3

    if ! eval "$STATUS_CMD" > /dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') : $SERVICE KO. Tentative de restart..." >> $LOGFILE
        if eval "$RESTART_CMD"; then
            sleep 3
            if eval "$STATUS_CMD" > /dev/null 2>&1; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') : $SERVICE redémarré avec succès." >> $LOGFILE
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') : ECHEC restart $SERVICE (toujours KO)." >> $LOGFILE
            fi
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') : ECHEC commande restart $SERVICE." >> $LOGFILE
        fi
    fi
}

# Exemples de commandes de vérification
check_and_restart "nginx" "sudo systemctl restart nginx" "systemctl is-active --quiet nginx"
check_and_restart "pm2" "pm2 resurrect" "pm2 ping"
check_and_restart "fake-api (pm2)" "pm2 restart fake-api" "pm2 show fake-api | grep -q 'online'"
