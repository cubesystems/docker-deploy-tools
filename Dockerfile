FROM alpine:3.19
ENV K8_VERSION=v1.29.2
ADD https://storage.googleapis.com/kubernetes-release/release/$K8_VERSION/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl && \
  kubectl version --client && \
  apk add --no-cache \
    ca-certificates \
    bash \
    openssh \
    git \
    jq \
    helm \
    yq \
    rsync \
    gettext \
    curl \
    sshpass

COPY read-vault-data.sh /usr/local/bin/
