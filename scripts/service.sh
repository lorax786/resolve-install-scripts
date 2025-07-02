#!/bin/bash

# Resolve service account and password
$RESOLVE_USER="$1"
$RESOLVE_PASS="$2"

# Create account
useradd -c "Resolve Service" -m "$RESOLVE_USER"
echo "$RESOLVE_USER:$RESOLVE_PASS" | chpasswd
