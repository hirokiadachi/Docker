#! /bin/bash

read -p "Type dockerfile name: " FILE_NAME
read -p "Select ubuntu version (18.04/20.04): " UBUNTU_VER
while :
do
  if [ "$UBUNTU_VER" = "18.04" ] || [ "$UBUNTU_VER" = "20.04" ]; then
      echo "==> Use ubuntu version: $UBUNTU_VER"
      break
  else
      read -p "Select ubuntu version (18.04/20.04): " UBUNTU_VER
  fi
done

read -p "Select cuda version (10.2/11.4.2): " CUDA_VER
while :
do
  if [ "$CUDA_VER" = "10.2" ] || [ "$CUDA_VER" = "11.4.2" ]; then
    echo "==> Use cuda version: $CUDA_VER"
    break
  else
    read -p "Select cuda version (10.2/11.4.2): " CUDA_VER
  fi
done

read -p "Type your USER ID: " UID
while :
do
  if [ -n "$UID" ]; then
    break
  else
    read -p "Type your USER ID: " UID
  fi
done

read -p "Type your GROUP ID: " GID
while :
do
  if [ -n "$GID" ]; then
    break
  else
    read -p "Type your GROUP ID: " GID
  fi
done

read -p "Type user name in a docker container: " USER_NAME
while :
do
  if [ -n "$USER_NAME" ]; then
    echo "==> User name: $USER_NAME"
    break
  else
    read -p "Type user name in a docker container: " USER_NAME
  fi
done

read -p "Type password: " PW
while :
do
  if [ -n "$PW" ]; then
    break
  else
    read -p "Type password: " PW
  fi
done

echo \
"#!/bin/bash

USER_ID=\${LOCAL_UID:-9001}
GROUP_ID=\${LOCAL_GID:-9001}

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
useradd -u $USER_ID -o -m user
groupmod -g $GROUP_ID user
export HOME=/home/user

exec /usr/sbin/gosu user "$@"
"


echo \
"#####################################################################
# This Dockerfile was generated by dockerfile-generator.sh
# Image build:
#   docker build --force-rm=true --rm=true -t {REPOSITORY}:{TAG} --no-cache=true .
# Container build:
#   docker run --runtim=nvidia --rm -it -u {USER ID}:{GROUP ID} -p {PORT NUM}:8888 -v {local dir}:/home/{USER NAME} --ipc=host --name {CONTAINER NAME} {REPOSITORY}:{TAG}
#####################################################################

# =====================================================================
# Set Versions
# =========================================" > $FILE_NAME

if [ "$CUDA_VER" = "10.2" ] && [ "$UBUNTU_VER" = "18.04" ]; then
  echo "FROM nvidia/cuda:$CUDA_VER-cudnn7-devel-ubuntu$UBUNTU_VER" >> $FILE_NAME
else
  echo "FROM nvidia/cuda:$CUDA_VER-cudnn8-devel-ubuntu$UBUNTU_VER" >> $FILE_NAME
fi

echo \
"ARG UID=$UID
ARG GID=$GID
ARG USER_NAME=$USER_NAME
ARG PASSWORD=$PW
ARG PYTHON_VERSION=python3.7

RUN useradd -m -s /bin/bash -u \${UID} \${USER_NAME}

ENV LD_LIBRARY_PATH=/usr/local/lib:\${LD_LIBRARY_PATH}
ENV CPATH=/usr/local/include:\${CPATH}
ENV CUDA_PATH=/usr/local/cuda
ENV CPATH=\${CUDA_PATH}/include:\${CPATH}
ENV LD_LIBRARY_PATH=\${CUDA_PATH}/lib64:\${CUDA_PATH}/lib:\${LD_LIBRARY_PATH}
ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/root/\${USER_NAME}
WORKDIR \$WORK_DIR" >> $FILE_NAME

echo \
"
# =========================================
# Ubuntu setting
# =========================================
RUN rm -rf /var/lib/apt/lists/*\\
            /etc/apt/source.list.d/cuda.list\\
            /etc/apt/source.list.d/nvidia-ml.list

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-get update -y &&\\
    apt-get upgrade -y
 
RUN apt-get install -y --no-install-recommends build-essential\\
                                               apt-utils\\
                                               ca-certificates\\
                                               make\\
                                               cmake\\
                                               wget\\
                                               git\\
                                               curl\\
                                               vim\\
                                               openssh-server

RUN curl -sL https://deb.nodesource.com/setup_current.x | bash - && \\
    apt-get install -y --no-install-recommends nodejs

RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* \\
           /var/cache/apt/* \\
           /usr/local/src/* \\
           /tmp/*" >> $FILE_NAME

echo \
"
# =========================================
# Python setting
# =========================================
RUN apt-get update\\
 && apt-get install unzip\\
 && apt-get install -y software-properties-common\\
 && add-apt-repository ppa:deadsnakes/ppa\\
 && apt-get update\\
 && apt-get install -y \${PYTHON_VERSION} \${PYTHON_VERSION}-dev python3-distutils-extra\\
 && wget -O ~/get-pip.py https://bootstrap.pypa.io/get-pip.py\\
 && \${PYTHON_VERSION} ~/get-pip.py\\
 && ln -s /usr/bin/\${PYTHON_VERSION} /usr/local/bin/python3\\
 && ln -s /usr/bin/\${PYTHON_VERSION} /usr/local/bin/python" >> $FILE_NAME
 
echo \
"
# =========================================
# Install OpenCV
# =========================================
RUN apt-get install -y --no-install-recommends libatlas-base-dev\\
        libgflags-dev \\
        libgoogle-glog-dev \\
        libhdf5-serial-dev \\
        libleveldb-dev \\
        liblmdb-dev \\
        libprotobuf-dev \\
        libsnappy-dev \\
        protobuf-compiler
RUN git clone --branch 4.0.1 https://github.com/opencv/opencv ~/opencv && \\
mkdir -p ~/opencv/build && cd ~/opencv/build && \\
cmake -D CMAKE_BUILD_TYPE=RELEASE \\
          -D CMAKE_INSTALL_PREFIX=/usr/local \\
          -D WITH_IPP=OFF \\
          -D WITH_CUDA=OFF \\
          -D WITH_OPENCL=OFF \\
          -D BUILD_TESTS=OFF \\
          -D BUILD_PERF_TESTS=OFF \\
          .. &&\\
    make -j"$(nproc)" install && \\
    ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2" >> $FILE_NAME
    
echo \
"
# =======================================================
# Install python modules
#   * Require requirements.txt to install python modules
# =======================================================
COPY requirements.txt \$WORK_DIR
RUN pip install -r requirements.txt &&\\
    pip install bhtsne" >> $FILE_NAME
    
echo \
"
# =========================================
# Jupyter setting
# =========================================
RUN pip install --upgrade --no-cache-dir \\
    'jupyterlab-kite>=2.0.2' \\
    jupyterlab_code_formatter \\
    jupyterlab-vimrc \\
    yapf \\
 && rm -rf ~/.cache/pip
 
WORKDIR /
COPY jupyter_lab_config.py /root/.jupyter/" >> $FILE_NAME
 
echo \
"
USER \${USER_NAME}
EXPOSE 8888 6006" >> $FILE_NAME