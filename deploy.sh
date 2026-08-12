#!/usr/bin/env bash
#
# Deploy the built Hugo site to frizzande.io.
#
# Caddy serves the webroot with a plain file_server (root * /srv/www/frizzande.io,
# bind-mounted from the remote path below), so publishing is just the rsync —
# there is no service to reload afterwards.
#
#   ./deploy.sh              build, then confirm before removing anything remote
#   ./deploy.sh --dry-run    show what would change, transfer nothing
#   ./deploy.sh --yes        don't prompt (for non-interactive use)
#
# Drafts are published by default: most posts under content/ carry
# draft: true while being live and linked, so building without them would
# unpublish about half the site. Set DRAFTS=0 to honour the flag instead.
#
set -euo pipefail

HOST="${DEPLOY_HOST:-ande@frizzande.io}"
REMOTE="${DEPLOY_PATH:-/var/www/frizzande.io/public/}"
# Floor for "the build looks sane". A near-empty public/ plus --delete would
# otherwise wipe the live site.
MIN_PAGES="${MIN_PAGES:-30}"
DRAFTS="${DRAFTS:-1}"

DRY_RUN=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

cd "$(dirname "$0")"

# --- build -----------------------------------------------------------------
# Tailwind purges against the markup, so stale CSS silently unstyles new
# classes. Always regenerate before Hugo runs.
npm run build:css
rm -rf public
if [[ "$DRAFTS" == "1" ]]; then
  hugo --buildDrafts
else
  hugo
fi

# --- verify the build before letting rsync --delete near the live site ------
[[ -f public/index.html ]] || { echo "public/index.html missing — refusing to deploy" >&2; exit 1; }
pages=$(find public -name 'index.html' | wc -l | tr -d ' ')
if (( pages < MIN_PAGES )); then
  echo "only $pages pages built (expected >= $MIN_PAGES) — refusing to deploy" >&2
  echo "override with MIN_PAGES=<n> if this is genuinely intended" >&2
  exit 1
fi
echo "built $pages pages"

RSYNC_OPTS=(-az --delete --human-readable)

# --- show what would be removed, and get consent ---------------------------
# Anything live but absent from this build gets deleted. That is usually just
# stale output, but it also catches posts newly marked draft: true, which Hugo
# stops emitting while they remain published.
deletions=$(rsync "${RSYNC_OPTS[@]}" --dry-run --itemize-changes public/ "$HOST:$REMOTE" \
            | awk '/^\*deleting/ {print $2}' | grep -E 'index\.html$' | sed 's|/index\.html$||' || true)

if [[ -n "$deletions" ]]; then
  count=$(printf '%s\n' "$deletions" | wc -l | tr -d ' ')
  echo
  echo "WARNING: $count published page(s) would be REMOVED from the live site:"
  printf '%s\n' "$deletions" | sed 's/^/  - /'
  echo
  if (( DRY_RUN == 0 && ASSUME_YES == 0 )); then
    if [[ ! -t 0 ]]; then
      echo "refusing to delete pages without a terminal to confirm on; pass --yes to override" >&2
      exit 1
    fi
    read -r -p "Delete these $count page(s)? [y/N] " reply
    [[ "$reply" == [yY] ]] || { echo "aborted — nothing was transferred"; exit 1; }
  fi
fi

if (( DRY_RUN == 1 )); then
  echo "--- dry run, showing changes only ---"
  rsync "${RSYNC_OPTS[@]}" --dry-run -v public/ "$HOST:$REMOTE"
  echo "dry run complete — nothing was transferred."
  exit 0
fi

# --- publish ---------------------------------------------------------------
rsync "${RSYNC_OPTS[@]}" -v public/ "$HOST:$REMOTE"

echo "✅ Deployed $pages pages to $HOST:$REMOTE"
