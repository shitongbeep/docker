#!/bin/bash

container_name="shitong"

if [[ $(docker ps -a --format "{{.Names}}" | grep -w "$container_name") ]]; then
    docker start "$container_name"
    docker exec -it "$container_name" /bin/bash
else
    docker run \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /home/$USER/slam:/home/$USER/slam \
        -v /home/$USER/datasets:/home/$USER/datasets \
        -e DISPLAY=$DISPLAY \
        -e NVIDIA_DRIVER_CAPABILITIES=all \
        -u $USER:$USER \
        --name $USER \
        --network host \
        --gpus all -it --rm lio:v1.0
fi
