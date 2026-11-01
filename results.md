# Rclone Automation & Verification Results

## 1. Core Operation Observations
- **copy**: Transferred all missing or modified files from source to destination. Re-running the command resulted in 0 B transferred because rclone checked sizes and modtimes.
- **sync**: Enforced destination alignment with the source. When extra_file.txt was added to the bucket, sync --dry-run flagged it, and sync permanently removed it.
- **check**: Validated that all file hashes matched bit-for-bit with 0 differences found.

## 2. Transfer Reliability & Restart Behavior
- S3 multipart uploads store chunks during upload. When a transfer is halted mid-flight, incomplete parts remain unfinalized in the S3 bucket.
- Re-running the command causes rclone to evaluate existing object metadata and re-transfer only incomplete or missing files.

## 3. Questions Answered
1. **Executing copy twice:** The second run checks size and modification timestamps, identifies matching files, and transfers 0 bytes.
2. **Missing file at destination during sync:** sync deletes the extraneous destination file to ensure an exact replica of the source.
3. **How rclone determines transfer need:** It first compares file sizes and modification times; if hashes are supported by the backend, it compares MD5/checksums before initiating transfer.
4. **Direct S3-to-S3 transfers:** On the same provider with shared credentials, rclone issues server-side S3 CopyObject requests. Across separate endpoints (different hosts/credentials), it streams data through host memory without touching the local disk.
5. **Network interruption during 1GB upload:** The active multipart connection fails. The S3 server retains uncommitted parts, and rclone automatically retries or restarts the transfer from the uncommitted state.
6. **Executing rclone from Celery securely:** Inject dynamic credentials directly into the subprocess environment using RCLONE_S3_ACCESS_KEY_ID, RCLONE_S3_SECRET_ACCESS_KEY, and RCLONE_S3_ENDPOINT variables without creating an rclone.conf file on disk.
