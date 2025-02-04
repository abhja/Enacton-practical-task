#!/bin/bash

PROJECT_DIR="/root/enacton"            # Folder to back up
BACKUP_DIR="/root/enacton/backup"      # Where to store backups
GDRIVE_FOLDER="gdrive:/backups"        # Google Drive folder (configured via rclone)
WEBHOOK_URL="https://webhook.site/f3e21f38-322b-494c-81ef-f9994b244999"
SEND_NOTIFICATION=true                 # Set to false to disable webhook
RETENTION_DAYS=7                       # Keep last 7 daily backups
RETENTION_WEEKS=4                      # Keep last 4 weekly backups
RETENTION_MONTHS=3                      # Keep last 3 monthly backups

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.zip"

mkdir -p "$BACKUP_DIR"

echo "Creating backup..."
zip -r "$BACKUP_FILE" "$PROJECT_DIR" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Backup failed!" | tee -a "$BACKUP_DIR/backup.log"
    exit 1
fi

echo "Uploading to Google Drive..."
rclone copy "$BACKUP_FILE" "$GDRIVE_FOLDER" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Upload failed!" | tee -a "$BACKUP_DIR/backup.log"
    exit 1
fi

echo "Deleting old backups..."
find "$BACKUP_DIR" -type f -name "backup_*.zip" -mtime +$RETENTION_DAYS -exec rm {} \;
find "$BACKUP_DIR" -type f -name "backup_*.zip" -mtime +$((RETENTION_WEEKS * 7)) -exec rm {} \;
find "$BACKUP_DIR" -type f -name "backup_*.zip" -mtime +$((RETENTION_MONTHS * 30)) -exec rm {} \;

if [ "$SEND_NOTIFICATION" = true ]; then
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
      -d '{"project": "Enacton", "date": "'"$TIMESTAMP"'", "status": "Backup Successful"}' "$WEBHOOK_URL")

    if [ "$RESPONSE" -ne 200 ]; then
        echo "Webhook notification failed!" | tee -a "$BACKUP_DIR/backup.log"
    fi
fi

echo "$TIMESTAMP - Backup completed successfully." >> "$BACKUP_DIR/backup.log"
echo "Backup process finished!"
