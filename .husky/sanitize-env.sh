#!/bin/bash
echo "Husky pre-push: Running .env sanitizer..."


if git diff --cached --name-only | grep -qE "/\.env$"; then
  echo "❌ ERROR: Attempting to push a .env file!"
  echo "Push has been aborted. Please ensure all .env files are in your .gitignore."
  exit 1
fi

changes_made=false

find . -type f -name ".env" -not -path "./node_modules/*" | while read -r env_file; do
  dir=$(dirname "$env_file")
  sample_file="$dir/.sample-env"

  echo "  -> Found '$env_file'. Generating '$sample_file'..."

  grep -v '^#' "$env_file" | grep -v '^$' | sed 's/ *=.*/=""/' > "$sample_file"

  git add "$sample_file"
  changes_made=true
done

if [ "$changes_made" = true ]; then
  echo "✅ Automatically staged new/updated .sample-env files."
fi

echo "✅ Finished sanitizing .env files. Proceeding with push."
exit 0