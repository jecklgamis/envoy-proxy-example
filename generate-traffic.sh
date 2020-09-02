#!/usr/bin/env bash
while (true); do
  curl -k https://localhost:8443 && echo "" && sleep 1
done
