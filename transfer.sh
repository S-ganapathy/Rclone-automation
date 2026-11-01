#!/usr/bin/env bash
set -eo pipefail

OPERATION="$1"
SOURCE="$2"
DESTINATION="$3"
LOG_FILE="transfer.log"

if [[ -z "$OPERATION" || -z "$SOURCE" || -z "$DESTINATION" ]]; then
  echo "Usage: $0 <copy|sync|move|check> <source> <destination> [extra rclone flags...]"
  exit 1
fi

shift 3
EXTRA_ARGS=("$@")

# Default environment variables for configuration-free execution
export RCLONE_S3_PROVIDER="${S3_PROVIDER:-Minio}"
export RCLONE_S3_ENDPOINT="${S3_ENDPOINT:-http://localhost:9000}"
export RCLONE_S3_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID:-minioadmin}"
export RCLONE_S3_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY:-miniopassword}"
export RCLONE_S3_REGION="${S3_REGION:-us-east-1}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] START: rclone $OPERATION $SOURCE -> $DESTINATION" | tee -a "$LOG_FILE"

if rclone "$OPERATION" "$SOURCE" "$DESTINATION" \
  --progress \
  --stats-one-line \
  --retries 3 \
  --log-file="$LOG_FILE" \
  --log-level NOTICE \
  "${EXTRA_ARGS[@]}"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $OPERATION completed" | tee -a "$LOG_FILE"
  exit 0
else
  STATUS=$?
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $OPERATION failed with exit code $STATUS" | tee -a "$LOG_FILE"
  exit $STATUS
fi
