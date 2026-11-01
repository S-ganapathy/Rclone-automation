# Rclone Automated File Transfer Workflow

Automated file transfer, synchronization, and verification framework using `rclone` and local dual-endpoint MinIO S3 storage without persistent configuration files.

## Prerequisites
- Docker & Docker Compose
- `rclone`
- `curl`

## Setup & Reproduction

1. Start dual local MinIO S3 instances:
   ```bash
   docker compose up -d
   ```

2. Create test dataset:
   ```bash
   mkdir -p test_data/docs test_data/assets dest_local
   echo "sample data" > test_data/sample.txt
   dd if=/dev/urandom of=test_data/assets/large_test_100MB.bin bs=1M count=100
   ```

3. Run file operations:
   ```bash
   # Copy
   ./transfer.sh copy test_data/ :s3:testpress-bucket/

   # Verify
   ./transfer.sh check test_data/ :s3:testpress-bucket/

   # Synchronize
   ./transfer.sh sync test_data/ :s3:testpress-bucket/
   ```

4. Cross-endpoint replication (MinIO 1 to MinIO 2):
   ```bash
   rclone copy \
     ":s3,provider=Minio,endpoint='http://localhost:9000',access_key_id=minioadmin,secret_access_key=miniopassword:testpress-bucket" \
     ":s3,provider=Minio,endpoint='http://localhost:9010',access_key_id=minioadmin2,secret_access_key=miniopassword2:backup-bucket"
   ```
