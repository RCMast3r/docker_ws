#!/usr/bin/env bash
set -xe
set -o pipefail

if [[ $EUID == 0 ]]; then
  echo "Detected root, aborting!"
  echo "You should run this script as your normal user, not as root"
  echo "This requires adding your user to the docker group (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)"
  exit 1
fi

REGISTRY_BASE_NAME="registry.gitlab.com/ksu_evt/autonomous-software/voltron_ws"
docker pull "$REGISTRY_BASE_NAME/ros-dev:latest"
docker tag "$REGISTRY_BASE_NAME/ros-dev:latest" "voltron_ws_local/ros-dev:latest"
