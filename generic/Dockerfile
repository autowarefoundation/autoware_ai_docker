ARG FROM_ARG
# hadolint ignore=DL3006
FROM ${FROM_ARG}
ARG ROS_DISTRO
ARG VERSION

USER autoware
ENV USERNAME autoware

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build Autoware
RUN bash -c 'mkdir -p /home/$USERNAME/Autoware/src; \
    cd /home/$USERNAME/Autoware; \
    wget https://raw.githubusercontent.com/Autoware-AI/autoware.ai/$VERSION/autoware.ai.repos; \
    vcs import src < autoware.ai.repos; \
    source /opt/ros/$ROS_DISTRO/setup.bash; \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release'

RUN echo "source /home/$USERNAME/Autoware/install/local_setup.bash" >> \
    /home/$USERNAME/.bashrc

COPY ./entrypoint.sh /tmp
# hadolint ignore=DL3002
USER root
ENTRYPOINT ["/tmp/entrypoint.sh"]
