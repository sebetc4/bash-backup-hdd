# Simple Backup Script

Simple backup script without LUKS encryption or BTRFS compression.

## Files

- `backup-hdd.sh` - Main simple backup script
- `backup-hdd-simple.yml` - Configuration file
- `tests/` - Test environment

## Usage

```bash
./backup-hdd.sh [-c <config>] [-d <drive>] [options]
```

### Options

- `-c, --config <file>` - Configuration file (default: `~/.backup/backup-hdd.yml`)
- `-d, --drive <drive>` - Drive to backup: 1, 2, both (default: both)
- `--no-delete` - Don't delete files in destination not in source
- `--no-progress` - Don't show progress during file transfer
- `-h, --help` - Display help message

### Examples

```bash
# Backup to both drives
./backup-hdd.sh

# Backup to drive 1 only
./backup-hdd.sh -d 1

# Backup without deleting files
./backup-hdd.sh --no-delete
```

## Configuration

The YAML configuration file defines:
- Source directory
- Destination directories (backup_drive_1 and backup_drive_2)
- Folders to backup for each drive

Example:
```yaml
source:
  dir: /mnt/source

backup_drive_1:
  dir: /mnt/backup1
  folders:
    - path: Documents
    - path: Photos

backup_drive_2:
  dir: /mnt/backup2
  folders:
    - path: Documents
    - path: Music
```

## Tests

The `tests/` directory contains test data to validate script functionality.
