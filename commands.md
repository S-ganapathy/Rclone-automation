# Rclone Verification Commands

## 1. Local S3 Infrastructure Setup
```bash
docker compose up -d
curl -I http://localhost:9000/minio/health/live
curl -I http://localhost:9010/minio/health/live
```

## 2. Basic Local File Operations
```bash
# Listing local test data
rclone lsf test_data/

# Copying between local directories
./transfer.sh copy test_data/ dest_local/

# Verify local integrity
./transfer.sh check test_data/ dest_local/

# Sync local directories
./transfer.sh sync test_data/ dest_local/
```

## 3. Configuration-Free Bucket Creation
```bash
# Create buckets on MinIO 1 and MinIO 2 without rclone.conf
rclone mkdir :s3:testpress-bucket \
  --s3-provider Minio \
  --s3-endpoint http://localhost:9000 \
  --s3-access-key-id minioadmin \
  --s3-secret-access-key miniopassword \
  --s3-region us-east-1

rclone mkdir :s3:backup-bucket \
  --s3-provider Minio \
  --s3-endpoint http://localhost:9010 \
  --s3-access-key-id minioadmin2 \
  --s3-secret-access-key miniopassword2 \
  --s3-region us-east-1
```

## 4. Automated S3 File Transfer & Safety Operations
```bash
# Dry-run verification
./transfer.sh copy test_data/ :s3:testpress-bucket/ --dry-run

# Full copy execution to S3
./transfer.sh copy test_data/ :s3:testpress-bucket/

# S3 integrity check
./transfer.sh check test_data/ :s3:testpress-bucket/

# Synchronize with deletion of unreferenced files
./transfer.sh sync test_data/ :s3:testpress-bucket/
```

## 5. Bandwidth Throttling & 1GB Upload
```bash
./transfer.sh copy test_data/assets/video_1GB.bin :s3:testpress-bucket/assets/ \
  --bwlimit 25M \
  --transfers 1 \
  --multi-thread-streams 4
```

## 6. Cross-Endpoint Transfer (MinIO 1 -> MinIO 2)
```bash
rclone copy \
  ":s3,provider=Minio,endpoint='http://localhost:9000',access_key_id=minioadmin,secret_access_key=miniopassword:testpress-bucket" \
  ":s3,provider=Minio,endpoint='http://localhost:9010',access_key_id=minioadmin2,secret_access_key=miniopassword2:backup-bucket" \
  --progress
```
