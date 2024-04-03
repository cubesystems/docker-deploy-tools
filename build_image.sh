#!/usr/bin/env sh

TAG=cubesystems/deploy-utils:1.7

docker buildx build . \
  -t $TAG \
  --platform linux/amd64 \
  --push
