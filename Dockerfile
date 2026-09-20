FROM alpine:3.24
RUN apk add --no-cache \
    ca-certificates \
    bash \
    openssh \
    git \
    jq \
    kubectl \
    helm \
    yq \
    rsync \
    gettext \
    curl \
    openssl \
    sshpass
