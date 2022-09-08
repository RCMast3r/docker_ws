#!/usr/bin/env bash

if [[ $EUID == 0 ]]; then
  echo "Detected root, aborting!"
  echo "You should run this script as your normal user, not as root"
  echo "This requires adding your user to the docker group (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)"
  exit 1
fi

CONTAINER_NAME="ros-humble-dev"

WORK_DIR="${TMPDIR:-/tmp}/$CONTAINER_NAME"

trap "exit 0" SIGINT

if [[ -d "${WORK_DIR}" && -f "${WORK_DIR}/run.pid" ]]; then
  PREV_PID="$(cat ${WORK_DIR}/run.pid)"
  if [[ -d "/proc/$PREV_PID" && ! -z "$(docker ps -a -f name=$CONTAINER_NAME -q)" ]]; then
    kill $PREV_PID
    # HACK wait until x11docker exits gracefully
    while [[ -d "/proc/$PREV_PID" ]]; do
        sleep 0.2
        echo -n "."
    done
    rm ${WORK_DIR}/*
    echo ""
    exit 0
  fi
else
  if [[ ! -z $(docker ps -a -f name=$CONTAINER_NAME -q) ]]; then
    echo "WARNING: x11docker not running but container is; x11docker didn't shutdown cleanly" 1>&2
    docker stop $CONTAINER_NAME
    exit $?
  fi
fi

echo "$CONTAINER_NAME not running!"
