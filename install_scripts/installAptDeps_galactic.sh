#!/usr/bin/env bash
set -e

sudo apt install -y python3-vcstool python3-pip python3-rosdep python3-colcon-common-extensions ros-galactic-gazebo-ros-pkgs ros-galactic-xacro git nano
sudo apt install -y ros-galactic-ackermann-msgs
sudo apt install -y ros-galactic-pcl-ros
sudo apt install -y ros-galactic-diagnostic-updater
sudo apt install -y libopencv-dev python3-opencv
sudo apt install -y libpcap-dev
sudo apt install -y libyaml-cpp-dev