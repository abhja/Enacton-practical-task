#!/bin/bash

PROJECT_DIR="/root/enacton"            
BACKUP_DIR="/root/enacton/backup"      
GDRIVE_FOLDER="gdrive:/backups"        
WEBHOOK_URL="https://webhook.site/f3e21f38-322b-494c-81ef-f9994b244999"
SEND_NOTIFICATION=true                 
RETENTION_DAYS=7                      
RETENTION_WEEKS=4                     
RETENTION_MONTHS=3                      

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
