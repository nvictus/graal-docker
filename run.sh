#!/bin/bash
DATADIR=data
xhost +
nvidia-docker run \
	--privileged \
	--rm \
	--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
	--volume $DATADIR:/data \
    --env DISPLAY=$DISPLAY \
    --name graal \
    -it graal /bin/bash \
