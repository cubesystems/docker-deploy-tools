FROM alpine:3.10
ENV K8_VERSION=v1.16.2

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/
ADD https://storage.googleapis.com/kubernetes-release/release/$K8_VERSION/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl && kubectl version --client
RUN apk add --no-cache ca-certificates bash openssh ansible git rsync
