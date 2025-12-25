# Testing Guide

Complete guide for testing both backup scripts.

## Quick Test Commands

### Simple Backup
```bash
cd simple-backup
./test-simple-backup.sh
```

### BTRFS Backup
```bash
cd btrfs-backup
./test-btrfs-backup.sh
```

## Test Features

Both test suites include:

- ✅ **Automatic Setup** - Test environment is created automatically
- ✅ **File Verification** - Checks that files exist and content matches
- ✅ **Incremental Tests** - Tests file modifications and additions
- ✅ **Deletion Tests** - Tests with and without `--delete` flag
- ✅ **Drive Selection** - Tests backup to specific drives
- ✅ **Automatic Cleanup** - Test environment is cleaned after each run
- ✅ **Reproducibility** - Tests can be run multiple times
- ✅ **Clear Reporting** - Pass/fail counts and detailed messages

## Test Coverage

### Simple Backup Tests (17 tests)

1. Initial backup to both drives
2. Incremental backup (modify existing files)
3. New file addition
4. File deletion with `--delete` flag
5. File deletion without `--delete` flag (files kept)
6. Drive-specific backup

### BTRFS Backup Tests (26 tests)

1. Initial backup to Drive 1 (subfolder support)
2. Initial backup to Drive 2 (full directory support)
3. Incremental backup (modify existing files)
4. New file addition
5. File deletion with `--delete` flag
6. File deletion without `--delete` flag (files kept)
7. Backup to both drives simultaneously
8. File count verification

## Test Output Example

```
========================================
  BTRFS Backup - Test Suite
========================================

✓ Setting up test environment...
▶ TEST 1: Initial backup to Drive 1 (subfolder support)
⚠ Cleaning up backup directories...
✓ Drive 1: Documents/Work directory
✓ Drive 1: Work file1: file1.txt
✓ Drive 1: Work file5: file5.txt
...

========================================
  Test Results
========================================

Total tests:  26
Passed:       26
Failed:       0

✓ All tests passed! ✨
```

## Test Environment Structure

### Simple Backup
```
simple-backup/tests/
├── source/           # Test source files
│   ├── dir1/
│   ├── dir2/
│   └── dir3/
├── backup1/          # Drive 1 destination (cleaned after tests)
├── backup2/          # Drive 2 destination (cleaned after tests)
└── test-config-1.yml # Test configuration
```

### BTRFS Backup
```
btrfs-backup/tests/
├── source/           # Test source files
│   ├── Documents/
│   ├── Photos/
│   ├── Music/
│   └── Videos/
├── backup1/          # Drive 1 destination (cleaned after tests)
├── backup2/          # Drive 2 destination (cleaned after tests)
├── test-config.yml   # Test configuration
└── README.md         # Test documentation
```

## Continuous Integration

Both test scripts are designed to be CI-friendly:

- Exit code 0 on success
- Exit code 1 on failure
- No user input required (fully automated)
- Clean test environment (no side effects)

Example CI usage:
```bash
#!/bin/bash
set -e

echo "Testing Simple Backup..."
cd simple-backup && ./test-simple-backup.sh

echo "Testing BTRFS Backup..."
cd ../btrfs-backup && ./test-btrfs-backup.sh

echo "All tests passed!"
```

## Troubleshooting

### Permission Issues

If you see permission errors:
```bash
chmod -R u+w simple-backup/tests/Backup-*
chmod -R u+w btrfs-backup/tests/backup*
```

### Test Fails

1. Check the error message for which assertion failed
2. Look at the test file for that specific test
3. Verify the backup script works manually with test config
4. Check file permissions and ownership

### Clean State

To completely reset test environments:

```bash
# Simple backup
cd simple-backup/tests
chmod -R u+w backup*
rm -rf backup1/* backup2/*

# BTRFS backup
cd btrfs-backup/tests
chmod -R u+w backup*
rm -rf backup1/* backup2/*
```

## Adding New Tests

To add a new test to either test suite:

1. Create a new test function:
```bash
test_my_new_feature() {
    log_test "TEST X: Description"

    # Your test code here
    assert_file_exists "$TEST_DIR/path/to/file" "Description"

    echo ""
}
```

2. Call it from `main()`:
```bash
main() {
    # ...existing tests...
    test_my_new_feature
    # ...
}
```

## Manual Testing

For manual testing without the test suite:

### Simple Backup
```bash
cd simple-backup
./backup-hdd.sh -c tests/test-config-1.yml --no-progress
```

### BTRFS Backup
```bash
cd btrfs-backup
./backup-hdd-btrfs.sh --config tests/test-config.yml --no-mount --no-progress
```

## Test Assertions Available

Both test scripts provide:

- `assert_file_exists` - Check if a file exists
- `assert_file_not_exists` - Check if a file doesn't exist
- `assert_files_identical` - Compare two files
- `assert_dir_exists` - Check if a directory exists (BTRFS only)

## Performance

Tests are designed to be fast:
- Simple Backup tests: ~5-10 seconds
- BTRFS Backup tests: ~10-15 seconds

All tests together: < 30 seconds
