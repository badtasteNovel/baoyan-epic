ARG KUBECTL_VERSION=v1.32.0
ARG HELM_VERSION=v3.17.3
ARG TASK_VERSION=v3.43.3

# ── installer stage: curl / gnupg 只存在於這裡 ───────────────────────────────
FROM debian:bookworm-slim AS installer
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG TASK_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI + buildx
RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
        https://download.docker.com/linux/debian bookworm stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin \
    && find /usr -name docker-buildx -type f -exec cp {} /usr/local/bin/docker-buildx \; \
    && rm -rf /var/lib/apt/lists/*

# gum — charm 官方 apt repo，直接裝到 /usr/bin/gum
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://repo.charm.sh/apt/gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/charm.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        > /etc/apt/sources.list.d/charm.list \
    && apt-get update && apt-get install -y --no-install-recommends gum \
    && rm -rf /var/lib/apt/lists/*

# kubectl (官方 .sha256 自我驗證)
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
        -o /usr/bin/kubectl \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" \
        | awk '{print $1 "  /usr/bin/kubectl"}' | sha256sum -c - \
    && chmod +x /usr/bin/kubectl

# helm
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin linux-amd64/helm

# task
RUN curl -fsSL "https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin task

# ── final stage: 無 curl，只保留 runtime 必需 ─────────────────────────────────
FROM debian:bookworm-slim

# ca-certificates: kubectl/helm 連接 HTTPS API server 必須
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=installer /usr/bin/docker                        /usr/bin/docker
COPY --from=installer /usr/local/bin/docker-buildx          /usr/lib/docker/cli-plugins/docker-buildx
COPY --from=installer /usr/bin/kubectl                              /usr/bin/kubectl
COPY --from=installer /usr/local/bin/helm                           /usr/local/bin/helm
COPY --from=installer /usr/local/bin/task                           /usr/local/bin/task
COPY --from=installer /usr/bin/gum                                  /usr/bin/gum
