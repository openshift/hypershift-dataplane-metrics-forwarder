SHELL := /usr/bin/env bash

# Verbosity
AT_ = @
AT = $(AT_$(V))
# /Verbosity

GIT_HASH := $(shell git rev-parse --short=7 HEAD)
IMAGETAG ?= ${GIT_HASH}

BASE_IMG ?= hypershift-dataplane-metrics-forwarder-package
IMG_REGISTRY ?= quay.io
IMG_ORG ?= app-sre
IMG ?= $(IMG_REGISTRY)/$(IMG_ORG)/${BASE_IMG}

CONTAINER_ENGINE ?= $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)

.PHONY: build-image
build-image:
	 	$(CONTAINER_ENGINE) build -t $(IMG):$(IMAGETAG) -f $(join $(CURDIR),/build/Dockerfile) . && \
		$(CONTAINER_ENGINE) tag $(IMG):$(IMAGETAG) $(IMG):latest

.PHONY: build-push
build-push:
		build/build_push.sh $(IMG):$(IMAGETAG)

.PHONY: skopeo-push
skopeo-push:
	@if [[ -z $$QUAY_USER || -z $$QUAY_TOKEN ]]; then \
		echo "You must set QUAY_USER and QUAY_TOKEN environment variables" ;\
		echo "ex: make QUAY_USER=value QUAY_TOKEN=value $@" ;\
		exit 1 ;\
	fi
	# QUAY_USER and QUAY_TOKEN are supplied as env vars
	skopeo copy --dest-creds "${QUAY_USER}:${QUAY_TOKEN}" \
		"docker-daemon:${IMG}:${IMAGETAG}" \
		"docker://${IMG}:latest"
	skopeo copy --dest-creds "${QUAY_USER}:${QUAY_TOKEN}" \
		"docker-daemon:${IMG}:${IMAGETAG}" \
		"docker://${IMG}:${IMAGETAG}"

.PHONY: push-image
push-image: build/Dockerfile
	$(CONTAINER_ENGINE) push $(IMG):$(IMAGETAG)
	$(CONTAINER_ENGINE) push $(IMG):latest
