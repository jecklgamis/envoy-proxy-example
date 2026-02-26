# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Envoy Proxy reference implementation demonstrating a containerized reverse proxy setup. It runs Envoy as a front proxy with a simple Node.js echo server as the upstream application, managed by supervisor.

## Build and Run Commands

```bash
# Generate SSL certs then build image in one step
make all

# Generate SSL certs + build + run
make up

# Individual steps
./generate-ssl-certs.sh   # Must run before first build (generates server.crt / server.key)
make image                # Build Docker image (tagged with current branch name)
make run                  # Run container with port mappings
make run-shell            # Run with interactive shell
make exec-shell           # Exec into already-running container

# Generate continuous test traffic (runs curl in a loop)
./generate-traffic.sh
```

## Architecture

```
Client → Envoy Proxy (8080/HTTP, 8443/HTTPS) → Node.js App (5050 internal)
              ↓
         Admin API (9901)
```

**Process Management:** The container uses `supervisor` to run two processes:
1. **Envoy Proxy** (`run-envoy.sh`) - Starts with log level `error`, reads `/etc/envoy/envoy.yaml`
2. **Node.js App** (`run-app.sh` → `app.js 5050`) - Echo server on port 5050 that returns request metadata as JSON

**Key Files:**
- `config/envoy.yaml` - Envoy static configuration (listeners, clusters, routes)
- `supervisor.ini` - Process supervisor config; both processes log to stdout
- `app.js` - Upstream HTTP echo server; takes port as CLI argument
- `Dockerfile` - Based on `envoyproxy/envoy:v1.35-latest`; installs nodejs, supervisor, dumb-init

## Testing Endpoints

```bash
# HTTP request
curl http://localhost:8080

# HTTPS request (self-signed cert)
curl -k https://localhost:8443

# Envoy admin endpoints
curl http://localhost:9901/stats
curl http://localhost:9901/clusters
curl http://localhost:9901/config_dump
```

## Envoy Configuration

`config/envoy.yaml` defines:
- **Admin interface** on port 9901
- **HTTPS listener** on port 8443 with TLS termination (cert/key from `/etc/server.crt` and `/etc/server.key`)
- **HTTP listener** on port 8080
- **Cluster** `default_app` — LOGICAL_DNS, ROUND_ROBIN, connects to 127.0.0.1:5050 with 0.25s connect timeout

Both listeners route all traffic (`prefix: /`) to `default_app` with a 15s request timeout.

## Kubernetes / Helm

```bash
cd deployment/k8s/helm
make dry-run    # Dry run (output saved to dry-run.txt)
make install    # Package and install chart
make upgrade    # Package and upgrade existing release
make rollback   # Rollback release
make uninstall  # Remove release
```

The Helm chart version is read from `deployment/k8s/helm/chart/Chart.yaml` using `yq`.

## CI/CD

GitHub Actions (`build.yml`) triggers on pushes to `main`, version tags (`v*`), and PRs to `main`. It generates SSL certs, builds the Docker image, and pushes to Docker Hub (only on non-PR pushes to the real repo using `DOCKER_USERNAME`/`DOCKER_PASSWORD` secrets).
