#!/usr/bin/env bash
set -xe
set -o pipefail

# FIXME ssh gets rate limited by the school firewall, so vcs import w/ ssh repos in the dev imgae doesn't work
# This means you can't build the ros-dev image on school wifi
# Getting this resolved will require talking to UITS
# We can work around this by only cloning a few repos at a time with a delay in between, but that would
#   require mangling our Dockerfile, which I would rather not do
# So, for now, we can only build ros-dev off the school network (like in GitLab CI!)

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
IMAGE_NAME_BASE="registry.gitlab.com/ksu_evt/autonomous-software/voltron_ws"
IMAGE_BASE="$IMAGE_NAME_BASE/ros-base"
IMAGE_DEV="$IMAGE_NAME_BASE/ros-dev"
docker build --ssh default -t $IMAGE_BASE:latest -t $IMAGE_BASE:humble -f .docker/base.Dockerfile .
docker build --ssh default -t $IMAGE_DEV:latest -t $IMAGE_DEV:humble -f .docker/dev.Dockerfile .
