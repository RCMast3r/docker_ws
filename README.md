workspace repo for working on Voltron

NOTE: ALWAYS MAKE SURE TO BUILD FOR RELEASE WHEN ACTUALLY USING THIS BOI (@Sahan)

### First-time Setup

In the repo/workspace root, run:


1) `source /opt/ros/galactic/setup.bash`

2) `vcs import < onkart.repos # if being used on the kart` OR `vcs import < develop.repos # if being used on personal machine`


3) `rosdep install -i --from-paths src -y`

TODO add step to run the install script

NOTE: for vscode users: by default, vscode's source monitoring does not handle the repos as sub-directories very well. To get around this and to view the status of all of the repos at once in the `src/` dir, shrimply use `vcs status src/` within the workspace directory.

in addition, if you would like to un-grayify the folders that appear in the `.gitignore`, put this in your workbench color customization:
```
"workbench.colorCustomizations": {
    "gitDecoration.ignoredResourceForeground": "#cccccc"
}
```

IMPORTANT for VSCODE users: to include contents in the ignored directories in vscode, uncheck the option in 

`Settings->Features->Explorer->"Exclude Git Ignore"`