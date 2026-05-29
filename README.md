# Jacht ROS Server

Containerized ROS 2 server stack for the Jacht project.

This stack runs:

- WireGuard server
- ROS-TCP Endpoint for Unity
- micro-ROS Agent for Pico robots

The ROS containers share the WireGuard container network namespace. This keeps ROS 2 / DDS traffic inside the VPN namespace instead of exposing it directly on the host network.

## Services

| Service | Purpose |
|---|---|
| `wireguard-server` | Creates the WireGuard VPN network |
| `jacht-ros-server` | Runs the Unity ROS-TCP Endpoint on TCP port `10000` |
| `micro-ros-agent-udp` | Runs the micro-ROS Agent on UDP port `8888` |

## Network

The WireGuard server uses:

```text
Server VPN IP: 10.13.13.1
WireGuard external UDP port: 51821
WireGuard internal container UDP port: 51820
Unity ROS-TCP port: 10000/tcp
micro-ROS Agent port: 8888/udp
```

The ROS 2 graph uses CycloneDDS over the WireGuard interface.

## Secrets

Do not commit WireGuard configs or keys.

The following folder must stay local only:

```text
wireguard-server/
```

It should be listed in `.gitignore`.

## Images

The main ROS server image is published by GitHub Actions:

```text
ghcr.io/tinlas03-2025-vt/server:latest
```

The WireGuard image is pulled from LinuxServer:

```text
lscr.io/linuxserver/wireguard:latest
```

The micro-ROS Agent compatibility image is currently built locally from:

```text
docker/micro-ros-agent-cyclone/Dockerfile
```

Because the micro-ROS Agent image is currently local, do not use plain `docker compose pull` for the whole stack.

## Deploy or update the server

From the server repo:

```bash
cd ~/Server

docker compose pull wireguard-server jacht-ros-server
docker compose up -d --build
```

This does the following:

- pulls `wireguard-server`
- pulls `jacht-ros-server`
- builds `micro-ros-agent-udp` locally if needed
- starts the full stack

## Check containers

```bash
docker compose ps
```

Expected services:

```text
jacht-wireguard-server
jacht-ros-server
micro-ros-agent-udp
```

## Check logs

```bash
docker logs -f jacht-wireguard-server
```

```bash
docker logs -f jacht-ros-server
```

```bash
docker logs -f micro-ros-agent-udp
```

Expected server log:

```text
jacht-ros-server contained wg0 ready
[UnityEndpoint]: Starting server on 0.0.0.0:10000
```

Expected micro-ROS Agent log:

```text
micro-ROS agent contained wg0 ready
running... port: 8888
```

## Check WireGuard

```bash
docker exec -it jacht-wireguard-server wg show
```

```bash
docker exec -it jacht-wireguard-server ip addr show wg0
```

Expected VPN address:

```text
10.13.13.1
```

## Check ROS topics

```bash
docker exec -it jacht-ros-server bash
```

Inside the container:

```bash
source /opt/ros/humble/setup.bash
[ -f /ros_ws/install/setup.bash ] && source /ros_ws/install/setup.bash
ros2 topic list
```

To check tracker position data:

```bash
ros2 topic echo /robots/pos geometry_msgs/msg/PoseArray
```

## Unity connection

Unity should connect to the server IP on TCP port `10000`.

Example:

```text
<server-ip>:10000
```

## Pico / micro-ROS connection

Pico micro-ROS clients should connect to the server IP on UDP port `8888`.

Example:

```text
<server-ip>:8888
```

## CycloneDDS

CycloneDDS config lives in:

```text
cyclonedds/server.xml
```

It forces ROS 2 to use the WireGuard interface:

```text
wg0
```

Multicast is disabled because WireGuard is a routed VPN interface, not a normal multicast-capable LAN.

## Future cleanup

To make the stack fully pull-only, publish the custom micro-ROS Agent image to GHCR too.

Then the deployment command can become:

```bash
docker compose pull
docker compose up -d
```

Until then, use:

```bash
docker compose pull wireguard-server jacht-ros-server
docker compose up -d --build
```
