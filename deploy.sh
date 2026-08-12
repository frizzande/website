#!/bin/bash

# Regenerate the Tailwind stylesheet so newly-used utility classes exist.
# Skipping this leaves static/css/main.css stale and silently unstyles new markup.
npm run build:css || { echo "Tailwind build failed"; exit 1; }

# Build the Hugo site
hugo || { echo "Hugo build failed"; exit 1; }

# Sync the built static files to the web directory
rsync -avz --delete public/ ande@103.249.237.191:/var/www/frizzande.io/public/

# Reload Nginx via Mailcow's container
ssh ande@103.249.237.191 << EOF
  cd ~/mailcow-dockerized || exit 1
  sudo docker compose restart nginx-mailcow
EOF

echo "✅ Deployment complete and Nginx reloaded."

