#!/usr/bin/env bash

set -e

sudo apt install -y python3-vcstool python3-pip python3-rosdep python3-colcon-common-extensions ros-humble-gazebo-ros-pkgs ros-humble-xacro git nano
sudo apt install -y ros-humble-ackermann-msgs
sudo apt install -y ros-humble-pcl
sudo apt install -y ros-humble-pcl-ros
sudo apt install -y ros-humble-diagnostic-updater
sudo apt install -y libopencv-dev python3-opencv
sudo apt install -y libpcap-dev
sudo apt install -y libyaml-cpp-dev