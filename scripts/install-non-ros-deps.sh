#!/usr/bin/env bash
set -xe
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

# From https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
WS_DIR=$(readlink -f "$SCRIPT_DIR/..")

install_osqp() {
    VERSION="0.6.2"

    rm -rf /tmp/osqp

    curl -L https://github.com/osqp/osqp/releases/download/v$VERSION/complete_sources.tar.gz | tar -xz -C /tmp
    cd /tmp/osqp
    mkdir build
    cd build
    pwd
    cmake -G "Unix Makefiles" ..
    cmake --build . -j$(nproc)
    sudo cmake --build . --target install
}

install_osqp_eigen() {
    VERSION="0.7.0"
    rm -rf /tmp/osqp-eigen-$VERSION
    sudo apt-get install -y libeigen3-dev

    mkdir /tmp/osqp-eigen
    curl -L https://github.com/robotology/osqp-eigen/archive/refs/tags/v$VERSION.tar.gz | tar -xz -C /tmp/
    cd /tmp/osqp-eigen-$VERSION
    mkdir build
    cd build
    cmake ..
    make -j$(nproc)
    sudo make install
}

install_gtsam() {
  VERSION="4.1.1"
  
  rm -rf /tmp/gtsam
  mkdir /tmp/gtsam
  cd /tmp/gtsam
  wget https://raw.githubusercontent.com/RCMast3r/evt-debs/main/ros-humble-gtsam_4.1.0-0jammy_amd64.deb
  sudo dpkg -i ros-humble-gtsam_4.1.0-0jammy_amd64.deb
  
}

install_foxglove() {
  VERSION="1.42.1"
  rm -rf /tmp/foxglove-$VERSION
  mkdir /tmp/foxglove-$VERSION
  cd /tmp/foxglove-$VERSION
  wget https://github.com/foxglove/studio/releases/download/v$VERSION/foxglove-studio-$VERSION-linux-amd64.deb
  sudo dpkg -i foxglove-studio-$VERSION-linux-amd64.deb
}

sudo apt-get update

cd $WS_DIR
install_osqp

cd $WS_DIR
install_osqp_eigen

cd $WS_DIR
install_gtsam

cd $WS_DIR
install_foxglove

cd $WS_DIR
