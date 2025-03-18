#!/bin/bash

# Check for proper number of arguments (only version is needed)
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

version="$1"

# Enable case-insensitive globbing to match filenames starting with "changelog"
shopt -s nocaseglob
files=(changelog*)
shopt -u nocaseglob

# Check if any matching file exists
if [ ${#files[@]} -eq 0 ]; then
  echo "Error: No file beginning with 'changelog' found in the current directory."
  exit 1
fi

# Use the first matching file
file="${files[0]}"
echo "Using file: $file"

# Use awk to print the block from the specified version until the next version header.
# The version header is assumed to start at the beginning of a line and match the pattern:
# one or two digits, dot, one or two digits, dot, one or two digits, optionally dot one or two digits.
awk -v ver="$version" '
  BEGIN { printing = 0 }
  /^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})?/ {
    # If already printing and this header is not the target version, stop printing.
    if (printing && $0 !~ "^" ver) exit
    # Start printing when the target version header is found.
    if ($0 ~ "^" ver) printing = 1
  }
  printing { print }
' "$file"

