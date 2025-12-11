# Open OnDemand Docker Development Setup

This guide explains how to run Open OnDemand in a Docker container for local development without modifying your local filesystem.

## Prerequisites

- Docker installed and running
- Source code cloned to your local machine

## Quick Start

### 1. Build the Docker Image

```bash
cd /path/to/ondemand
docker build -t ood-dev:latest -f Dockerfile.dev \
  --build-arg USER=$(whoami) \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) .
```

### 2. Start the Container

```bash
docker run -d --name ood-dev --privileged \
  -p 8080:8080 -p 5556:5556 \
  -v /path/to/ondemand:/opt/ood/src:ro \
  ood-dev:latest
```

### 3. Configure Authentication

Wait a few seconds for the container to start, then create the portal configuration:

```bash
# Generate password hash (using 'password' as the password)
PASS_HASH=$(docker exec ood-dev htpasswd -nbBC 10 '' 'password' | tr -d ':')

# Create portal config with your username
docker exec ood-dev bash -c "cat > /etc/ood/config/ood_portal.yml << EOF
servername: localhost
port: 8080
listen_addr_port: 8080
oidc_remote_user_claim: email
dex:
  static_passwords:
    - email: $(whoami)@localhost
      hash: \"$PASS_HASH\"
      username: $(whoami)
      userID: 71e63e31-7af3-41d7-add2-575568f4525f
EOF"
```

### 4. Generate SSL Certificate

```bash
docker exec ood-dev openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/localhost.key \
  -out /etc/pki/tls/certs/localhost.crt \
  -subj '/CN=localhost'
```

### 5. Fix PAM Configuration for Sudo

The apache user needs to run sudo commands. Fix the PAM configuration:

```bash
docker exec -u root ood-dev sh -c 'cat > /etc/pam.d/sudo << EOF
#%PAM-1.0
auth       include      system-auth
account    sufficient   pam_permit.so
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOF'
```

### 6. Apply Configuration and Restart Services

```bash
docker exec ood-dev bash -c "/opt/ood/ood-portal-generator/sbin/update_ood_portal --rpm -f --insecure && systemctl restart httpd ondemand-dex"
```

### 7. Access the Application

Open http://localhost:8080/ in your browser.

**Login credentials:**
- **Email:** `<your-username>@localhost`
- **Password:** `password`

## One-Liner Setup Script

For convenience, here's a complete setup script:

```bash
#!/bin/bash
set -e

CONTAINER_NAME="ood-dev"
USERNAME=$(whoami)
PASSWORD="password"

# Build image
docker build -t ood-dev:latest -f Dockerfile.dev \
  --build-arg USER=$USERNAME \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) .

# Remove existing container if exists
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Start container
docker run -d --name $CONTAINER_NAME --privileged \
  -p 8080:8080 -p 5556:5556 \
  -v "$(pwd):/opt/ood/src:ro" \
  ood-dev:latest

# Wait for container to be ready
sleep 5

# Generate password hash
PASS_HASH=$(docker exec $CONTAINER_NAME htpasswd -nbBC 10 '' "$PASSWORD" | tr -d ':')

# Create portal config
docker exec $CONTAINER_NAME bash -c "cat > /etc/ood/config/ood_portal.yml << EOF
servername: localhost
port: 8080
listen_addr_port: 8080
oidc_remote_user_claim: email
dex:
  static_passwords:
    - email: ${USERNAME}@localhost
      hash: \"$PASS_HASH\"
      username: $USERNAME
      userID: 71e63e31-7af3-41d7-add2-575568f4525f
EOF"

# Generate SSL certificate
docker exec $CONTAINER_NAME openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/localhost.key \
  -out /etc/pki/tls/certs/localhost.crt \
  -subj '/CN=localhost'

# Fix PAM for sudo
docker exec -u root $CONTAINER_NAME sh -c 'cat > /etc/pam.d/sudo << EOF
#%PAM-1.0
auth       include      system-auth
account    sufficient   pam_permit.so
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOF'

# Apply config and restart services
docker exec $CONTAINER_NAME bash -c "/opt/ood/ood-portal-generator/sbin/update_ood_portal --rpm -f --insecure && systemctl restart httpd ondemand-dex"

echo ""
echo "✅ Open OnDemand is running!"
echo "   URL: http://localhost:8080/"
echo "   Email: ${USERNAME}@localhost"
echo "   Password: $PASSWORD"
```

## Useful Commands

```bash
# Stop the container
docker stop ood-dev

# Start the container again
docker start ood-dev

# Access container shell
docker exec -it ood-dev bash

# View service logs
docker exec ood-dev journalctl -u httpd -u ondemand-dex --no-pager -n 50

# Restart services inside container
docker exec ood-dev systemctl restart httpd ondemand-dex

# Remove container completely
docker rm -f ood-dev

# Remove image
docker rmi ood-dev:latest
```

## Troubleshooting

### Login succeeds but page shows error

Check the logs for sudo/PAM issues:
```bash
docker exec ood-dev journalctl -u httpd --no-pager -n 50
```

If you see `account validation failure`, apply the PAM fix from step 5.

### Services not running

Check if systemd services are active:
```bash
docker exec ood-dev systemctl status httpd ondemand-dex
```

### SSL Certificate errors

Regenerate the SSL certificate:
```bash
docker exec ood-dev openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/localhost.key \
  -out /etc/pki/tls/certs/localhost.crt \
  -subj '/CN=localhost'
docker exec ood-dev systemctl restart httpd
```

### Container won't start with systemd

Make sure you're using `--privileged` flag when running the container. Systemd requires elevated privileges to function properly in Docker.

## AI Assistant Feature

The dashboard includes an AI-powered assistant that helps users manage HPC tasks. A floating chat bubble appears in the bottom-right corner of every page.

### Enabling the AI Assistant

Set the OpenAI API key as an environment variable in the container:

```bash
docker exec ood-dev bash -c 'echo "OPENAI_API_KEY=your-api-key-here" >> /etc/ood/config/apps/dashboard/env'
docker exec ood-dev systemctl restart httpd
```

Or add it to the container run command:
```bash
docker run -d --name ood-dev --privileged \
  -p 8080:8080 -p 5556:5556 \
  -e OPENAI_API_KEY=your-api-key-here \
  -v /path/to/ondemand:/opt/ood/src:ro \
  ood-dev:latest
```

### Assistant Capabilities

The AI assistant can help users:
- **List and manage jobs** - View job status, get details, delete jobs
- **Browse files** - List directories, read file contents, get file info
- **Check cluster status** - View cluster information and job queues
- **View interactive sessions** - List active Jupyter, Desktop, etc. sessions
- **Discover available apps** - List interactive applications that can be launched

### Configuration Options

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `OPENAI_API_KEY` | (required) | Your OpenAI API key |
| `OPENAI_MODEL` | `gpt-4o-mini` | OpenAI model to use |

## Notes

- The source code is mounted as read-only (`ro`) to prevent accidental modifications
- All configuration is stored inside the container and will be lost when the container is removed
- The container uses Rocky Linux 8 as the base OS
- Ports 8080 (HTTP) and 5556 (Dex IDP) are exposed
