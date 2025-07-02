#!/bin/bash
# .husky/sanitize-env.sh

echo "Husky pre-push: Running .env sanitizer..."

# ---
# SAFETY CHECK: Abort push if any .env file is staged for commit.
# ---
if git diff --cached --name-only | grep -qE "(^|/)\.env$"; then
  echo "❌ ERROR: Attempting to push a .env file!"
  echo "Push has been aborted. Please ensure all .env files are in your .gitignore."
  exit 1
fi

# ---
# Find all .env files, but exclude node_modules to be safe and fast.
# For each found .env file, create a .sample-env with empty values.
# ---
find . -type f -name ".env" -not -path "./node_modules/*" | while read env_file; do
  dir=$(dirname "$env_file")
  sample_file="$dir/.sample-env"

  echo "  -> Found '$env_file'. Generating '$sample_file'..."

  grep -v '^#' "$env_file" | grep -v '^$' | sed 's/=.*//' | sed 's/$/=""/' > "$sample_file"

  git add "$sample_file"
done

echo "✅ Finished sanitizing .env files."
exit 0