# 1. Use a specific version of the Alpine base image
FROM alpine:3.18

# --- Build Arguments ---
# Define versions for Helm and argocd-vault-plugin
ARG HELM_VERSION=v3.17.0
ENV AVP_VERSION=1.18.1
ENV BIN=argocd-vault-plugin

# --- Installation & Security Settings ---
# Work as root user
USER root

# Install packages, download binaries, create user, and clean up in a single layer.
RUN apk add --no-cache bash curl tar git && \
    \
    # Install Helm
    curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -zx -C /usr/local/bin linux-amd64/helm --strip-components=1 && \
    \
    # Install argocd-vault-plugin
    curl -L -o /usr/local/bin/${BIN} "https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64" && \
    \
    # Grant execute permissions
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/${BIN} && \
    \
    # Create and switch to a dedicated non-root user
    addgroup -S appgroup && adduser -S -G appgroup -s /bin/bash appuser

# --- User Settings ---
USER appuser

# --- Default Command ---
# Define the default behavior when the container starts (e.g., start bash)
CMD ["/bin/bash"]
