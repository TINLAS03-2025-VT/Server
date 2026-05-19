# Jacht ROS Server

ROS 2 Humble server for the Jachtseizoen robot swarm project.

This container runs the ROS-TCP-Endpoint so Unity can connect to the ROS 2 server over TCP port 10000.

## Run the server


Create or use the provided compose.yaml file

``` yaml

services:
  jacht-ros-server:
    image: ghcr.io/tinlas03-2025-vt/server:latest
    container_name: jacht-ros-server
    restart: unless-stopped
    environment:
      - ROS_DOMAIN_ID=42
    ports:
      - "10000:10000/tcp"
```

then run:

    docker compose pull
    docker compose up -d

The ROS TCP endpoint listens on:

    <server-ip>:10000

## View logs

    docker compose logs -f

## Stop the server

    docker compose down

## Local development

Use the development compose file:

    docker compose -f compose.dev.yaml run --rm --service-ports jacht-ros-dev

Inside the development container:

    colcon build --merge-install
    source install/setup.bash
    ros2 interface list | grep jacht

## Add a custom message

1. Add a .msg file to:

       ros_ws/src/jacht_msgs/msg/

2. Add the new .msg file to:

       ros_ws/src/jacht_msgs/CMakeLists.txt

3. Test locally.

4. Commit and push.

5. GitHub Actions will build and publish the new Docker image.

## Image

The published image is:

    ghcr.io/tinlas03-2025-vt/server:latest
