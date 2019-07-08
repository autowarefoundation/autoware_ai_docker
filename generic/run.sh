#!/bin/bash

# Default settings
CUDA="on"
IMAGE_NAME="autoware/autoware"
TAG_PREFIX="latest"
ROS_DISTRO="kinetic"
BASE_ONLY="false"
PRE_RELEASE="off"
AUTOWARE_HOME=""

function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -a,--autoware-home <autoware_home> If provided, run the base image only and mount the provided Autoware folder."
    echo "                                       Default: Use pre-compiled Autoware image"
    echo "    -b,--base-only                     DEPRECATED: Use -a/--autoware-home."
    echo "    -c,--cuda <on|off>                 Enable Cuda support in the Docker."
    echo "                                       Default: $CUDA"
    echo "    -h,--help                          Display the usage and exit."
    echo "    -i,--image <name>                  Set docker images name."
    echo "                                       Default: $IMAGE_NAME"
    echo "    -p,--pre-release <on|off>          Use pre-release image."
    echo "                                       Default: $PRE_RELEASE"
    echo "    -r,--ros-distro <name>             Set ROS distribution name."
    echo "                                       Default: $ROS_DISTRO"
    echo "    -t,--tag-prefix <tag>              Tag prefix use for the docker images."
    echo "                                       Default: $TAG_PREFIX"
}

OPTS=`getopt --options a:bc:hi:p:r:t: \
         --long autoware-home:,base-only,cuda:,help,image-name:,pre-release:,ros-distro:,tag-prefix: \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
  case $1 in
    -a|--autoware-home)
      BASE_ONLY="true"
      AUTOWARE_HOME=$2
      shift 2
      ;;
    -b|--base-only)
      usage
      exit 0
      ;;
    -c|--cuda)
      param=$(echo $2 | tr '[:upper:]' '[:lower:]')
      case "${param}" in
        "on"|"off") CUDA="${param}" ;;
        *) echo "Invalid cuda option: $2"; exit 1 ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -i|--image-name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    -p|--pre-release)
      param=$(echo $2 | tr '[:upper:]' '[:lower:]')
      case "${param}" in
        "on"|"off") PRE_RELEASE="${param}" ;;
        *) echo "Invalid pre-release option: $2"; exit 1 ;;
      esac
      shift 2
      ;;
    -r|--ros-distro)
      ROS_DISTRO="$2"
      shift 2
      ;;
    -t|--tag-prefix)
      TAG_PREFIX="$2"
      shift 2
      ;;
    --)
      if [ ! -z $2 ];
      then
        echo "Invalid parameter: $2"
        exit 1
      fi
      break
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
done

echo "Using options:"
echo -e "\tROS distro: $ROS_DISTRO"
echo -e "\tImage name: $IMAGE_NAME"
echo -e "\tTag prefix: $TAG_PREFIX"
echo -e "\tCuda support: $CUDA"
if [ "$BASE_ONLY" == "true" ]; then
  echo -e "\tAutoware Home: $AUTOWARE_HOME"
fi
echo -e "\tPre-release version: $PRE_RELEASE"

SUFFIX=""
RUNTIME=""

XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority

SHARED_DOCKER_DIR=/home/autoware/shared_dir
SHARED_HOST_DIR=$HOME/shared_dir

AUTOWARE_DOCKER_DIR=/home/autoware/Autoware

VOLUMES="--volume=$XSOCK:$XSOCK:rw
         --volume=$XAUTH:$XAUTH:rw
         --volume=$SHARED_HOST_DIR:$SHARED_DOCKER_DIR:rw"

if [ "$BASE_ONLY" == "true" ]; then
    SUFFIX=$SUFFIX"-base"
    VOLUMES="$VOLUMES --volume=$AUTOWARE_HOME:$AUTOWARE_DOCKER_DIR "
fi

if [ $CUDA == "on" ]; then
    SUFFIX=$SUFFIX"-cuda"
    RUNTIME="--runtime=nvidia"
fi

if [ $PRE_RELEASE == "on" ]; then
    SUFFIX=$SUFFIX"-rc"
fi

# Create the shared directory in advance to ensure it is owned by the host user
mkdir -p $SHARED_HOST_DIR

IMAGE=$IMAGE_NAME:$TAG_PREFIX-$ROS_DISTRO$SUFFIX
echo "Launching $IMAGE"

docker run \
    -it --rm \
    $VOLUMES \
    --env="XAUTHORITY=${XAUTH}" \
    --env="DISPLAY=${DISPLAY}" \
    --user $(id -u):$(id -g) \
    --env="USER_ID=$(id -u)" \
    --privileged \
    --net=host \
    $RUNTIME \
    $IMAGE
