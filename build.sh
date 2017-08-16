#!/bin/bash
IMG_NAME="graal"
#nvidia-docker build -t $IMG_NAME .
#nvidia-docker run $IMG_NAME './build_pycuda.sh'
CONTAINER=$(docker ps -l -q | head -n 1)
#docker cp examples $CONTAINER:scratch/
docker cp examples/HindIII-all $CONTAINER:scratch/input_data
nvidia-docker commit $CONTAINER graal
