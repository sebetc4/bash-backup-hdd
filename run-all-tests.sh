#!/bin/bash

################################################################################
# Run all backup tests
#
# This script runs both simple backup and BTRFS backup test suites
################################################################################

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_NC='\033[0m'

TOTAL_PASSED=0
TOTAL_FAILED=0

echo ""
echo -e "${COLOR_BLUE}╔════════════════════════════════════════════════════════════════╗${COLOR_NC}"
echo -e "${COLOR_BLUE}║                 Running All Backup Tests                       ║${COLOR_NC}"
echo -e "${COLOR_BLUE}╚════════════════════════════════════════════════════════════════╝${COLOR_NC}"
echo ""

# Test 1: Simple Backup
echo -e "${COLOR_BLUE}[1/2] Testing Simple Backup...${COLOR_NC}"
echo ""

cd "$SCRIPT_DIR/simple-backup"
if ./test-simple-backup.sh; then
    simple_result="PASSED"
    simple_color="${COLOR_GREEN}"
else
    simple_result="FAILED"
    simple_color="${COLOR_RED}"
fi

echo ""
echo ""

# Test 2: BTRFS Backup
echo -e "${COLOR_BLUE}[2/2] Testing BTRFS Backup...${COLOR_NC}"
echo ""

cd "$SCRIPT_DIR/btrfs-backup"
if ./test-btrfs-backup.sh; then
    btrfs_result="PASSED"
    btrfs_color="${COLOR_GREEN}"
else
    btrfs_result="FAILED"
    btrfs_color="${COLOR_RED}"
fi

# Final Summary
echo ""
echo ""
echo -e "${COLOR_BLUE}╔════════════════════════════════════════════════════════════════╗${COLOR_NC}"
echo -e "${COLOR_BLUE}║                    Final Test Summary                          ║${COLOR_NC}"
echo -e "${COLOR_BLUE}╚════════════════════════════════════════════════════════════════╝${COLOR_NC}"
echo ""
echo -e "Simple Backup Tests:  ${simple_color}${simple_result}${COLOR_NC}"
echo -e "BTRFS Backup Tests:   ${btrfs_color}${btrfs_result}${COLOR_NC}"
echo ""

if [ "$simple_result" = "PASSED" ] && [ "$btrfs_result" = "PASSED" ]; then
    echo -e "${COLOR_GREEN}✓ All test suites passed! 🎉${COLOR_NC}"
    echo ""
    exit 0
else
    echo -e "${COLOR_RED}✗ Some tests failed${COLOR_NC}"
    echo ""
    exit 1
fi
