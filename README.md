# Dockerized Development Environment for KSU EVT's Voltron
**NOTE:** ALWAYS MAKE SURE TO BUILD FOR RELEASE WHEN ACTUALLY USING THIS BOI (@Sahan)


## Pre-Reqs:
You Can:
- Install a Linux OS somewhere on your system (Dual-Booting is fine, even encouraged)
- Use a Virtual Machine and install a Linux OS (Preferably Ubuntu 22.04) on that

> **NOTE:** We hope to have the workspace available on MacOS and Windows soon, but for now, this is the only way to go.


## Stage 1 - Authenticate GitLab:
- Open a bash terminal and you should already be in your HOME directory
- If it does not exist, create a .ssh folder and enter it by running this command
```bash
mkdir .ssh && cd .ssh
```
- Once you are in there, generate an ssh key with this command
```bash
ssh-keygen -b 4096
```
> **NOTE:** Be sure you name it with the default key ID for your OS ('id_rsa' for Ubuntu 22.04)
- Run this command to output the contents of the public key of ssh keypair we just created
```bash
cat NAME_OF_YOUR_KEY_FILE.pub
```
- Copy that output, then go to gitlab.com > Preferences > SSH keys
- Paste the key there, create a name for it, and save it


# Stage 2 - Installing Docker

*If using an Nvidia GPU:*

[Install nvidia-docker2](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit)

>**NOTE - if using Pop-OS:** see this issue comment: https://github.com/NVIDIA/nvidia-docker/issues/1388#issuecomment-1182634769 as Pop-OS doesnt handle the packaging of nvidia-docker2 correctly and you will have to add a preference manually

*Otherwise:*

[Installing Docker Engine](https://docs.docker.com/engine/install/)

>**NOTE:** DO NOT INSTALL DOCKER DESKTOP. INSTALL THE SERVER VERSION


# Stage 3 - Cloning the Workspace:
Open your bash terminal and enter this command:
```bash
git clone git@gitlab.com:KSU_EVT/autonomous-software/voltron_ws.git
```

Type this command to enter the directory in which we just cloned the workspace:
```bash
cd voltron_ws
```

# Stage 4 - Entering the Container:

- Normally, you have to run containers as root
- There are a lot of semantics about this workspace that mandate we cannot run as root
- Therefore, you have to add yourself to the docker group
- Run this command:
```bash
echo "$(whoami)" | xargs sudo usermod -aG docker
```
- Log out then log back in so the group changes take effect
>**NOTE:** If you don't feel like logging out, you can just run `newgrp docker`, but you'll have to do that every time you open a new terminal window.

- When in the workspace directory, type this command to build and run the container:
```bash
./update.sh
```

- Now that the workspace is built, you can use this command to enter it:
```bash
./enter.sh
```

# Stage 5 - Setting up YOUR Work Environment

- On first startup, run the following within the docker container bash prompt:
```bash
./scripts/create-bashrc.sh
```
<details>
<summary>If you get "~/.bashrc already exists!":</summary>
<br>

We must generate your new `.bashrc` with the script, then append the contents of your old `.bashrc` to the new file:
```bash
mv ~/.bashrc ~/.bashrc.old
./create-bashrc.sh
cat ~/.bashrc.old >> ~/.bashrc
```
</details>

- This will color your terminal and do some other housekeeping for the bash terminal inside the container, but the changes won't take effect until you exit and re-enter the container. If you're impatient, just run this command:
```bash
source ~/.bashrc
```

- To clone all of the repositories we're currently working in, run these commands:
```bash
eval `ssh-agent`
ssh-add
vcs import --input dev-repos.yaml --recursive
```

> **NOTE:** YOU MIGHT HAVE TO RUN THIS COMMAND TWICE IF ON KSU WIFI; They limit SSH tunnels for some reason and VCS clones using SSH. This is the error you will see if that's the case:
```bash
kex_exchange_identification: read: Connection reset by peer
Connection reset by 172.65.251.78 port 22
fatal: Could not read from remote repository.
```

- Afterward, all of our modules will be inside the src/ folder


# Stage 6 - Shutting Down the Container

- To stop the docker container from inside its CLI, press the sequence `ctrl+P ctrl+Q`

- Alternatively, you can exit the container by simply running `exit`

- The container is still running in the background, so you can jump back in with `./enter.sh`

- If you're done working, you can kill the container process with this command (From the host's terminal, not inside the container):
```bash
./stop.sh
```
---

#### dependency **NOTE:**

All of the dependencies for the environment are captured by either a `package.xml` or an install script within the `scripts/` folder.

In addition, the docker container is not persistent and anything installed by the user will not stay installed once the container is stopped. Anything you do not want to capture in either a packages `package.xml` or the `install-non-ros-deps.sh` script can be held in the `install-local.sh` script in the `scripts/` folder.

> for example, say you want to use `nano` in the container, in the `install-local.sh` add the line `sudo apt-get install -y nano`

---

#### VScode usability tips:
**NOTE:** for vscode users: by default, vscode's source monitoring does not handle the repos as sub-directories very well. To get around this and to view the status of all of the repos at once in the `src/` dir, shrimply use `vcs status src/` within the workspace directory.

in addition, if you would like to un-grayify the folders that appear in the `.gitignore`, put this in your workbench color customization:

```
"workbench.colorCustomizations": {
    "gitDecoration.ignoredResourceForeground": "#cccccc"
}
```

IMPORTANT for VSCODE users: to include contents in the ignored directories in vscode, uncheck the option in:

`Settings->Features->Explorer->"Exclude Git Ignore"`

---
