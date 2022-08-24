#!/usr/bin/env bash
set -xe
set -o pipefail

# From https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
WS_DIR=$(readlink -f "$SCRIPT_DIR/..")

cd $WS_DIR

export DOCKER_BUILDKIT=1 # we need the docker buildkit ssh feature
DEV_BASE_IMAGE="ksuevt/ros-humble-dev"
if [[ -f /proc/driver/nvidia/version ]]; then
  bash $WS_DIR/.docker/build-nvidia.sh
  DEV_BASE_IMAGE="ksuevt/ros-humble-dev-nvidia"
fi

docker build --build-arg BASE_IMAGE=$DEV_BASE_IMAGE \
    -t ksuevt/ros-humble-local -f .docker/dev-local.Dockerfile .
