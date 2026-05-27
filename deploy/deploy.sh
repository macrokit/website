#!/usr/bin/env bash
# Deploy macrokit.dev static site to the production server.
#
# Reads server connection details from accounts.txt (NOT committed). Override
# via env: MACROKIT_SSH_KEY, MACROKIT_SSH_HOST, MACROKIT_REMOTE_ROOT.

set -euo pipefail

SSH_KEY="${MACROKIT_SSH_KEY:-/Users/jameswalstonn/Desktop/servers/us/helpswap.pem}"
SSH_HOST="${MACROKIT_SSH_HOST:-ubuntu@3.95.41.84}"
REMOTE_ROOT="${MACROKIT_REMOTE_ROOT:-/macrokit/website}"

HERE="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -f "$SSH_KEY" ]]; then
  echo "SSH key not found at $SSH_KEY" >&2
  exit 1
fi

echo "==> rsync public/ -> $SSH_HOST:$REMOTE_ROOT/public/"
rsync -avz --delete \
  -e "ssh -i $SSH_KEY -o ServerAliveInterval=30" \
  "$HERE/public/" \
  "$SSH_HOST:$REMOTE_ROOT/public/"

echo "==> rsync deploy/nginx/ -> $SSH_HOST:$REMOTE_ROOT/deploy/nginx/"
rsync -avz \
  -e "ssh -i $SSH_KEY -o ServerAliveInterval=30" \
  "$HERE/deploy/nginx/" \
  "$SSH_HOST:$REMOTE_ROOT/deploy/nginx/"

echo "==> ensure vhost is symlinked + reload nginx"
ssh -i "$SSH_KEY" -o ServerAliveInterval=30 "$SSH_HOST" bash <<'REMOTE'
set -euo pipefail
sudo ln -sf /macrokit/website/deploy/nginx/macrokit.dev.conf /etc/nginx/sites-available/macrokit.dev
sudo ln -sf /etc/nginx/sites-available/macrokit.dev /etc/nginx/sites-enabled/macrokit.dev
sudo nginx -t
sudo systemctl reload nginx
REMOTE

echo
echo "==> deploy complete. test:"
echo "    curl -H 'Host: macrokit.dev' http://3.95.41.84/"
