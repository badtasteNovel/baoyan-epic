ARG KUBECTL_VERSION=v1.36.1

FROM alpine:3.21 AS installer
ARG KUBECTL_VERSION
RUN apk add --no-cache curl \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
       -o /usr/local/bin/kubectl \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" \
       | awk '{print $1 "  /usr/local/bin/kubectl"}' | sha256sum -c - \
    && chmod +x /usr/local/bin/kubectl

FROM alpine:3.21
COPY --from=installer /usr/local/bin/kubectl /usr/local/bin/kubectl
