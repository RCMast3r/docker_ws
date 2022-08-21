#!/usr/bin/env bash

# Script to build image ksuevt/ros-humble-dev-nvidia
# containing NVIDIA driver version matching the one on host.

Imagename="ksuevt/ros-humble-dev-nvidia"

if [[ -z "$(which curl)" ]]; then
  echo "curl command not found!"
  echo "You must install curl to use this script. Aborting"
  exit 1
fi

# From https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
Scriptdir=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

Savedir="$Scriptdir/nvidia-drivers"
[[ ! -d "$Savedir" ]] && mkdir "$Savedir"

Nvidiaversion="$(head -n1 </proc/driver/nvidia/version | awk '{ print $8 }')"
[ "$Nvidiaversion" ] || {
  echo "Error: No NVIDIA driver detected on host" >&2
  exit 1
}
echo "Detected NVIDIA driver version: $Nvidiaversion"

# Cache downloaded driver file in case of rebuilds (base image changes)
Driverfile="NVIDIA-Linux-x86_64-$Nvidiaversion.run"
Savefile="$Savedir/$Driverfile"

if [[ ! -f "$Savefile" ]]; then
  echo "Downloading driver..."
  Driverurl="https://http.download.nvidia.com/XFree86/Linux-x86_64/$Nvidiaversion/NVIDIA-Linux-x86_64-$Nvidiaversion.run"
  echo "Driver download URL: $Driverurl"
  curl $Driverurl --output $Savefile
  if [[ $? != 0 ]]; then
    echo "Error: Failed to download NVIDIA driver" >&2
    exit 1
  fi
else
  echo "Found driver at $Savefile"
fi

Tmpdir="/tmp/ros-humble-dev-nvidia-build"
mkdir -p "$Tmpdir"

echo "# Dockerfile to create NVIDIA driver dev image $Imagename
FROM ksuevt/ros-humble-dev:latest
COPY nvidia-drivers/NVIDIA-Linux-x86_64-$Nvidiaversion.run /tmp/NVIDIA-installer.run
RUN apt-get update && \
    apt-get install --no-install-recommends -y kmod xz-utils wget ca-certificates binutils || exit 1 ; \
    Nvidiaoptions='--accept-license --no-runlevel-check --no-questions --no-backup --ui=none --no-kernel-module --no-nouveau-check' ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--install-libglvnd'        && Nvidiaoptions=\"\$Nvidiaoptions --install-libglvnd\" ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--no-nvidia-modprobe'      && Nvidiaoptions=\"\$Nvidiaoptions --no-nvidia-modprobe\" ; \
    sh /tmp/NVIDIA-installer.run -A | grep -q -- '--no-kernel-module-source' && Nvidiaoptions=\"\$Nvidiaoptions --no-kernel-module-source\" ; \
    sh /tmp/NVIDIA-installer.run \$Nvidiaoptions || { echo 'ERROR: Installation of NVIDIA driver failed.' >&2 ; exit 1 ; } ; \
    rm /tmp/NVIDIA-installer.run ; \
" >"$Tmpdir/Dockerfile"

echo "Creating docker image $Imagename"
# we can't copy files from outside the docker build context
Buildcmd="docker build -t $Imagename -f $Tmpdir/Dockerfile $Scriptdir"
echo "$Buildcmd"
$Buildcmd || {
  echo "Error: Failed to build image $Imagename.
  Check possible build error messages above.
  Make sure that you have permission to start docker.
  Make sure docker daemon is running." >&2
  rm -R "$Tmpdir"
  exit 1
}

echo "Successfully created $Imagename"
rm -R "$Tmpdir"
exit 0
