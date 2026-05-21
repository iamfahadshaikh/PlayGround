#!/bin/bash

RECIPIENT="$1"
CONTAINER="$2"

HOSTNAME=$(hostname)
DATE=$(date)

if [ -z "$RECIPIENT" ] || [ -z "$CONTAINER" ]; then
    echo "Usage: $0 <recipient_email> <container_name>"
    exit 1
fi

RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)

if [ "$RUNNING" != "true" ]; then

    LOGS=$(docker logs --tail 50 "$CONTAINER" 2>&1)

    {
        echo "Subject: [CONTAINER ALERT] $CONTAINER DOWN on $HOSTNAME"
        echo "Content-Type: text/html"
        echo
        echo "<html><body style='font-family:Arial;'>"
        echo "<h2 style='color:red;'>Container Down Alert</h2>"

        echo "<b>Server:</b> $HOSTNAME<br>"
        echo "<b>Container:</b> $CONTAINER<br>"
        echo "<b>Date:</b> $DATE<br><br>"

        echo "<h3>Last 50 Logs</h3>"
        echo "<pre>$LOGS</pre>"

        echo "</body></html>"
    } | sendmail "$RECIPIENT"

fi
