# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Envoy Proxy reference implementation demonstrating a containerized reverse proxy setup. It runs Envoy as a front proxy with a simple Node.js echo server as the upstream application, managed by supervisor.

## Build and Run Commands

```bash
# Quick start from Docker Hub
docker run -p 8080:8080 -p 9901:9901 -p 8443:8443 jecklgamis/envoy-proxy-example:main

# Build locally
./generate-ssl-certs.sh   # Generate self-signed SSL certs (required before build)
make image                # Build Docker image

# Run locally
make run                  # Run container with port mappings
make run-shell            # Run with interactive shell

# Kubernetes deployment
cd deployment/k8s/helm
make package              # Package Helm chart
make install              # Install to cluster
```

## Architecture

```
Client → Envoy Proxy (8080/HTTP, 8443/HTTPS) → Node.js App (5050 internal)
              ↓
         Admin API (9901)
```

**Process Management:** The container uses `supervisor` to run two processes:
1. **Envoy Proxy** - Listens on ports 8080 (HTTP) and 8443 (HTTPS), routes to upstream
2. **Node.js App** (`app.js`) - Echo server on port 5050 that returns request metadata as JSON

**Key Files:**
- `config/envoy.yaml` - Envoy static configuration (listeners, clusters, routes)
- `supervisor.ini` - Process supervisor config for container
- `app.js` - Simple upstream HTTP echo server
- `Dockerfile` - Based on `envoyproxy/envoy:v1.35-latest`

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

The Envoy config in `config/envoy.yaml` defines:
- **Admin interface** on port 9901
- **HTTP listener** on port 8080 with 15s request timeout
- **HTTPS listener** on port 8443 with TLS termination
- **Cluster** `default_app` pointing to 127.0.0.1:5050 (the Node.js app)

All routes use prefix matching on `/` and forward to the upstream cluster.
