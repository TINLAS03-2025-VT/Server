# Jacht ROS Server

Containerized ROS 2 Humble server for the Jachtseizoen robot swarm project.

This stack runs:

- `jacht-wireguard-server`: WireGuard network namespace for remote ROS 2 nodes.
- `jacht-ros-server`: Unity ROS-TCP-Endpoint on TCP `10000`.
- `micro-ros-agent-udp`: micro-ROS Agent for Pico robots on UDP `8888`.

The ROS containers share the WireGuard container network namespace and use CycloneDDS on `wg0`.

## Prerequisites

- Docker + Docker Compose.
- Router/firewall forwards external UDP `51821` to this server.
- A WireGuard server config exists at `wireguard-server/`.
- `wireguard-server/` must not be committed because it contains private keys.

## First-time WireGuard setup

Start the WireGuard service once to generate peer configs:

```bash
docker compose up -d wireguard-server
find wireguard-server -name "*.conf"
```

Send each tracker user their own peer config. They should save it as:

```text
wireguard-client/wg_confs/wg0.conf
```

## Production run

The main ROS server image is published by GitHub Actions as:

```text
ghcr.io/tinlas03-2025-vt/server:latest
```

Run:

```bash
docker compose pull
docker compose up -d --build
```

`--build` is still used because the small `micro-ros-agent-udp` compatibility image is built locally.

## Logs

```bash
docker logs -f jacht-wireguard-server
docker logs -f jacht-ros-server
docker logs -f micro-ros-agent-udp
```

## Test ROS topics

```bash
docker exec -it jacht-ros-server bash
source /opt/ros/humble/setup.bash
[ -f /ros_ws/install/setup.bash ] && source /ros_ws/install/setup.bash
ros2 topic list -t
```

## Unity

Unity connects to:

```text
<server-ip>:10000
```

## Pico / micro-ROS

Pico firmware connects to:

```text
<server-ip>:8888 UDP
```

## Add a custom message

1. Add the `.msg` file to `ros_ws/src/jacht_msgs/msg/`.
2. Add it to `ros_ws/src/jacht_msgs/CMakeLists.txt`.
3. Commit and push.
4. GitHub Actions builds and publishes a new server image.
