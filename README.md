workspace repo for working on Voltron

NOTE: ALWAYS MAKE SURE TO BUILD FOR RELEASE WHEN ACTUALLY USING THIS BOI (@Sahan)

# EVT dockerized dev environment (nvidia)

pre-reqs:

must be within a linux environment.

### step 0:

1 clone with:
```
$ git clone --recurse-submodules git@gitlab.com:KSU_EVT/autonomous-software/voltron_ws.git
```

ONLY if using an nvidia gpu: (otherwise skip)

2 [install nvidia-docker2](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit)

-----
NOTE if using Pop-OS see this issue comment: https://github.com/NVIDIA/nvidia-docker/issues/1388#issuecomment-1182634769

as Pop-OS doesnt handle the packaging of nvidia-docker2 correctly and you will have to add a preference manually
-----

3 if not using a pre-built docker image:
```
$ ./.docker/build-all.sh 
```

#### steps 1 through 3:
1. to enter the built docker image: 
```
$ ./enter.sh
```

2. on first startup, run the following within the docker container bash prompt:
```
$ ./create-bashrc.sh
```

3. to stop the built docker image:
```
$ ./stop.sh
```

dependency note: 

All of the dependencies for the environment are captured by either a `package.xml` or an install script within the `scripts/` folder. 

In addition, the docker container is not persistent and anything installed by the user will not stay installed once the container is stopped. Anything you do not want to capture in either a packages `package.xml` or the `install-non-ros-deps.sh` script can be held in the `install-local.sh` script in the `scripts/` folder.

> for example, say you want to use `nano` in the container, in the `install-local.sh` add the line `sudo apt-get install -y nano`