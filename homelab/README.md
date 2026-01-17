# Homelab (infinage.space)

Docker Compose + Caddy setup for serving all `*.infinage.space` subdomains.

---

## DNS (Namecheap)

Already configured:

* **A record**

  * Host: `*`
  * Value: `<Lightsail / EC2 public IP>`

No further DNS changes required.

---

## Server Setup

Installed on the server:

* Docker
* Docker Compose
* Git (optional)

Nothing else is needed.

---

## Start Everything

```bash
git clone git@github.com:infinage/infinage.git
cd infinage/homelab
docker compose up -d
```

Caddy acts as the single public entry point.

---

## How Routing Works

* Only **Caddy** binds to the host network
* All services run on the Docker network
* No service exposes ports directly
* Routing is hostname-based (subdomain → container)

```
subdomain.infinage.space → Caddy → service:port
```

---

## Adding a New Service

### 1. Caddyfile

```caddy
http://download.infinage.space, http://download.localhost {
    reverse_proxy download-proxy:8080
}
```

* Port must match the app’s internal listening port

---

### 2. docker-compose.yml

```yaml
download-proxy:
  image: docker.io/infinage/download-proxy
  restart: unless-stopped
```

* Image must be public
* No `ports:` section needed

> Rule: if a subdomain exists, it **must** have a Caddyfile entry.

---

## Image Guidelines

* Use multi-stage builds
* Keep images lean
* Be explicit about the internal listening port

---

## Local Testing

Subdomains work locally via:

* `http://service.localhost`

No `/etc/hosts` changes required.

---
