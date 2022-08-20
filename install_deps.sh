#!/usr/bin/env bash

set -e



inst () {
  cd $1
  pwd
  ./install.sh
  cd ${start_dir}
}

start_dir=$(pwd)

readarray -t install_array < <(find . -name "install_scripts")

echo "${#install_array[@]}"

len=${#install_array[@]}

## Use bash for loop 
for (( i=0; i<$len; i++ )); do inst ${install_array[$i]} ; done