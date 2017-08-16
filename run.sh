#!/bin/bash
IMG_NAME="graal"
COMMAND="/bin/bash"
xhost +
nvidia-docker run --privileged --rm \
	--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --env DISPLAY=$DISPLAY \
    -it $IMG_NAME $COMMAND \
