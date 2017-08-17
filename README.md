# graal-docker

GRAAL in a container.

1. Install [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

2. Build the image

```bash
$ nvidia-docker build graal .
```

3. Start a container and shell into it with mounted volumes and connected display (see `run.sh`)

```bash
$ DATADIR=$(pwd)/examples/
$ xhost +
$ nvidia-docker run \
    --privileged \
    --rm \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --volume $DATADIR:/data \
    --env DISPLAY=$DISPLAY \
    --name graal-container \
    -it graal /bin/bash \
```

Omit the `--rm` if you do not want to run it ephemerally.
