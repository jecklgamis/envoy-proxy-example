#!/usr/bin/env bash
set -e
usr/local/bin/envoy -l error -c /etc/envoy/envoy.yaml
