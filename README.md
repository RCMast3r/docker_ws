workspace repo for working on Voltron

NOTE: ALWAYS MAKE SURE TO BUILD FOR RELEASE WHEN ACTUALLY USING THIS BOI (@Sahan)

### First-time Setup

In the repo/workspace root, run:


1) 
`source /opt/ros/galactic/setup.bash`

2)
`vcs import < onkart.repos # if being used on the kart`
OR
`vcs import < onkart.repos # if being used on the kart`


3)
`rosdep install -i --from-paths src -y`