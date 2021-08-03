FROM alpine:3.12
ENV K8_VERSION=v1.19.2
ADD https://storage.googleapis.com/kubernetes-release/release/$K8_VERSION/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl && kubectl version --client && \
  apk add --no-cache ca-certificates bash openssh ansible git rsync sshpass && \
  ansible-galaxy install git+https://github.com/cubesystems/ansible-laravel5-deploy.git,405a8cb7eeb250626c4727c50f6339f758204414
