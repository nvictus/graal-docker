#!/bin/bash
nvidia-docker build -t graal .

# manual edit examples
# --------------------
# nvidia-docker cp xyz graal:xyz/
# nvidia-docker run --name graal-container -it graal /bin/bash
# nvidia-docker commit graal-container graal
# docker stop graal-container; docker rm graal-container
