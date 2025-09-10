#!/bin/bash

# ----------------------------------------------------------------------------
# news.sh
#
# - Creates a new blog post using archetypes/blog.md
# - Title is the number of days since 1991-06-26
# - Date is today's date (YYYY-MM-DD)
# - Sets draft: true by default if missing
# - Sets publishDate to today (appears directly below date)
# - Saves to content/blog/<days>.md and opens it in Vim
# ----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BASE_DATE="1991-06-26"
TODAY=$(date +%Y-%m-%d)
DAYS_SINCE=$(( ( $(date -d "$TODAY" +%s) - $(date -d "$BASE_DATE" +%s) ) / 86400 ))

TEMPLATE_PATH="$REPO_ROOT/archetypes/blog.md"
OUTPUT_DIR="$REPO_ROOT/content/blog"
OUTPUT_FILE="$OUTPUT_DIR/${DAYS_SINCE}.md"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "Error: archetype template not found at $TEMPLATE_PATH"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Error: $OUTPUT_FILE already exists."
  exit 1
fi

# ----------------------------
# Generate new post with draft and publishDate inside front matter
# ----------------------------
awk -v title="$DAYS_SINCE" -v date="$TODAY" '
  BEGIN { in_header=0; has_draft=0 }
  /^---/ {
    if (in_header==0) {
      in_header=1
      print
      next
    } else {
      # End of front matter: add draft if missing
      if (!has_draft) print "draft: true"
      print "---"
      in_header=0
      next
    }
  }
  {
    # Replace placeholders in template
    gsub(/\{\{\s*title\s*\}\}/, title)
    gsub(/\{\{\s*date\s*\}\}/, date)

    # After the date line, insert publishDate
    if ($0 ~ /^date:/) {
      print
      print "publishDate: " date
      next
    }

    # Detect if draft line exists
    if ($0 ~ /^draft:/) has_draft=1

    print
  }
' "$TEMPLATE_PATH" > "$OUTPUT_FILE"

# 7) Open in Vim
vim "$OUTPUT_FILE"

