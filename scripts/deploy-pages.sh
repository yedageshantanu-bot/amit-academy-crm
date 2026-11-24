#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR/frontend"

echo "Building frontend..."
npm run build

DEPLOY_TOKEN="${CLOUDFLARE_API_TOKEN:-}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-}"
PROJECT_NAME="${CLOUDFLARE_PAGES_PROJECT:-academy-crm}"

if [ -z "$DEPLOY_TOKEN" ] || [ -z "$ACCOUNT_ID" ]; then
  echo "Error: Set CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID (or run CRM_DNA.md onboarding)."
  exit 1
fi

echo "Deploying to Cloudflare Pages ($PROJECT_NAME)..."
WRANGLER_SEND_METRICS=false CLOUDFLARE_API_TOKEN="$DEPLOY_TOKEN" CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID" \
  npx wrangler pages deploy dist --project-name "$PROJECT_NAME" --branch main --commit-dirty=true

echo "Deployment complete!"
