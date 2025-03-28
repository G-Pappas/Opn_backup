#!/bin/sh

# Backup settings
BACKUP_DIR="/mnt/opnsense_backup"
BACKUP_FILE="opnsense-config-$(date +%Y%m%d-%H%M%S).xml"
MAX_BACKUPS=10  # Number of backups to retain

# Create backup directory if missing
mkdir -p "$BACKUP_DIR"

# Generate config backup
echo "Creating OPNsense backup..."
if ! php /usr/local/etc/inc/backup.inc dump > "$BACKUP_DIR/$BACKUP_FILE"; then
    echo "ERROR: Failed to create backup!"
    exit 1
fi

# Set proper permissions (optional)
chmod 600 "$BACKUP_DIR/$BACKUP_FILE"

# Clean up old backups (keep last $MAX_BACKUPS)
echo "Cleaning up old backups..."
ls -t "$BACKUP_DIR"/opnsense-config-*.xml 2>/dev/null | tail -n +$(($MAX_BACKUPS + 1)) | xargs -r rm -f

# Verify
CURRENT_BACKUPS=$(ls -1 "$BACKUP_DIR"/opnsense-config-*.xml 2>/dev/null | wc -l)
echo "Backup complete: $BACKUP_DIR/$BACKUP_FILE"
echo "Total backups kept: $CURRENT_BACKUPS (max: $MAX_BACKUPS)"
