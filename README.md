# Dataplane Metrics Forwarder

The dataplane metrics forwarder is a proxy that lives in each hosted control plane (HCP) namespace in management clusters. The main goal of this proxy is to let the hosted clusters push metrics to RHOBS. This proxy exposes a route that is known to the Cluster Monitoring Operator (CMO) running in the dataplane. The CMO pushes the metrics to this route. And the proxy simply forwards this request to the OpenShift Observability Operator (OBO) running on the relevant management cluster. This way the dataplane metrics ultimately end up in RHOBS.

## Deployment process

The proxy is deployed using ACM policy. The ACM policy targets all management clusters and only HCP namespaces in those management clusters. It deploys a PKO package which deploys the resources the proxy needs. The resources it deploys are:
- Issuer
- Certificate
- ConfigMap
- Deployment
- Service
- Route

Additionally, the CMO on the dataplane is configured using another policy that only targets hosted clusters. There are two versios of the policy.
- `metrics-forwarder-config`
- `metrics-forwarder-config-non-uwm`

`metrics-forwarder-config` is applied by default unless a `ManagedCluster` has the label `ext-managed.openshift.io/uwm-disabled` set to `true`

## Testing

### Prerequisites

- kubectl - You will need the Kubernetes CLI, [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl), to deploy and interact with Package Operator and your packages.
- kubectl-package - Package Operator provides a kubectl plugin to validate, package and inspect Package Operator packages. The binaries can be found on the Package Operator [releases](https://github.com/package-operator/package-operator/releases) page.

The [Package Operator](https://github.com/package-operator/package-operator) includes a template test framework that makes it easier to identify template errors without having the need of deploying the Package.

For each template test, Package Operator will auto-generate fixtures into the `.test-fixtures` and the test cases that can be defined in the PackageManifest.

To validate the package run this command in the project's root:
```
$ kubectl package validate ./package
```
If you alter the source templates, either manually update the fixtures to satisfy our expectations - or delete the `.test-fixtures` directory, and the next kubectl package validate call will regenerate the directory, allowing you to review changes in git.
