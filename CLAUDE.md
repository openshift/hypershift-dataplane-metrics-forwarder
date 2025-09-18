# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Package Operator-based Kubernetes package that deploys a metrics forwarding proxy for OpenShift HyperShift environments. The proxy forwards metrics from HyperShift dataplane clusters to Red Hat Observability Service (RHOBS) via nginx.

## Common Development Commands

### Package Validation
```bash
# Validate the Package Operator package (primary testing method)
kubectl package validate ./package
```

### Container Image Build
```bash
# Build container image locally
make build-image

# Build and push (with existence check to avoid rebuilds)
make build-push

# Push using skopeo with authentication
make skopeo-push

# Direct push to registry
make push-image
```

### Prerequisites
- `kubectl` CLI
- `kubectl-package` plugin from [Package Operator releases](https://github.com/package-operator/package-operator/releases)
- Podman or Docker (auto-detected by Makefile)

## Architecture Overview

### Package Operator Framework
This project uses Package Operator instead of traditional Go-based Kubernetes operators. The main components are:

- **Package Manifest**: `package/manifest.yaml` - Defines deployment phases and test configuration
- **Resource Templates**: `package/resources.yaml.gotmpl` - Go templates for Kubernetes resources
- **Container Build**: `build/Dockerfile` - Simple UBI8-based container that packages YAML files

### Deployment Phases
The Package Operator deploys resources in specific phases:
1. `certman-issuer` - Certificate Manager Issuer
2. `certman-cert` - TLS Certificate
3. `config` - nginx ConfigMap
4. `deploy` - Deployment + NetworkPolicy
5. `expose` - Service + Route

### Key Resources Deployed
- **nginx proxy**: Forwards metrics from dataplane CMO to OpenShift Observability Operator
- **TLS certificates**: For secure communication
- **Network policies**: Restrict egress to DNS and observability operator
- **OpenShift Route**: External access endpoint

## Template Variables and Context

Templates use HyperShift naming conventions:
- `{{.package.metadata.namespace}}` - HCP namespace (format: `clusters-{cluster-id}`)
- `{{ (splitn "-" 4 $x)._3 }}` - Extracts cluster ID from namespace name
- Templates expect to run in HyperShift hosted control plane namespaces

## Testing Framework

### Package Operator Testing
- **Primary test method**: `kubectl package validate ./package`
- **Test fixtures**: Auto-generated in `.test-fixtures/` directory
- **Template tests**: Defined in PackageManifest with default HyperShift context
- **Fixture regeneration**: Delete `.test-fixtures/` and re-run validate to regenerate

### Test Context
Templates are tested with realistic HyperShift HCP namespace context to ensure proper variable substitution.

## Deployment Context

### Target Environment
- **Management clusters**: OpenShift clusters hosting HyperShift control planes
- **ACM policies**: Deploy this package to all HCP namespaces
- **Metrics flow**: Dataplane → nginx proxy → OpenShift Observability Operator → RHOBS

### Cluster Configuration
- **Pod scheduling**: Uses anti-affinity for zone distribution and node affinity for HyperShift control plane nodes
- **Tolerations**: Configured for HyperShift-specific taints
- **Networking**: Targets `hypershift-monitoring-stack-prometheus.openshift-observability-operator.svc.cluster.local:9090`

## Code Review Process

### OWNERS Configuration
- **Reviewers**: wanghaoran1988, feichashao, MitaliBhalla, Tafhim, bmeng
- **Approvers**: wanghaoran1988, feichashao, bmeng, Tafhim, srep-team-leads, sre-architects

## Container Registry

- **Registry**: `quay.io/app-sre/hypershift-dataplane-metrics-forwarder-package`
- **Tagging**: Git commit hash (7 chars) + `latest`
- **Base image**: `registry.access.redhat.com/ubi8/ubi-minimal:latest`
- **Runtime user**: Non-root (UID 1001)

## Related Policies

This package works in conjunction with CMO configuration policies:
- `metrics-forwarder-config` (default)
- `metrics-forwarder-config-non-uwm` (when UWM is disabled via `ext-managed.openshift.io/uwm-disabled=true`)