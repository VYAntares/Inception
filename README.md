*This project has been created as part of the 42 curriculum by LOGIN.*

# Inception

## Description

Inception is a system administration project that uses Docker to set up a
small infrastructure composed of different services. The project creates a
complete web hosting environment with NGINX, WordPress, and MariaDB, all
running in separate Docker containers inside a Virtual Machine.

The goal is to understand containerization, service orchestration, and
security best practices.

## Instructions

> 🚧 This section will be completed as the project progresses.

### Prerequisites

- A Virtual Machine running Debian 12 (Bookworm)
- Docker and Docker Compose V2 installed
- `make` and `git` installed

### Quick Start

```bash
# Clone the repository
git clone <repo_url> && cd inception

# Run the project
make
```

---

## Project Description

### Virtual Machines vs Docker

A **Virtual Machine (VM)** runs a complete operating system with its own kernel
on top of a hypervisor. It is heavy (several GBs), slow to start (minutes),
and fully isolated from the host.

A **Docker container** shares the host OS kernel and only packages the
application and its dependencies. It is lightweight (MBs), starts in seconds,
and provides process-level isolation.

```
Virtual Machine                Docker Container
───────────────                ────────────────
┌──────────────┐               ┌──────────────┐
│ Application  │               │ Application  │
├──────────────┤               ├──────────────┤
│ Full OS      │  ← Heavy      │ Dependencies │  ← Light
├──────────────┤               ├──────────────┤
│ Hypervisor   │               │ Docker Engine│
├──────────────┤               ├──────────────┤
│ Host OS      │               │ Host OS      │
└──────────────┘               └──────────────┘

Startup : ~2 minutes           Startup : ~2 seconds
Size    : 1–10 GB              Size    : 10–500 MB
```

**Key difference:** In this project, the VM hosts Docker, and Docker hosts the
three services (NGINX, WordPress, MariaDB). The containers share the VM's kernel
but are isolated from each other.

### Docker Image vs Docker Container

A **Docker image** is an immutable template (the recipe) that defines everything
needed to run a service: the base OS layer, installed packages, configuration
files, and the startup command.

A **Docker container** is a running instance of an image (the cake baked from
the recipe). You can create multiple containers from the same image. When a
container stops, the image remains unchanged.

```
Image (recipe)    →    Container (running instance)
docker build           docker run

Like a class      →    Like an object instance in OOP
```

### Secrets vs Environment Variables

> 🚧 This section will be completed when we implement secrets management.

### Docker Network vs Host Network

A **Docker Network** creates an isolated virtual network where containers
communicate with each other using their service names as hostnames. Docker
acts as an internal DNS resolver — no need to know IP addresses.

```
Docker Network "inception"
┌─────────────────────────────────────────┐
│  nginx  ──────  wordpress  ──  mariadb  │
│    ↑                                    │
│  only port 443 exposed to the outside   │
└─────────────────────────────────────────┘
```

**Host Network** removes network isolation entirely: the container shares
the host machine's network stack directly. This is forbidden in Inception
because it bypasses container isolation and exposes all ports.

With Docker Network, WordPress reaches MariaDB simply with:
```php
define('DB_HOST', 'mariadb'); // Docker resolves the name automatically
```

### How a request travels through the infrastructure

When a user visits `https://login.42.fr`:

```
1. Browser asks: "what is login.42.fr ?"
2. /etc/hosts answers: "it's 127.0.0.1" (no real DNS needed)
3. Browser sends HTTPS request to port 443
           ↓
4. NGINX receives it → decrypts HTTPS
        ↓                    ↓
   Static file          PHP file (.php)
   (CSS, JS, img)       (WordPress page)
   NGINX serves         NGINX forwards
   it directly    →     to PHP-FPM
   ⚡ Fast                    ↓
                      WordPress executes PHP
                              ↓
                      Queries MariaDB for data
                              ↓
                      Generates HTML response
                              ↓
                      NGINX encrypts and sends back
```

NGINX does not forward everything to WordPress because static files
(CSS, images, JS) do not need PHP execution. NGINX serves them directly,
which is faster and avoids unnecessary load on PHP-FPM.

### Docker Volumes vs Bind Mounts

> 🚧 This section will be completed when we set up persistent storage.

---

## Resources

### Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)

### AI Usage

AI tools (Claude) were used throughout this project for:
- Understanding Docker concepts (containers vs images, volumes, networks)
- Learning how services communicate inside a Docker network
- Debugging configuration issues in Dockerfiles and docker-compose
- Understanding TLS/SSL certificate generation with OpenSSL
- Understanding NGINX reverse proxy and FastCGI configuration

All AI-generated content was reviewed, tested, and adapted to reflect a
genuine understanding of each component. The implementation decisions and
final code are the result of learning, not blind copy-paste.
