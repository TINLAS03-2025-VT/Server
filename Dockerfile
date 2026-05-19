FROM ros:humble-ros-base

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV ROS_DOMAIN_ID=42

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-dev-tools \
    git \
    ca-certificates \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ros_ws

COPY ros_ws/src /ros_ws/src
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Add the ROS 2 version of Unity's ROS-TCP-Endpoint.
RUN git clone --depth 1 --branch main-ros2 \
    https://github.com/Unity-Technologies/ROS-TCP-Endpoint.git \
    /ros_ws/src/ROS-TCP-Endpoint

RUN source /opt/ros/humble/setup.bash && \
    rosdep update && \
    rosdep install --from-paths src -y --ignore-src --rosdistro humble && \
    colcon build --merge-install

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "[ -f /ros_ws/install/setup.bash ] && source /ros_ws/install/setup.bash" >> /root/.bashrc

ENTRYPOINT ["/entrypoint.sh"]

CMD ["ros2", "run", "ros_tcp_endpoint", "default_server_endpoint", "--ros-args", "-p", "ROS_IP:=0.0.0.0", "-p", "ROS_TCP_PORT:=10000"]
