#!/usr/bin/env bash

CONTAINER_NAME="ros-humble-dev"

# From https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

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

CONTAINER_IMAGE="ksuevt/ros-humble-dev"
if [[ -f "/proc/driver/nvidia/version" ]]; then
    bash $SCRIPT_DIR/.docker/create-nvidia-image.sh
    CONTAINER_IMAGE="ksuevt/ros-humble-dev-nvidia"
fi

echo -n "Launching image..."
LAUNCH_COMMAND="x11docker -D $WAYLAND_OPTION --hostdisplay --gpu --ipc=host \
    --clipboard -l --sudouser=nopasswd --network=host \
    -m --share=$HOME --share=$SCRIPT_DIR --share=$HOME/.ssh \
    --workdir=$SCRIPT_DIR --name=$CONTAINER_NAME \
    -- -h ros-dev --privileged -- \
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
