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
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

cd $DIR/..

export DOCKER_BUILDKIT=1 # we need the docker buildkit ssh feature
export BUILDKIT_PROGRESS=plain
docker build -t ksuevt/ros-humble-base -f .docker/base.Dockerfile .
docker build --ssh default -t ksuevt/ros-humble-dev -f .docker/dev.Dockerfile . # depends on ksuevt/ros-humble-base

bash .docker/build-local.sh
