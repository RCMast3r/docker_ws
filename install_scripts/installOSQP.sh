#!/usr/bin/env bash

set -e

if [ -d "~/osqp/" ] 
then
    echo "osqp folder already exists, skipping install" 
else
    sudo apt-get install -Y libeigen3-dev

    curl -L https://github.com/osqp/osqp/releases/download/v0.6.2/complete_sources.tar.gz | tar -xz -C ~/
    cd ~/osqp
    mkdir build
    cd build
    pwd
    cmake -G "Unix Makefiles" ..
    cmake --build .    
    cmake --build . --target install

    cd ~/
    git clone https://github.com/robotology/osqp-eigen.git
    cd osqp-eigen
    mkdir build
    cd build
    cmake ..
    make
    make install

fi
