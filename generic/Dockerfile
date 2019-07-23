ARG FROM_ARG
# hadolint ignore=DL3006
FROM ${FROM_ARG}
ARG ROS_DISTRO
ARG VERSION

ENV USERNAME autoware

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build Autoware
RUN su -c "bash -c 'mkdir -p /home/$USERNAME/Autoware/src; \
           cd /home/$USERNAME/Autoware; \
           wget https://gitlab.com/autowarefoundation/autoware.ai/autoware/raw/$VERSION/autoware.ai.repos; \
           vcs import src < autoware.ai.repos; \
           source /opt/ros/$ROS_DISTRO/setup.bash; \
           colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release'" $USERNAME

RUN echo "source /home/$USERNAME/Autoware/install/local_setup.bash" >> \
    /home/$USERNAME/.bashrc

COPY ./entrypoint.sh /tmp
ENTRYPOINT ["/tmp/entrypoint.sh"]