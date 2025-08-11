#!/usr/bin/env bash
set -euo pipefail
ver=$(cat VERSION)
commit=$(git rev-parse --short HEAD)
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir -p public
cat > public/version.json <<JSON
{ "version": "$ver", "commit": "$commit", "builtAt": "$ts" }
JSON
echo "Wrote public/version.json"
