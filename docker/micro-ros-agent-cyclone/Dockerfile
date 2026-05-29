FROM microros/micro-ros-agent:humble

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-rmw-cyclonedds-cpp \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*
