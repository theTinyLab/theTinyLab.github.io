#!/usr/bin/env bash
# Leak-prevention gate: fails if internal infrastructure detail appears in
# anything that could reach the public site. Runs pre-commit and in CI/deploy.
set -uo pipefail
cd "$(dirname "$0")/.."

patterns=(
  '172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}'
  '172\.30\.[0-9]{1,3}'
  '192\.168\.[0-9]{1,3}\.[0-9]{1,3}'
  '\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\bVLANs?[- ]?#?[0-9]{1,3}\b'
  '\b(pve|nuc|ns0|ns[12]|fw0|pg0|etcd0)[0-9]{1,2}\b'
  'LAB_Transit'
  'home\.thetinylab'
  'sudo@thetinylab'
)

fails=0
while IFS= read -r -d '' f; do
  for p in "${patterns[@]}"; do
    matches=$(grep -InE "$p" "$f" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      echo "LEAK: pattern [$p]" >&2
      echo "$matches" | sed 's/^/      /' >&2
      echo "  in: $f" >&2
      fails=1
    fi
  done
done < <(find . -type f \
  \( -name '*.md' -o -name '*.html' -o -name '*.toml' -o -name '*.yaml' \
     -o -name '*.yml' -o -name '*.css' -o -name '*.js' -o -name '*.json' \) \
  -not -path './.git/*' -not -path './public/*' -print0)

if [ "$fails" -ne 0 ]; then
  echo "" >&2
  echo "leak-check FAILED — internal detail must not enter this repo." >&2
  echo "See README.md § sanitization contract." >&2
  exit 1
fi

echo "leak-check: clean"
