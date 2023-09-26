#!/usr/bin/env bash


if [ $(sudo docker image ls | grep "tinyos_debian" | wc -l) -eq 0 ]; then
    echo "======================================"
    echo "            Build Container           "
    echo "======================================"

    sudo docker pull ucmerceddandeslab/tinyos_debian
fi

echo "======================================"
echo "          Create container            "
echo "======================================"

if [ $(sudo docker ps -a | grep "tiny" | wc -l) -eq 1 ]; then
    echo "Deleting old container"
    sudo docker rm -f tiny

fi

sudo docker run -idt \
    --name="tiny"\
    --env="DISPLAY=$DISPLAY"\
    --env="QT_X11_NO_MITSHM=1"\
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"\
    --env="XAUTHORITY=$XAUTH"\
    --net=host \
    --privileged \
    -v $(pwd)/CSE160-Project-Skeleton-Code:/opt/tinyos-main/apps/CSE160-Project-Skeleton-Code \
    2347c5a05ed4 \
    bash


echo "Done"
