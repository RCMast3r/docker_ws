## -*- dockerfile-image-name: "ksuevt/ros-humble-dev-local" -*-
FROM ksuevt/ros-humble-dev
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

ARG NVIDIA_VERSION
COPY .docker/nvidia-drivers/NVIDIA-Linux-x86_64-$NVIDIA_VERSION.run /tmp/NVIDIA-installer.run
RUN apt-get update && \
    apt-get install --no-install-recommends -y kmod xz-utils wget ca-certificates binutils || exit 1 ; \
    Nvidiaoptions='--accept-license --no-runlevel-check --no-questions --no-backup --ui=none --no-kernel-module --no-nouveau-check' ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--install-libglvnd'        && Nvidiaoptions=\"\$Nvidiaoptions --install-libglvnd\" ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--no-nvidia-modprobe'      && Nvidiaoptions=\"\$Nvidiaoptions --no-nvidia-modprobe\" ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--no-kernel-module-source' && Nvidiaoptions=\"\$Nvidiaoptions --no-kernel-module-source\" ; \
    sh /tmp/NVIDIA-installer.run \$Nvidiaoptions || { echo 'ERROR: Installation of NVIDIA driver failed.' >&2 ; exit 1 ; } ; \
    rm /tmp/NVIDIA-installer.run
