#!/bin/sh
set -e

FILES=$(git ls-files '*.sh')

if [ -z "$FILES" ]; then
  echo "No shell scripts to check"
  exit 0
fi

shellcheck $FILES

