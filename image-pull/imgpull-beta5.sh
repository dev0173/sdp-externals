#!/usr/bin/env bash
set -euo pipefail

# Point Docker to minikube daemon
eval "$(minikube -p minikube docker-env)"

# Pull all required images for chart version 1.0.0-beta.5
docker pull alpine:3.20
docker pull alpine:3.20.2
docker pull alpine:3.20.3
docker pull alpine:3.21.0
docker pull alpine:3.22
docker pull alpine/curl:8.12.1
docker pull alpine/kubectl:1.34.1
docker pull bitnamilegacy/kubectl:1.30
docker pull busybox
docker pull busybox:1.36
docker pull cr.fluentbit.io/fluent/fluent-bit:3.2.10
docker pull docker.io/bitnamilegacy/keycloak-config-cli:6.4.0-debian-12-r11
docker pull docker.io/bitnamilegacy/keycloak:26.3.3-debian-12-r0
docker pull envoyproxy/envoy:v1.31.0
docker pull ghcr.io/stakater/reloader:v1.4.8
docker pull hashicorp/terraform:1.12.0
docker pull hashicorp/terraform:1.9.5
docker pull python:3.12-alpine
docker pull registry.na.semarchy.net/semarchy-release/alpine-tools:3.22.1
docker pull registry.na.semarchy.net/semarchy-release/docker-billing-service:1.7.3-rc.1
docker pull registry.na.semarchy.net/semarchy-release/docker-dm-passive:1.2.1
docker pull registry.na.semarchy.net/semarchy-release/docker-dm:1.2.1
docker pull registry.na.semarchy.net/semarchy-release/docker-log-explorer-service:1.0.2
docker pull registry.na.semarchy.net/semarchy-release/docker-log-explorer:1.1.2
docker pull registry.na.semarchy.net/semarchy-release/docker-secret-manager:1.1.2
docker pull registry.na.semarchy.net/semarchy-release/docker-site-admin:1.2.1
docker pull registry.na.semarchy.net/semarchy-release/docker-user-profile:1.1.2
docker pull registry.na.semarchy.net/semarchy-release/docker-welcome:1.2.1
docker pull registry.na.semarchy.net/semarchy-release/iam_kc_extensions:2.2.4
docker pull registry.na.semarchy.net/semarchy-release/iam_kc_themes:2.2.4
