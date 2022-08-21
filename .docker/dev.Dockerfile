## -*- dockerfile-image-name: "ksuevt/ros-humble-dev" -*-
FROM ksuevt/ros-humble-base
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# x11docker dependencies documented in https://github.com/mviereck/x11docker/wiki/dependencies
# also ros desktop, ros utilties, and other utilities
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update && \
  apt-get install -y xinit xauth xclip x11-xserver-utils x11-utils weston xwayland xdotool locales dbus \
                     mesa-utils mesa-utils-extra vainfo \
                     libxv1 va-driver-all vdpau-driver-all \
                     ros-humble-desktop python3-vcstool python3-rosdep python3-colcon-common-extensions \
                     sudo git iputils-ping neovim ssh

# Workspace dependencies
COPY . /tmp/voltron_ws
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh \
  cd /tmp/voltron_ws && mkdir src && vcs import src < dev-repos.yaml

RUN /tmp/voltron_ws/scripts/install-non-ros-deps.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  rosdep init && rosdep update --rosdistro=humble
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  cd /tmp/voltron_ws && rosdep install --rosdistro humble --from-paths src --ignore-src -r -y
