ARG BASE_IMAGE=registry.gitlab.com/ksu_evt/autonomous-software/voltron_ws/ros-dev
FROM $BASE_IMAGE
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir /tmp/voltron_ws_local/
COPY ./src /tmp/voltron_ws_local/src
COPY ./scripts /tmp/voltron_ws_local/scripts
# rosdep init and rosdep update must have been run in base image
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  cd /tmp/voltron_ws_local && sudo apt-get update -y && rosdep install --rosdistro humble --from-paths src --ignore-src -r -y
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  test -f /tmp/voltron_ws_local/scripts/install-local.sh && bash /tmp/voltron_ws_local/scripts/install-local.sh || echo "scripts/install-local.sh doesn't exist, skipping"
