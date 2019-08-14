#!/bin/bash

set -e

# Default settings
IMAGE_NAME="autoware/build"
TARGET_PLATFORM="generic-aarch64"
DOCKER_ARCH="arm64v8"
LINUX_ARCH="aarch64"
ROS_DISTRO="melodic"
TAG_SUFFIX="local"

function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -h,--help              Display the usage and exit."
    echo "    -i,--image <name>      Set docker images name."
    echo "                           Default: $IMAGE_NAME"
    echo "    -p,--platform <name>   Set the target platform/architecture."
    echo "                           Default: $TARGET_PLATFORM"
    echo "                           Valid: generic-aarch64, driveworks"
    echo "    -r,--ros-distro <name> Set ROS distribution name."
    echo "                           Default: $ROS_DISTRO"
    echo "    -t,--tag-suffix <tag>  Tag suffix to use for docker images."
    echo "                           Default: $TAG_SUFFIX"
}

OPTS=`getopt --options hi:p:r:t: \
         --long help,image-name:,platform:,ros-distro:,tag-suffix: \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -i|--image-name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    -p|--platform)
      TARGET_PLATFORM="$2"
      shift 2
      ;;
    -r|--ros-distro)
      ROS_DISTRO="$2"
      shift 2
      ;;
    -t|--tag-suffix)
      TAG_SUFFIX="$2"
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

IMAGE_TAG=${TARGET_PLATFORM}-${ROS_DISTRO}-${TAG_SUFFIX}

echo "Using options:"
echo -e "\tImage name: $IMAGE_NAME"
echo -e "\tTarget platform: $TARGET_PLATFORM"
echo -e "\tROS distro: $ROS_DISTRO"
echo -e "\tTag suffix: $TAG_SUFFIX"
echo ""

FROM_FILE="Dockerfile.${ROS_DISTRO}-crossbuild"

# Register QEMU as a handler for non-x86 targets
docker container run --rm --privileged multiarch/qemu-user-static:register --reset

# Copy dependencies file into build context
cp ../dependencies .

if [ "$TARGET_PLATFORM" = "driveworks" ]; then
  FROM_FILE="${FROM_FILE}-driveworks"
fi

# Build Docker Image
docker image build \
  --build-arg AUTOWARE_DOCKER_ARCH=${DOCKER_ARCH} \
  --build-arg AUTOWARE_TARGET_ARCH=${LINUX_ARCH} \
  --build-arg AUTOWARE_TARGET_PLATFORM=${TARGET_PLATFORM} \
  -t ${IMAGE_NAME}:${IMAGE_TAG} \
  -f ${FROM_FILE} .

# Remove dependencies file from build context
rm dependencies
