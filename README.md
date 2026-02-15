# Inception

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=flat&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=flat&logo=wordpress&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white)

> *A complete web hosting infrastructure using Docker containers*

**Inception** is a system administration project from the 42 curriculum that demonstrates how to build and orchestrate a multi-service web infrastructure using Docker. The project creates a production-like environment with NGINX, WordPress, and MariaDB running in isolated containers.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Understanding the Stack](#-understanding-the-stack)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Resources](#-resources)

---

## 🎯 Overview

This project sets up a complete web hosting environment inside a Virtual Machine using Docker containers. The infrastructure includes:

- **NGINX** - Web server with SSL/TLS encryption (reverse proxy)
- **WordPress** - Content Management System with PHP-FPM
- **MariaDB** - Relational database for WordPress data

All services run in separate Docker containers, communicate through a private network, and persist data using Docker volumes.

### Key Features

✅ **Custom Docker images** - Built from scratch (no pre-built images from DockerHub)  
✅ **Secure HTTPS** - TLS v1.2/v1.3 encryption with auto-generated certificates  
✅ **Isolated network** - Services communicate only through internal Docker network  
✅ **Persistent storage** - Data survives container restarts via Docker volumes  
✅ **Secrets management** - Passwords stored securely outside version control  
✅ **Production-ready** - Follows Docker and security best practices

---

## 🏗️ Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Internet / Browser                      │
│                   https://eahmeti.42.fr                    │
└───────────────────────────┬────────────────────────────────┘
                            │
                            │ HTTPS (Port 443)
                            │ TLS v1.2/v1.3
                            ▼
                   ┌────────────────┐
                   │      NGINX     │
                   │   (debian:11)  │  ← Reverse Proxy + SSL Termination
                   │                │  ← Serves static files directly
                   └────────┬───────┘
                            │
                            │ FastCGI (Port 9000)
                            │ Internal only
                            ▼
                   ┌────────────────┐
                   │    WordPress   │
                   │   (debian:11)  │  ← PHP-FPM processes PHP files
                   │   + PHP-FPM    │  ← Generates dynamic content
                   └────────┬───────┘
                            │
                            │ MySQL Protocol (Port 3306)
                            │ Internal only
                            ▼
                   ┌────────────────┐
                   │     MariaDB    │
                   │   (debian:11)  │  ← Stores WordPress data
                   │                │  ← Users, posts, settings, etc.
                   └────────────────┘

Docker Network: inception (bridge mode)
Volumes: wordpress_data → ~/data/wordpress
         mariadb_data   → ~/data/mariadb
```

### Service Details

| Service | Base Image | Exposed Ports | Internal Ports | Volume Mount |
|---------|-----------|---------------|----------------|--------------|
| **NGINX** | debian:bullseye | 443 (HTTPS) | - | wordpress_data (read-only) |
| **WordPress** | debian:bullseye | - | 9000 (FastCGI) | wordpress_data (read-write) |
| **MariaDB** | debian:bullseye | - | 3306 (MySQL) | mariadb_data (read-write) |

---

## 🚀 Quick Start

### TL;DR - Get it running in 3 steps

```bash
# 1. Configure domain name
echo "127.0.0.1 eahmeti.42.fr" | sudo tee -a /etc/hosts

# 2. Create secrets
mkdir -p secrets/
echo "rootpassword123" > secrets/db_root_password.txt
echo "wppassword123" > secrets/db_password.txt
echo "wp_admin_password=adminpassword123" > secrets/credentials.txt
echo "wp_user_password=userpassword123" >> secrets/credentials.txt

# 3. Launch infrastructure
make
```

**Access your site:**
- 🌐 Website: https://eahmeti.42.fr
- 🔐 Admin panel: https://eahmeti.42.fr/wp-admin
  - Admin user: `eahmeti` / `adminpassword123`
  - Regular user: `user` / `userpassword123`

---

## 📦 Installation


### Step 1: Clone the Repository

```bash
git clone <repository_url> inception
cd inception
```

### Step 2: Configure Domain Name

Add your domain to `/etc/hosts` so your browser knows where to find it:

```bash
# Open /etc/hosts with your favorite editor
sudo nano /etc/hosts

# Add this line at the end:
127.0.0.1 eahmeti.42.fr

# Save and exit (Ctrl+O, Enter, Ctrl+X in nano)
```

**Note:** Replace `eahmeti` with your actual 42 login if you forked this project.

### Step 3: Create Secrets Directory

Docker secrets are used to store sensitive information securely:

```bash
# Create secrets directory
mkdir -p secrets/

# MariaDB root password
echo "your_secure_root_password" > secrets/db_root_password.txt

# MariaDB WordPress user password
echo "your_secure_db_password" > secrets/db_password.txt

# WordPress admin and user passwords
echo "wp_admin_password=your_secure_admin_password" > secrets/credentials.txt
echo "wp_user_password=your_secure_user_password" >> secrets/credentials.txt
```

**Security note:** These files should **never** be committed to Git. They're already in `.gitignore`.

### Step 4: Create Data Directories

The Makefile handles this automatically, but you can create them manually:

```bash
mkdir -p ~/data/mariadb
mkdir -p ~/data/wordpress
```

### Step 5: Configure Environment Variables

The `.env` file is already configured in `srcs/.env`. If you changed your login, update it:

```bash
nano srcs/.env

DOMAIN_NAME=eahmeti.42.fr

DB_NAME=wordpress
DB_USER=wpuser

MYSQL_HOST=mariadb
```

### Step 6: Build and Launch

```bash
# Build images and start containers
make

# Or step by step:
make setup    # Create data directories
make build    # Build Docker images
make up       # Start containers
```

### Step 7: Verify Installation

```bash
# Check that all containers are running
docker compose -f srcs/docker-compose.yml ps

# Expected output:
# NAME        IMAGE              STATUS
# mariadb     inception_mariadb  Up
# wordpress   inception_wordpress Up
# nginx       inception_nginx    Up

# Check logs if needed
make logs
```

### Step 8: Access WordPress

Open your browser and navigate to:
- **Website:** https://eahmeti.42.fr
- **Admin panel:** https://eahmeti.42.fr/wp-admin

You'll see a security warning (certificate is self-signed) - click "Advanced" and "Proceed to site".

---

## 🛠️ Usage

### Make Commands

The Makefile provides convenient commands to manage the infrastructure:

| Command | Description |
|---------|-------------|
| `make` or `make all` | Setup directories + build images + start containers |
| `make setup` | Create data directories in ~/data/ |
| `make build` | Build all Docker images |
| `make up` | Start all containers in detached mode |
| `make down` | Stop all containers (keeps volumes) |
| `make down-v` | Stop containers and remove volumes |
| `make re` | Full restart (fclean + all) |
| `make clean` | Stop and remove containers |
| `make fclean` | Complete cleanup (containers + images + volumes + data) |
| `make logs` | Show live logs from all containers |
| `make ps` | List running containers |

### Common Workflows

#### Starting the infrastructure

```bash
make
```

#### Viewing logs in real-time

```bash
# All services
make logs

# Specific service
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

#### Accessing a container shell

```bash
# NGINX (Alpine-based, uses sh)
docker exec -it nginx sh

# WordPress (Debian-based, uses bash)
docker exec -it wordpress bash

# MariaDB
docker exec -it mariadb bash
```

#### Connecting to MariaDB

```bash
# From host machine
docker exec -it mariadb mysql -u root -p
# Password: content of secrets/db_root_password.txt

# Once connected:
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

#### Testing WordPress database connection

```bash
# From WordPress container
docker exec -it wordpress mysql -h mariadb -u wpuser -p
# Password: content of secrets/db_password.txt

# Verify connection
SHOW DATABASES;
USE wordpress;
```

#### Stopping the infrastructure

```bash
# Stop containers (keeps data)
make down

# Stop containers and remove volumes (data lost!)
make down-v
```

#### Complete cleanup and rebuild

```bash
# Full cleanup (removes everything)
make fclean

# Rebuild from scratch
make
```

---

## 📂 Project Structure

```
inception/
├── Makefile                          # Build and management commands
├── README.md                         # This file
├── .gitignore                        # Git ignore rules (includes secrets/)
│
├── secrets/                          # 🔒 NOT in Git - create manually
│   ├── db_root_password.txt          # MariaDB root password
│   ├── db_password.txt               # MariaDB WordPress user password
│   └── credentials.txt               # WordPress admin and user passwords
│
└── srcs/                             # Source files (required by subject)
    ├── .env                          # Environment variables
    ├── docker-compose.yml            # Service orchestration
    └── requirements/                 # Service-specific files
        │
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image definition
        │   ├── conf/
        │   │   └── 50-server.cnf     # MariaDB server configuration
        │   └── tools/
        │       └── init-db.sh        # Database initialization script
        │
        ├── wordpress/
        │   ├── Dockerfile            # WordPress + PHP-FPM image
        │   ├── conf/
        │   │   └── www.conf          # PHP-FPM pool configuration
        │   └── tools/
        │       └── init-wordpress.sh # WordPress setup script (WP-CLI)
        │
        └── nginx/
            ├── Dockerfile            # NGINX image definition
            ├── conf/
            │   └── nginx.conf        # NGINX server configuration
            └── tools/
                └── init-nginx.sh     # SSL certificate generation script
```

---

## 📚 Understanding the Stack

### Virtual Machines vs Docker

#### Virtual Machine (VM)

A **Virtual Machine** runs a complete operating system with its own kernel on top of a hypervisor. It's a full computer simulation.

```
┌──────────────────┐
│   Application    │
├──────────────────┤
│   Full Guest OS  │  ← Entire OS (kernel + userland)
├──────────────────┤
│    Hypervisor    │  ← Hardware virtualization layer
├──────────────────┤
│     Host OS      │
├──────────────────┤
│    Hardware      │
└──────────────────┘

Startup time: 1-5 minutes
Size: 1-10 GB per VM
Isolation: Strong (separate kernels)
```

#### Docker Container

A **Docker container** shares the host OS kernel and only packages the application and its dependencies.

```
┌──────────────────┐
│   Application    │
├──────────────────┤
│   Dependencies   │  ← Only what the app needs
├──────────────────┤
│  Docker Engine   │  ← Container runtime
├──────────────────┤
│     Host OS      │  ← Shared kernel
├──────────────────┤
│    Hardware      │
└──────────────────┘

Startup time: 1-5 seconds
Size: 10-500 MB per container
Isolation: Process-level (same kernel)
```

**In this project:**
- The VM hosts Docker
- Docker hosts the three containers (NGINX, WordPress, MariaDB)
- The containers share the VM's kernel but are isolated from each other

---

### Docker Image vs Docker Container

#### Docker Image

A **Docker image** is an immutable template - it's the recipe that defines everything needed to run a service:

- Base operating system layer
- Installed packages and dependencies
- Configuration files
- Environment variables
- Startup command

**Think of it as:** A class in Object-Oriented Programming, or a blueprint.

#### Docker Container

A **Docker container** is a running instance of an image - it's the actual environment executing your application.

- Created from an image
- Has its own filesystem (writable layer on top of image)
- Can be started, stopped, deleted
- Multiple containers can run from the same image

**Think of it as:** An object instance in OOP, or a house built from a blueprint.

```
┌────────────────┐        docker run         ┌──────────────────┐
│  Docker Image  │  ──────────────────────>  │ Docker Container │
│   (Template)   │                           │    (Instance)    │
└────────────────┘                           └──────────────────┘
        ↑                                              ↑
   docker build                                 Running process
        │                                              │
    Dockerfile                                 Isolated environment
```

**Example:**
```bash
# Build image from Dockerfile (the recipe)
docker build -t my-nginx .

# Create and run container from image (the running instance)
docker run -d --name webserver my-nginx

# Can create multiple containers from same image
docker run -d --name webserver2 my-nginx
docker run -d --name webserver3 my-nginx
```

---

### Docker Network

A **Docker Network** creates an isolated virtual network where containers can communicate with each other using their service names as hostnames.

```
Docker Network "inception" (bridge mode)
┌─────────────────────────────────────────────────┐
│                                                 │
│    nginx ←──────→ wordpress ←──────→ mariadb    │
│  (container)     (container)       (container)  │
│                                                 │
│  Internal DNS: Docker resolves names            │
│  • nginx → 172.18.0.2                           │
│  • wordpress → 172.18.0.3                       │
│  • mariadb → 172.18.0.4                         │
│                                                 │
└──────────────────┬──────────────────────────────┘
                   │
                   │ Only port 443 exposed
                   ↓
              Outside world
```

**Benefits:**
- **Service discovery:** No need to know IP addresses, use service names
- **Isolation:** Services can't access containers outside their network
- **Security:** Internal communication doesn't leave the host

**Example in docker-compose.yml:**
```yaml
services:
  nginx:
    networks:
      - inception
  wordpress:
    networks:
      - inception
  mariadb:
    networks:
      - inception

networks:
  inception:
    driver: bridge
```

**Inside the WordPress container:**
```php
// WordPress can reach MariaDB simply with the service name
define('DB_HOST', 'mariadb');  // Docker resolves this automatically!
```

**Why `network: host` is forbidden:**
- Removes network isolation entirely
- Container shares the host's network stack directly
- All ports are exposed (security risk)
- Bypasses Docker's built-in DNS and service discovery

---

### How a Request Flows Through the Infrastructure

When a user visits `https://eahmeti.42.fr`:

```
1️⃣ DNS Resolution
   Browser asks: "What is eahmeti.42.fr?"
   /etc/hosts answers: "127.0.0.1" (localhost)
   
2️⃣ HTTPS Request
   Browser → Port 443 → NGINX container
   
3️⃣ SSL/TLS Decryption
   NGINX decrypts HTTPS using its private key
   
4️⃣ Request Routing
   NGINX examines the requested file:
   
   ┌─────────────────────────────────────┐
   │ Static file?     │ PHP file?        │
   │ (.css, .js,      │ (.php, WordPress │
   │  .jpg, .png)     │  dynamic pages)  │
   ├──────────────────┼──────────────────┤
   │ NGINX serves     │ NGINX forwards   │
   │ directly         │ to WordPress     │
   │ ⚡ Fast           │ via FastCGI      │
   └─────────────────────────────────────┘
   
5️⃣ PHP Processing (if needed)
   WordPress (PHP-FPM) receives the request
   Executes PHP code
   
6️⃣ Database Query (if needed)
   WordPress → MariaDB (port 3306)
   Fetches posts, users, settings, etc.
   
7️⃣ Response Generation
   WordPress generates HTML
   Sends back to NGINX
   
8️⃣ SSL/TLS Encryption
   NGINX encrypts the response
   Sends HTTPS response to browser
```

**Why doesn't NGINX forward everything to WordPress?**

Static files (CSS, images, JavaScript) don't need PHP execution:
- **Faster:** NGINX serves them directly from disk
- **Less load:** PHP-FPM doesn't have to process them
- **More efficient:** NGINX is optimized for static file serving

---

### Docker Volumes

Docker volumes provide persistent storage that survives container restarts and deletions.

#### Types of Volume Mounts

**1. Named Volume (managed by Docker)**
```yaml
volumes:
  wordpress_data:  # Docker manages this automatically
    driver: local
```

**2. Bind Mount (specific host directory)**
```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/eahmeti/data/wordpress  # Specific host path
```

**Why bind mounts in this project?**
- Subject requirement: data must be in `~/data/` on the host
- Easy to backup: just copy `~/data/` directory
- Easy to inspect: can browse files directly on the host
- Persists even if volumes are deleted: `docker volume rm` doesn't delete host files

**Volume sharing example:**
```yaml
services:
  nginx:
    volumes:
      - wordpress_data:/var/www/html  # Read-only access
  wordpress:
    volumes:
      - wordpress_data:/var/www/html  # Read-write access
```

Both NGINX and WordPress access the same files:
- WordPress creates/modifies WordPress files
- NGINX reads them to serve static content

---

### Secrets Management

Secrets (passwords, API keys) should **never** be:
- Hardcoded in Dockerfiles
- Committed to Git
- Stored in environment variables (visible with `docker inspect`)

#### Docker Secrets (used in this project)

```yaml
services:
  mariadb:
    secrets:
      - db_password
      - db_root_password

secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
```

**How it works:**
1. Secret files are read from the host
2. Mounted as read-only files in `/run/secrets/` inside the container
3. Application reads them at runtime

**Inside the container:**
```bash
# Secret is available as a file
cat /run/secrets/db_password
# Output: wppassword123

# In bash script:
DB_PASSWORD=$(cat /run/secrets/db_password)
```

**Benefits:**
- Not visible in `docker inspect`
- Not in environment variables
- Not in image layers
- Can be rotated without rebuilding images

---

### NGINX as Reverse Proxy

**What is a reverse proxy?**

A reverse proxy sits between clients and backend servers, forwarding requests and responses.

```
Normal web server:
Browser ──────> NGINX ──────> Static files (disk)

Reverse proxy:
Browser ──────> NGINX ──────> Backend app (WordPress)
                  ↑
                  └──── Also serves static files directly
```

**Why use NGINX as a reverse proxy?**

1. **SSL/TLS Termination**
   - NGINX handles encryption/decryption
   - Backend doesn't need to worry about HTTPS
   - Certificates managed in one place

2. **Load Balancing** (not used in this project, but possible)
   - Distribute requests across multiple backends
   - Health checks and failover

3. **Caching**
   - Cache responses from backend
   - Reduce load on PHP-FPM

4. **Static File Serving**
   - NGINX is 2-3x faster than PHP-FPM for static files
   - Offloads work from the application

5. **Security**
   - Single point of entry (port 443)
   - Backend services not exposed directly
   - Can add rate limiting, IP filtering, etc.

**In our configuration:**
```nginx
location ~ \.php$ {
    fastcgi_pass wordpress:9000;  # Forward PHP to WordPress
    # ... FastCGI params ...
}

location / {
    try_files $uri $uri/ /index.php?$args;  # Try static first, then PHP
}
```

---

## 🔒 Security

### Secure Configuration

#### 1. Network Isolation

```yaml
# ✅ Good - Only NGINX exposed
ports:
  - "443:443"  # NGINX only

# ❌ Bad - Exposing everything
ports:
  - "443:443"   # NGINX
  - "9000:9000" # WordPress (shouldn't be public!)
  - "3306:3306" # MariaDB (major security risk!)
```

#### 2. No Host Network Mode

```yaml
# ❌ Forbidden - Exposes all ports
services:
  nginx:
    network_mode: host

# ✅ Correct - Isolated bridge network
services:
  nginx:
    networks:
      - inception
```

#### 3. Secrets Outside Version Control

```bash
# ✅ Secrets in gitignore
secrets/
*.txt

# ✅ Created during deployment
echo "password" > secrets/db_password.txt

# ❌ Never do this
git add secrets/db_password.txt
```

#### 4. SSL/TLS Configuration

```nginx
# ✅ Modern protocols only
ssl_protocols TLSv1.2 TLSv1.3;

# ❌ Insecure old protocols
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```

#### 5. MariaDB User Privileges

```sql
-- ✅ Least privilege principle
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
-- wpuser can only access wordpress database

-- ❌ Too permissive
GRANT ALL PRIVILEGES ON *.* TO 'wpuser'@'%';
-- wpuser can access ALL databases (dangerous!)
```

### Security Checklist

- ✅ Secrets stored in `/run/secrets/` (Docker secrets)
- ✅ Only port 443 exposed to the internet
- ✅ TLS v1.2 and v1.3 only (no older protocols)
- ✅ Self-signed certificate with proper CN (Common Name)
- ✅ MariaDB accessible only from Docker network
- ✅ WordPress user has minimal database privileges
- ✅ No passwords in environment variables or Dockerfiles
- ✅ All services run as non-root users (www-data, mysql)

---

### Debugging Commands

```bash
# View real-time logs
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb

# Check container resource usage
docker stats

# Inspect container configuration
docker inspect nginx
docker inspect wordpress
docker inspect mariadb

# Check network connectivity
docker exec -it wordpress ping mariadb
docker exec -it nginx ping wordpress

# List all Docker resources
docker ps -a           # All containers
docker images          # All images
docker volume ls       # All volumes
docker network ls      # All networks

# Clean up everything (nuclear option)
docker system prune -a --volumes
```

---

## 📖 Resources

### Official Documentation

- **Docker**
  - [Docker Documentation](https://docs.docker.com/)
  - [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
  - [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

- **NGINX**
  - [NGINX Documentation](https://nginx.org/en/docs/)
  - [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
  - [FastCGI Module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)

- **WordPress**
  - [WordPress Developer Resources](https://developer.wordpress.org/)
  - [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
  - [WordPress Requirements](https://wordpress.org/about/requirements/)

- **MariaDB**
  - [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
  - [MariaDB Server Documentation](https://mariadb.com/kb/en/mariadb-server-documentation/)

- **PHP-FPM**
  - [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
  - [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### Learning Resources

- **Docker Tutorials**
  - [Docker Get Started](https://docs.docker.com/get-started/)
  - [Docker Curriculum](https://docker-curriculum.com/)
  - [Play with Docker](https://labs.play-with-docker.com/)

- **Networking**
  - [Docker Networking Overview](https://docs.docker.com/network/)
  - [Understanding Docker Bridge Networks](https://docs.docker.com/network/bridge/)

- **Security**
  - [Docker Security Best Practices](https://docs.docker.com/engine/security/)
  - [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

### Tools Used

- [Docker](https://www.docker.com/) - Container platform
- [Docker Compose](https://docs.docker.com/compose/) - Multi-container orchestration
- [NGINX](https://nginx.org/) - Web server and reverse proxy
- [WordPress](https://wordpress.org/) - Content Management System
- [MariaDB](https://mariadb.org/) - Relational database (MySQL fork)
- [PHP-FPM](https://php-fpm.org/) - FastCGI Process Manager for PHP
- [WP-CLI](https://wp-cli.org/) - WordPress command-line interface
- [OpenSSL](https://www.openssl.org/) - SSL/TLS certificate generation

---

## 🤖 AI Usage Disclaimer

AI tools (Claude by Anthropic) were used throughout this project for:

- Understanding Docker concepts (containers, images, volumes, networks)
- Learning service communication inside Docker networks
- Debugging configuration issues in Dockerfiles and docker-compose
- Understanding TLS/SSL certificate generation with OpenSSL
- Understanding NGINX reverse proxy and FastCGI configuration
- Explaining best practices for security and performance

**All AI-generated content was:**
- Thoroughly reviewed and tested
- Adapted to demonstrate genuine understanding
- Used as a learning tool, not a copy-paste solution

The implementation decisions and final code reflect real comprehension of each component, not blind AI output copying.

---

## 📝 Notes

### Why Debian Bullseye (11) instead of Bookworm (12)?

The subject requires the **penultimate stable** version of Alpine or Debian:
- Debian 12 (Bookworm) = current stable
- Debian 11 (Bullseye) = penultimate stable ✅

### Why No Port 80?

The subject requires **only HTTPS (port 443)** to be exposed. Port 80 (HTTP) is not configured, forcing all traffic through encrypted HTTPS.

### Why Self-Signed Certificates?

In a learning/development environment:
- No need for a real Certificate Authority (CA)
- Faster to generate and test
- Demonstrates understanding of SSL/TLS without external dependencies

In production, you would use:
- [Let's Encrypt](https://letsencrypt.org/) for free, automated certificates
- Commercial CA for enterprise requirements

### Why Separate Containers?

Each service runs in its own container following the **single responsibility principle**:
- Easier to scale (can run multiple WordPress instances)
- Easier to update (update NGINX without touching WordPress)
- Better isolation (security and resource management)
- Follows Docker best practices

---

## 📄 License

This project is part of the 42 school curriculum.

---

## 👤 Author

**Created by:** eahmeti  
**School:** 42  
**Project:** Inception

---

*Made with ☕ and 🐳 Docker*
