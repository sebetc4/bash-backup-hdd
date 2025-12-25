#!/bin/bash

################################################################################
# Test script for simple backup
#
# This script tests the simple backup functionality with automatic cleanup
# and verification.
################################################################################

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_DIR="$SCRIPT_DIR/tests"
readonly BACKUP_SCRIPT="$SCRIPT_DIR/backup-hdd.sh"
readonly TEST_CONFIG="$TEST_DIR/test-config-1.yml"

# Colors
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${COLOR_GREEN}✓${COLOR_NC} $1"
}

log_warn() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_NC} $1"
}

log_error() {
    echo -e "${COLOR_RED}✗${COLOR_NC} $1" >&2
}

log_test() {
    echo -e "${COLOR_BLUE}▶${COLOR_NC} $1"
}

assert_file_exists() {
    local file="$1"
    local description="${2:-File should exist}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [ -f "$file" ]; then
        log_info "$description: $file"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$description: $file NOT FOUND"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local description="${2:-File should not exist}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [ ! -f "$file" ]; then
        log_info "$description: $file"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$description: $file EXISTS (should not)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_files_identical() {
    local file1="$1"
    local file2="$2"
    local description="${3:-Files should be identical}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if diff -q "$file1" "$file2" &>/dev/null; then
        log_info "$description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "$description: Files differ"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

cleanup_backups() {
    log_warn "Cleaning up backup directories..."
    # Fix permissions before cleanup to avoid permission issues
    chmod -R u+w "$TEST_DIR/backup1" "$TEST_DIR/backup2" 2>/dev/null || true
    rm -rf "$TEST_DIR/backup1"/*
    rm -rf "$TEST_DIR/backup2"/*
}

setup_test_files() {
    log_info "Setting up test files..."

    # Create test structure if it doesn't exist
    mkdir -p "$TEST_DIR/source"/{dir1,dir2,dir3/dir3a,dir3/dir3b,dir3/dir3c}

    # Create test files
    echo "Test file 1 - $(date)" > "$TEST_DIR/source/dir1/test.txt"
    echo "Test file 2" > "$TEST_DIR/source/dir2/text.txt"
    echo "Test file 3a" > "$TEST_DIR/source/dir3/dir3a/text.txt"
    echo "Test file 3b" > "$TEST_DIR/source/dir3/dir3b/text.txt"
    echo "Test file 3c" > "$TEST_DIR/source/dir3/dir3c/text.txt"
    echo "Test file 3" > "$TEST_DIR/source/dir3/text.txt"
}

################################################################################
# Test Functions
################################################################################

test_initial_backup() {
    log_test "TEST 1: Initial backup to both drives"

    cleanup_backups

    # Run backup
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d both --no-progress <<< "Y"

    # Verify backup1 (should have dir1 and dir3)
    assert_file_exists "$TEST_DIR/backup1/dir1/test.txt" "Backup-1: dir1 file"
    assert_file_exists "$TEST_DIR/backup1/dir3/dir3a/text.txt" "Backup-1: dir3/dir3a file"
    assert_file_not_exists "$TEST_DIR/backup1/dir2/text.txt" "Backup-1: dir2 should not exist"

    # Verify backup2 (should have dir2 and dir3)
    assert_file_exists "$TEST_DIR/backup2/dir2/text.txt" "Backup-2: dir2 file"
    assert_file_exists "$TEST_DIR/backup2/dir3/dir3a/text.txt" "Backup-2: dir3/dir3a file"
    assert_file_not_exists "$TEST_DIR/backup2/dir1/test.txt" "Backup-2: dir1 should not exist"

    # Verify file contents
    assert_files_identical "$TEST_DIR/source/dir1/test.txt" "$TEST_DIR/backup1/dir1/test.txt" "Backup-1: File content matches"
    assert_files_identical "$TEST_DIR/source/dir2/text.txt" "$TEST_DIR/backup2/dir2/text.txt" "Backup-2: File content matches"

    echo ""
}

test_incremental_backup() {
    log_test "TEST 2: Incremental backup (modify existing file)"

    # Modify a file
    echo "Modified content - $(date)" > "$TEST_DIR/source/dir1/test.txt"

    # Run backup
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 1 --no-progress <<< "Y"

    # Verify modified file was updated
    assert_files_identical "$TEST_DIR/source/dir1/test.txt" "$TEST_DIR/backup1/dir1/test.txt" "Modified file synced"

    echo ""
}

test_new_file_backup() {
    log_test "TEST 3: New file addition"

    # Add new file
    echo "New file" > "$TEST_DIR/source/dir1/newfile.txt"

    # Run backup
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 1 --no-progress <<< "Y"

    # Verify new file exists
    assert_file_exists "$TEST_DIR/backup1/dir1/newfile.txt" "New file backed up"
    assert_files_identical "$TEST_DIR/source/dir1/newfile.txt" "$TEST_DIR/backup1/dir1/newfile.txt" "New file content matches"

    echo ""
}

test_file_deletion_with_delete() {
    log_test "TEST 4: File deletion (with --delete flag)"

    # Remove file from source
    rm -f "$TEST_DIR/source/dir1/newfile.txt"

    # Run backup with delete
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 1 --no-progress <<< "Y"

    # Verify file was deleted from backup
    assert_file_not_exists "$TEST_DIR/backup1/dir1/newfile.txt" "Deleted file removed from backup"

    echo ""
}

test_file_deletion_without_delete() {
    log_test "TEST 5: File deletion (without --delete flag)"

    # Create and backup a file
    echo "Temp file" > "$TEST_DIR/source/dir2/tempfile.txt"
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 2 --no-progress <<< "Y"
    assert_file_exists "$TEST_DIR/backup2/dir2/tempfile.txt" "Temp file backed up"

    # Remove from source
    rm -f "$TEST_DIR/source/dir2/tempfile.txt"

    # Run backup WITHOUT delete
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 2 --no-delete --no-progress <<< "Y"

    # Verify file still exists in backup
    assert_file_exists "$TEST_DIR/backup2/dir2/tempfile.txt" "File kept in backup (--no-delete)"

    # Cleanup
    rm -f "$TEST_DIR/backup2/dir2/tempfile.txt"

    echo ""
}

test_drive_selection() {
    log_test "TEST 6: Drive-specific backup"

    cleanup_backups

    # Backup only to drive 1
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 1 --no-progress <<< "Y"

    # Verify drive 1 has files
    assert_file_exists "$TEST_DIR/backup1/dir1/test.txt" "Drive 1 backup exists"

    # Verify drive 2 is empty
    assert_file_not_exists "$TEST_DIR/backup2/dir2/text.txt" "Drive 2 not backed up"

    # Backup only to drive 2
    "$BACKUP_SCRIPT" -c "$TEST_CONFIG" -d 2 --no-progress <<< "Y"

    # Verify drive 2 now has files
    assert_file_exists "$TEST_DIR/backup2/dir2/text.txt" "Drive 2 backup exists"

    echo ""
}

################################################################################
# Main Test Suite
################################################################################

main() {
    echo ""
    echo -e "${COLOR_BLUE}======================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}  Simple Backup - Test Suite${COLOR_NC}"
    echo -e "${COLOR_BLUE}======================================${COLOR_NC}"
    echo ""

    # Check if backup script exists
    if [ ! -f "$BACKUP_SCRIPT" ]; then
        log_error "Backup script not found: $BACKUP_SCRIPT"
        exit 1
    fi

    # Setup
    setup_test_files

    # Run tests
    test_initial_backup
    test_incremental_backup
    test_new_file_backup
    test_file_deletion_with_delete
    test_file_deletion_without_delete
    test_drive_selection

    # Final cleanup
    cleanup_backups
    log_info "Test environment cleaned up"

    # Summary
    echo ""
    echo -e "${COLOR_BLUE}======================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}  Test Results${COLOR_NC}"
    echo -e "${COLOR_BLUE}======================================${COLOR_NC}"
    echo ""
    echo "Total tests:  $TESTS_TOTAL"
    echo -e "Passed:       ${COLOR_GREEN}$TESTS_PASSED${COLOR_NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "Failed:       ${COLOR_RED}$TESTS_FAILED${COLOR_NC}"
        echo ""
        exit 1
    else
        echo -e "Failed:       $TESTS_FAILED"
        echo ""
        log_info "All tests passed!"
        exit 0
    fi
}

# Execute main
main "$@"
