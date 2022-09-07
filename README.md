workspace repo for working on Voltron

NOTE: ALWAYS MAKE SURE TO BUILD FOR RELEASE WHEN ACTUALLY USING THIS BOI (@Sahan)

# EVT dockerized dev environment (nvidia)

pre-reqs:

must be within a linux environment.

### step 0:

1. clone with:
```bash
git clone --recurse-submodules git@gitlab.com:KSU_EVT/autonomous-software/voltron_ws.git
```

**_ONLY_** if using an Nvidia GPU: (otherwise skip)

2. [install nvidia-docker2](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit)

---
**NOTE: if using Pop-OS** see this issue comment: https://github.com/NVIDIA/nvidia-docker/issues/1388#issuecomment-1182634769

as Pop-OS doesnt handle the packaging of nvidia-docker2 correctly and you will have to add a preference manually

---


3. if not using a pre-built docker image:

* if you **_do not_** have an Nvidia GPU:
```bash
./.docker/build-local.sh
```


* if you **_do_** have an Nvidia GPU:
```bash
./.docker/build-nvidia.sh
```


#### steps 1 through 3:
1. to enter the built docker image:
```bash
./enter.sh
```


2. on first startup, run the following within the docker container bash prompt:
```bash
./scripts/create-bashrc.sh
```

* If you get the warning `~/.bashrc already exists!`, perform the following:
```bash
mv ~/.bashrc ~/.bashrc.old
./scripts/create-bashrc.sh
cat ~/.bashrc.old >> ~/.bashrc
```


3. to stop the docker container from inside its CLI, press the sequence `ctrl+P ctrl+Q`

* Alternatively, (from the host's terminal) run:
```bash
./stop.sh
```

#### dependency note:

All of the dependencies for the environment are captured by either a `package.xml` or an install script within the `scripts/` folder.

In addition, the docker container is not persistent and anything installed by the user will not stay installed once the container is stopped. Anything you do not want to capture in either a packages `package.xml` or the `install-non-ros-deps.sh` script can be held in the `install-local.sh` script in the `scripts/` folder.

> for example, say you want to use `nano` in the container, in the `install-local.sh` add the line `sudo apt-get install -y nano`

---

#### VScode usability tips:
NOTE: for vscode users: by default, vscode's source monitoring does not handle the repos as sub-directories very well. To get around this and to view the status of all of the repos at once in the `src/` dir, shrimply use `vcs status src/` within the workspace directory.

in addition, if you would like to un-grayify the folders that appear in the `.gitignore`, put this in your workbench color customization:

```
"workbench.colorCustomizations": {
    "gitDecoration.ignoredResourceForeground": "#cccccc"
}
```

IMPORTANT for VSCODE users: to include contents in the ignored directories in vscode, uncheck the option in:

`Settings->Features->Explorer->"Exclude Git Ignore"`

---