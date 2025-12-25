# Backup HDD Scripts

Collection of backup scripts for different use cases.

## Scripts

### 1. Simple Backup ([simple-backup/](simple-backup/))

Basic backup script using rsync for simple directory synchronization.

**Features:**
- Simple rsync-based backup
- No encryption
- No compression
- YAML configuration support
- Multi-drive support

**Use case:** Quick backups to unencrypted drives

### 2. BTRFS Backup with LUKS ([btrfs-backup/](btrfs-backup/))

Advanced backup script with encryption and compression support.

**Features:**
- LUKS encrypted volumes support
- Automatic mounting/unmounting
- BTRFS compression (zstd:9)
- Integrity verification (BTRFS scrub)
- Disk space validation
- Compression statistics
- Subfolder backup support
- Complete test environment

**Use case:** Secure backups to encrypted BTRFS drives

## Quick Start

### Simple Backup
```bash
cd simple-backup/
./backup-hdd.sh
```

### BTRFS Backup (Production)
```bash
cd btrfs-backup/
sudo ./backup-hdd-btrfs.sh --scrub --compression-stats
```

### BTRFS Backup (Test Mode)
```bash
cd btrfs-backup/
./test-backup.sh
```

## Configuration

Both scripts use YAML configuration files. See each script's README for details:
- [Simple Backup Configuration](simple-backup/README.md#configuration)
- [BTRFS Backup Configuration](btrfs-backup/README.md#configuration)

## Requirements

**Common:**
- `rsync`
- `yq`

**BTRFS Backup additional:**
- `cryptsetup`
- `compsize` (optional, for compression stats)

Install on Fedora:
```bash
sudo dnf install rsync yq cryptsetup compsize
```

## Project Structure

```
backup-hdd/
├── README.md                   # This file
├── simple-backup/              # Simple backup script
│   ├── backup-hdd.sh          # Main script
│   ├── backup-hdd-simple.yml  # Configuration
│   ├── tests/                 # Test data
│   └── README.md              # Documentation
└── btrfs-backup/              # BTRFS/LUKS backup script
    ├── backup-hdd-btrfs.sh    # Main script
    ├── test-backup.sh         # Test wrapper
    ├── tests/              # Test environment
    │   ├── source/            # Test source files
    │   ├── backup1/           # Test destination 1
    │   ├── backup2/           # Test destination 2
    │   ├── test-config.yml    # Test configuration
    │   └── README.md          # Test documentation
    └── README.md              # Documentation
```

## Testing

Both scripts include comprehensive automated test suites.

### Run All Tests
```bash
./run-all-tests.sh
```

### Run Individual Tests
```bash
# Simple backup tests (17 tests)
cd simple-backup && ./test-simple-backup.sh

# BTRFS backup tests (26 tests)
cd btrfs-backup && ./test-btrfs-backup.sh
```

### Test Features
- ✅ Automatic test environment setup
- ✅ File existence and content verification
- ✅ Incremental backup testing
- ✅ File deletion testing (with/without --delete)
- ✅ Drive selection testing
- ✅ Automatic cleanup after tests
- ✅ Reproducible tests

See [TESTING.md](TESTING.md) for detailed testing documentation.

## License

See individual script directories for license information.

## Contributing

Feel free to open issues or submit pull requests for improvements.
