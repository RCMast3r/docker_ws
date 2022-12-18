#!/usr/bin/env bash

if [[ $EUID == 0 ]]; then
  echo "Detected root, aborting!"
  echo "You should run this script as your normal user, not as root"
  echo "This requires adding your user to the docker group (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)"
  exit 1
fi

CONTAINER_NAME="ros-humble-dev"

# From https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
WS_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

WORK_DIR="${TMPDIR:-/tmp}/$CONTAINER_NAME"
if [[ ! -d "${WORK_DIR}" ]]; then
    mkdir $WORK_DIR
fi

LAUNCH_SHELL_CMD="docker exec -it -e TERM=${TERM} ${CONTAINER_NAME} bash"

if [[ -f "${WORK_DIR}/run.pid" ]]; then
    PREV_PID="$(cat ${WORK_DIR}/run.pid)"
    if [[ -d "/proc/$PREV_PID" && ! -z "$(docker ps -a -f name=$CONTAINER_NAME -q)" ]]; then
        $LAUNCH_SHELL_CMD
        exit 0
    fi

    if [[ ! -z "$(docker ps -a -f name=$CONTAINER_NAME -q)" ]]; then
        echo "Warning: environment didn't shutdown cleanly"
        docker stop "$(docker ps -a -f name=$CONTAINER_NAME -q)" >/dev/null 2>&1
    fi
fi

# x11docker isn't already running

rm ${WORK_DIR}/* 2>/dev/null

WAYLAND_OPTION=""
if [[ ! -z "${WAYLAND_DISPLAY}" ]]; then
    # If running wayland, add --hostwayland
    WAYLAND_OPTION="--hostwayland"
fi

if [[ "$(docker images -q voltron_ws_local/ros-dev:latest 2> /dev/null)" == "" ]]; then
  # The image doesn't exist locally
  echo "Can't find image voltron_ws_local/ros-dev:latest locally."
  echo "Make sure to run update.sh at least once before running enter.sh."
  exit 1
fi
bash $WS_DIR/.docker/build-local.sh

CONTAINER_IMAGE="voltron_ws_local/ros-dev-local"
echo -n "Launching image..."
LAUNCH_COMMAND="bash $WS_DIR/scripts/x11docker/x11docker -D $WAYLAND_OPTION --hostdisplay --gpu \
    --clipboard -l --sudouser=nopasswd --network=host \
    -m --share=$HOME --share=$WS_DIR --share=$HOME/.ssh \
    --workdir=$WS_DIR --name=$CONTAINER_NAME \
    -- -h ros-dev --privileged -v /dev:/dev --add-host=ros-dev:127.0.1.1 --ipc=host -- \
    $CONTAINER_IMAGE"
nohup $LAUNCH_COMMAND > $WORK_DIR/run.output 2>&1 &
LAUNCH_PID="$!"

echo $LAUNCH_PID > $WORK_DIR/run.pid

# HACK wait until x11docker hasn't outputted anything for a few seconds; probably done by then
while [ $(( $(date +%s) - $(stat -c %Y $WORK_DIR/run.output) )) -lt 3 ]; do
    sleep 0.2
    echo -n "."
done
echo ""

$LAUNCH_SHELL_CMD
exit 0
