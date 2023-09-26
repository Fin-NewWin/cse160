#!/bin/sh


xhost local:root
XAUTH=/tmp/.docker.XAUTH

sudo docker start tiny

sudo docker exec -it tiny bash
