ARG TOOLBOX_IMAGE=my-ops-toolbox:latest

FROM ${TOOLBOX_IMAGE} AS tools

FROM my-php-release:debian-bookworm

USER root

ENV HELM_DATA_HOME=/opt/helm-data

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=tools /usr/bin/gum                                  /usr/bin/gum
COPY --from=tools /usr/bin/kubectl                              /usr/bin/kubectl
COPY --from=tools /usr/local/bin/helm                           /usr/local/bin/helm
COPY --from=tools /usr/local/bin/task                           /usr/local/bin/task

WORKDIR /workspace
ENTRYPOINT []
CMD ["bash"]
