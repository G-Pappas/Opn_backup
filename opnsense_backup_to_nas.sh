#!/bin/sh

# Backup settings
BACKUP_DIR="/mnt/opnsense_backup"
BACKUP_FILE="opnsense-config-$(date +%Y%m%d-%H%M%S).xml"
MAX_BACKUPS=10
LOG_FILE="/home/backup.log"

# Ensure backup directory exists
if ! mkdir -p "$BACKUP_DIR"; then
    echo "$(date) - ERROR: Failed to create $BACKUP_DIR" >> "$LOG_FILE"
    exit 1
fi

# Generate config backup
echo "$(date) - Creating OPNsense backup..." >> "$LOG_FILE"
if ! php /usr/local/etc/inc/backup.inc dump > "$BACKUP_DIR/$BACKUP_FILE"; then
    echo "$(date) - ERROR: Failed to create backup file" >> "$LOG_FILE"
    exit 1
fi

# Set proper permissions
chmod 600 "$BACKUP_DIR/$BACKUP_FILE"

# Clean up old backups
echo "$(date) - Cleaning up old backups..." >> "$LOG_FILE"
ls -t "$BACKUP_DIR"/opnsense-config-*.xml 2>/dev/null | tail -n +$(($MAX_BACKUPS + 1)) | while read -r old_backup; do
    rm -f "$old_backup"
    echo "$(date) - Deleted: $old_backup" >> "$LOG_FILE"
done

# Verify
CURRENT_BACKUPS=$(ls -1 "$BACKUP_DIR"/opnsense-config-*.xml 2>/dev/null | wc -l)
echo "$(date) - Backup complete: $BACKUP_DIR/$BACKUP_FILE" >> "$LOG_FILE"
echo "$(date) - Total backups kept: $CURRENT_BACKUPS (max: $MAX_BACKUPS)" >> "$LOG_FILE"
