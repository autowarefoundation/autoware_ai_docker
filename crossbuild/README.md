# Autoware Cross Build Docker
To use the cross build tool, first make sure Docker is properly installed.

[Docker installation](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)

## How to Build Docker images for cross-compilation
Autoware users skip this step.
```
$ cd docker/crossbuild/

# generic-aarch64 (these are the default options for build_cross_image.sh)
$ ./build_cross_image.sh --ros-distro melodic --platform generic-aarch64
```

The following options are available on the `build_cross_image.sh` script:
```
    -h,--help              Display the usage and exit.
    -i,--image <name>      Set docker images name.
                           Default: autoware/build
    -p,--platform <name>   Set the target platform/architecture.
                           Default: generic-aarch64
                           Valid: generic-aarch64, driveworks
    -r,--ros-distro <name> Set ROS distribution name.
                           Default: melodic
    -t,--tag-suffix <tag>  Tag suffix to use for docker images.
                           Default: local
```
