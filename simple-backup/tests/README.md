# Simple Backup - Test Environment

Automated test suite for the simple backup script.

## Quick Start

Run all tests:
```bash
../test-simple-backup.sh
```

## Test Structure

```
tests/
├── source/          # Source files for testing
│   ├── dir1/
│   ├── dir2/
│   └── dir3/
├── backup1/         # Destination for drive 1 (auto-created)
├── backup2/         # Destination for drive 2 (auto-created)
└── test-config-1.yml  # Test configuration
```

## Test Cases

The test suite includes:

1. **Initial Backup** - First backup to both drives
2. **Incremental Backup** - Modify existing files and re-backup
3. **New File Addition** - Add new files and verify they're backed up
4. **File Deletion with --delete** - Remove files and verify deletion
5. **File Deletion without --delete** - Verify files are kept when --no-delete is used
6. **Drive Selection** - Test backing up to specific drives

## Test Features

- ✅ Automatic test environment setup
- ✅ File existence verification
- ✅ File content verification
- ✅ Automatic cleanup after tests
- ✅ Reproducible tests (can be run multiple times)
- ✅ Clear pass/fail reporting

## Configuration

The test configuration (`test-config-1.yml`) defines:
- **Drive 1**: Backs up `dir1` and `dir3`
- **Drive 2**: Backs up `dir2` and `dir3`

## Running Specific Tests

The test script runs all tests automatically. To modify test behavior:
- Tests are functions in `test-simple-backup.sh`
- Comment out tests in the `main()` function to skip them

## Cleanup

Tests automatically clean up backup directories after completion.
The test environment is reset and ready for the next run.

## Expected Output

```
======================================
  Simple Backup - Test Suite
======================================

✓ Setting up test files...
▶ TEST 1: Initial backup to both drives
✓ Backup-1: dir1 file
✓ Backup-1: dir3/dir3a file
...

======================================
  Test Results
======================================

Total tests:  17
Passed:       17
Failed:       0

✓ All tests passed!
```
