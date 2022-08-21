#!/usr/bin/env bash

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
fi

echo "$CONTAINER_NAME not running!"
