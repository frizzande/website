#!/bin/bash

# ----------------------------------------------------------------------------
# news.sh
#
#  - Uses Hugo's archetype template at archetypes/blog.md
#  - Calculates days since 1991-06-26 for the title
#  - Inserts today's date in YYYY-MM-DD
#  - Writes a new file content/blog/<days>.md and opens it in vim
# -----------------------------------------------------------------------------

# 1) Where am I? (this script’s folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) Repo root = two levels up from content/blog/
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 3) Base date & today
BASE_DATE="1991-06-26"
TODAY=$(date +%Y-%m-%d)

# 4) Compute days since BASE_DATE
DAYS_SINCE=$(( ( $(date -d "$TODAY" +%s) - $(date -d "$BASE_DATE" +%s) ) / 86400 ))

# 5) Paths
TEMPLATE_PATH="$REPO_ROOT/archetypes/blog.md"
OUTPUT_DIR="$REPO_ROOT/content/blog"
OUTPUT_FILE="$OUTPUT_DIR/${DAYS_SINCE}.md"

# 6) Sanity checks
if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "Error: archetype template not found at $TEMPLATE_PATH"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Error: $OUTPUT_FILE already exists."
  exit 1
fi

# 7) Generate the new post from the archetype
sed \
  -e "s/{{\s*title\s*}}/$DAYS_SINCE/" \
  -e "s/{{\s*date\s*}}/$TODAY/" \
  "$TEMPLATE_PATH" > "$OUTPUT_FILE"

# 8) Open in your editor
vim "$OUTPUT_FILE"

st.sh
#
#  - Uses Hugo's archetype template at archetypes/blog.md
#  - Calculates days since 1991-06-26 for the title
#  - Inserts today's date in YYYY-MM-DD
#  - Writes a new file content/blog/<days>.md and opens it in vim
# -----------------------------------------------------------------------------

# 1) Where am I? (this script’s folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) Repo root = two levels up from content/blog/
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 3) Base date & today
BASE_DATE="1991-06-26"
TODAY=$(date +%Y-%m-%d)

# 4) Compute days since BASE_DATE
DAYS_SINCE=$(( ( $(date -d "$TODAY" +%s) - $(date -d "$BASE_DATE" +%s) ) / 86400 ))

# 5) Paths
TEMPLATE_PATH="$REPO_ROOT/archetypes/blog.md"
OUTPUT_DIR="$REPO_ROOT/content/blog"
OUTPUT_FILE="$OUTPUT_DIR/${DAYS_SINCE}.md"

# 6) Sanity checks
if [ ! -f "$TEMPLATE_PATH" ]; then
	  echo "Error: archetype template not found at $TEMPLATE_PATH"
	    exit 1
fi

mkdir -p "$OUTPUT_DIR"

if [ -f "$OUTPUT_FILE" ]; then
	  echo "Error: $OUTPUT_FILE already exists."
	    exit 1
fi

# 7) Generate the new post from the archetype
sed \
	  -e "s/{{\s*title\s*}}/$DAYS_SINCE/" \
	    -e "s/{{\s*date\s*}}/$TODAY/" \
	      "$TEMPLATE_PATH" > "$OUTPUT_FILE"

# 8) Open in your editor
vim "$OUTPUT_FILE"


# 1) Figure out where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2) Base date & today
BASE_DATE="1991-06-26"
TODAY=$(date +%Y-%m-%d)

# 3) Compute days since base date
DAYS_SINCE=$(( ( $(date -d "$TODAY" +%s) - $(date -d "$BASE_DATE" +%s) ) / 86400 ))

# 4) Paths
TEMPLATE_PATH="$SCRIPT_DIR/archetypes/blog.md"
OUTPUT_DIR="$SCRIPT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/${DAYS_SINCE}.md"

# 5) Make sure the template exists
if [ ! -f "$TEMPLATE_PATH" ]; then
	  echo "Template not found at $TEMPLATE_PATH"
	    exit 1
fi

# 6) Ensure output directory exists (it does, since script lives there)
# mkdir -p "$OUTPUT_DIR"

# 7) Prevent overwrite
if [ -f "$OUTPUT_FILE" ]; then
	  echo "Error: $OUTPUT_FILE already exists."
	    exit 1
fi

# 8) Fill in placeholders and write out the new post
sed \
	  -e "s/{{title}}/$DAYS_SINCE/" \
	    -e "s/{{date}}/$TODAY/" \
	      "$TEMPLATE_PATH" > "$OUTPUT_FILE"

# 9) Open it in Vim
vim "$OUTPUT_FILE"

