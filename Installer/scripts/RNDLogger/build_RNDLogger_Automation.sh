#!/usr/bin/env bash

# ----------------------------------------
# Build script for RNDLogger_Automation NSIS installer
# ----------------------------------------

set -e

# Convert Windows makensis.exe path for Bash usage
NSIS="/c/Program Files (x86)/NSIS/Bin/makensis.exe"

# NSIS script name
NSI_SCRIPT="RNDLogger_Automation.nsi"

# Sanity checks
if [[ ! -f "$NSI_SCRIPT" ]]; then
  echo "ERROR: NSIS script not found: $NSI_SCRIPT"
  exit 1
fi

if [[ ! -x "$NSIS" ]]; then
  echo "ERROR: makensis.exe not found or not executable at:"
  echo "  $NSIS"
  exit 1
fi

echo "Building NSIS installer..."
echo "Using: $NSIS"
echo "Script: $NSI_SCRIPT"
echo

"$NSIS" "$NSI_SCRIPT"

echo
echo "✅ Build completed successfully"
``
