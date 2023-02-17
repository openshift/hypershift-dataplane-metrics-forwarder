# Metrics Forwarder

The Metrics Forwarder is a Proxy that lives in each Hosted Control Plane (HCP) Namespace in Management Clusters. The main goal of this Proxy is to let the relevant Hosted Cluster's Data Plane push metrics to RHOBS. This proxy exposes a route that is known to the Cluster Monitoring Operator (CMO) running in the Data Plane. The CMO pushes the metrics to this route. And the proxy simply forwards this request to the Openshift Observability Operator (OBO) running on the relevant Management Cluster. This way the metrics ultimately end up in RHOBS.

## Deployment process

The proxy is deployed using ACM policy. The ACM Policy targets all Management Clusters and only HCP Namespaces in those Management Clusters. It deploys a PKO Package which deploys the resources the proxy needs. The resources it deploys are:
- ServiceAccount
- Role
- RoleBinding
- CronJob
- Issuer
- Certificate
- ConfigMap
- Deployment
- Service
- Route

Additionally, the CMO on the Data Plane is configured using another Policy that only targets Hosted Clusters.

## Proxy initialization process

The Proxy needs to be initialized to work properly. This phase might not be needed later if the root-ca contains certificates that are compatible with Cert Manager.
Initially, PKO Package deploys 4 resources:
- ServiceAccount named metrics-forwarder-sa
- Role named metrics-forwarder-secret-ensurer
- RoleBinding named metrics-forwarder-secret-rolebinding
- CronJob named metrics-forwarder-secret-ensurer

This CronJob mianly recreates the root-ca (metrics-forwarder-secret) in the HCP with names that are compatible with Cert Manager. 

## Contact
___
- Red Hat Internal Slack #sd-sre-team-thor
