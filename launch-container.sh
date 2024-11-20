#!/bin/sh

read -p "Type port number: " PORT
while :
do
  if [ -z "$PORT" ]; then
    read -p "Type port number: " PORT
  else
    break
  fi
done

id
read -p "Type User ID: " ID
while :
do
  if [ -z "$ID" ]; then
    read -p "Type User ID: " ID
  else
    break
  fi
done

read -p "Which directories mounts to the container?: " MOUNT_DIR
while :
do
  if [ -z "$MOUNT_DIR" ]; then
    read -p "Which directories mounts to the container?: " MOUNT_DIR
  else
    break
  fi
done

read -p "Type container name: " CONTAINER_NAME
while :
do
  if [ -z "$CONTAINER_NAME" ]; then
    read -p "Type container name: " CONTAINER_NAME
  else
    break
  fi
done

echo \
"# ==============================
# Visualize Docker image
# ==============================
"
docker images
echo \
"
# =============================="

read -p "Waht is kind of docker image?: " DOCKER_IMAGE
while :
do
  if [ -z "$DOCKER_IMAGE" ]; then
    read -p "Waht is kind of docker image?: " DOCKER_IMAGE
  else
    break
  fi
done

while :
do
echo \
"
Port number    : $PORT
Mount directory: $MOUNT_DIR
Container name : $CONTAINER_NAME
Docker image   : $DOCKER_IMAGE
"
read -p "These arguments are true? (y/n): " CONFIRM
  
  if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    break
  elif [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "n" ]; then
    read -p "Which setting do you want to change? (port/mount/name/image): " FIX
    
    if [ "$FIX" = "port" ]; then
      read -p "Type port name: " PORT
    elif [ "$FIX" = "mount" ]; then
      read -p "Which directories mounts to the container?: " MOUNT_DIR
    elif [ "$FIX" = "name" ]; then
      read -p "Type container name: " CONTAINER_NAME
    elif [ "$FIX" = "image" ]; then
      read -p "Waht is kind of docker image?: " DOCKER_IMAGE
    else
      read -p "Which setting do you want to change? (port/mount/name/image): " FIX
    fi
    
  else
    read -p "These arguments are true? (y/n): " CONFIRM
  fi
done


while :
do
  read -p "Launch jupyter lab at the same time as building the container? (y/n): " JUPYTER
  if [ "$JUPYTER" = "y" ] || [ "$JUPYTER" = "Y" ] || [ "$JUPYTER" = "n" ] || [ "$JUPYTER" = "n" ]; then
    break
  fi
done

if [ "$JUPYTER" = "y" ] || [ "$JUPYTER" = "Y" ]; then
    echo "Build docker container with $DOCKER_IMAGE and launch jupyter lab in the container"
    docker run --gpus=all --shm-size=8g --rm -it -u $ID:$ID -p $PORT:8888 \
        -v $MOUNT_DIR:/home/workspace -v /mnt/disk1:/home/disk1 -v /mnt/disk2:/home/disk2  --ipc=host --name $CONTAINER_NAME \
        $DOCKER_IMAGE\
        jupyter lab --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token= --notebook-dir='/home'
else
    echo "Build docker container with $DOCKER_IMAGE"
    docker run --gpus=all --shm-size=8g --rm -it -u $ID:$ID -p $PORT:8888 \
        -v $MOUNT_DIR:/home/workspace -v /mnt/disk1:/home/disk1 -v /mnt/disk2:/home/disk2  --ipc=host --name $CONTAINER_NAME \
        $DOCKER_IMAGE
fi
