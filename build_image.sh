#!/usr/bin/env sh

TAG=cubesystems/deploy-utils:1.6

docker buildx build . \
  -t $TAG \
  --platform linux/amd64 \
  --push
