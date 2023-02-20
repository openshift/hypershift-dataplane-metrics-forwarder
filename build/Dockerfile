FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

ENV USER_UID=1001 \
    USER_NAME=dpmf-user

ADD package/*.yaml* /package/

USER ${USER_UID}

LABEL io.hypershift.managed.name="hypershift-dataplane-metrics-forwarder" \
    io.hypershift.managed.description="Metrics forwarder proxy to forward dataplane metrics to RHOBS"