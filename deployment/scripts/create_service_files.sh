#!/bin/bash

# Define variables
# NOTE: PROJECT_DIR and DJANGO_ALLOWED_HOSTS must be environment variables
PROJECT_NAME=$(basename "$PROJECT_DIR")
GUNICORN_LOCATION="$1"
WORKERS="$2"
TEMPLATE_FILE="$3"
NGINX_TEMPLATE_FILE="$4"
ACTIVATE="$5"
SERVICE_FILE="/etc/systemd/system/gunicorn.service"
SOCKET_FILE="/etc/systemd/system/gunicorn.socket"
NGINX_CONF_FILE="/etc/nginx/sites-available/$PROJECT_NAME"
NGINX_LINK="/etc/nginx/sites-enabled/$PROJECT_NAME"

# Check if all arguments are provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <PROJECT_NAME> <PROJECT_DIR> <GUNICORN_LOCATION> <WORKERS> <TEMPLATE_FILE> <NGINX_TEMPLATE_FILE>"
    exit 1
fi

# Extract SERVER_NAME from environment variable
SERVER_NAME=$(echo "$DJANGO_ALLOWED_HOSTS" | tr ',' ' ')

# Load template and replace placeholders for service file
sudo sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
         -e "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" \
         -e "s|{{GUNICORN_LOCATION}}|$GUNICORN_LOCATION|g" \
         -e "s|{{WORKERS}}|$WORKERS|g" "$TEMPLATE_FILE" | sudo tee "$SERVICE_FILE"

# Create the socket file
cat <<EOF | sudo tee "$SOCKET_FILE"
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
EOF

# Load Nginx template and replace placeholders
sudo sed -e "s|{{SERVER_NAME}}|$SERVER_NAME|g" \
         -e "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" "$NGINX_TEMPLATE_FILE" | sudo tee "$NGINX_CONF_FILE"




if [ "$ACTIVATE" == "--activate" ]; then
    # Reload systemd and Nginx to apply changes
    sudo systemctl daemon-reload
    sudo systemctl restart nginx

    # Enable and start the socket
    sudo systemctl start gunicorn.socket
    sudo systemctl enable gunicorn.socket

    # Reload systemd and Nginx to apply changes
    sudo ln -sf "$NGINX_CONF_FILE" "$NGINX_LINK"
    sudo systemctl restart nginx
    sudo ufw allow 'Nginx Full'

    echo "Gunicorn service, socket, and Nginx configuration for $PROJECT_NAME have been set up and activated successfully."
else
    echo "Gunicorn service, socket, and Nginx configuration files have been created. Run with --activate to start services."
fi