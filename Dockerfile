#####################################################################
# This Dockerfile was generated by dockerfile-generator.sh
# Image build:
#   docker build --force-rm=true --rm=true -t {REPOSITORY}:{TAG} --no-cache=true .
# Container build:
#   docker run --runtim=nvidia --rm -it -u {USER ID}:{GROUP ID} -p {PORT NUM}:8888 -v {local dir}:/home/{USER NAME} --ipc=host --name {CONTAINER NAME} {REPOSITORY}:{TAG}
#####################################################################

# =========================================
# Set Versions
# =========================================
FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04
ARG UID=****
ARG GID=****
ARG USER_NAME=****
ARG PASSWORD=****
ARG PYTHON_VERSION=python.xxx

ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
ENV CPATH=/usr/local/include:${CPATH}
ENV CUDA_PATH=/usr/local/cuda
ENV CPATH=${CUDA_PATH}/include:${CPATH}
ENV LD_LIBRARY_PATH=${CUDA_PATH}/lib64:${CUDA_PATH}/lib:${LD_LIBRARY_PATH}
ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/root/${USER_NAME}
WORKDIR $WORK_DIR

# =========================================
# Ubuntu setting
# =========================================
RUN rm -rf /var/lib/apt/lists/*\
            /etc/apt/source.list.d/cuda.list\
            /etc/apt/source.list.d/nvidia-ml.list

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-get update -y &&\
    apt-get upgrade -y
 
RUN apt-get install -y --no-install-recommends build-essential\
                                               apt-utils\
                                               ca-certificates\
                                               make\
                                               cmake\
                                               wget\
                                               git\
                                               curl\
                                               vim\
                                               openssh-server

RUN apt-get install -y --no-install-recommends sudo
RUN groupadd -g ${GID} ${USER_NAME} && \
    useradd -m -s /bin/bash -u ${UID} -g ${GID} -G sudo ${USER_NAME} && \
    echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
    echo "%${USER_NAME}    ALL=(ALL)   NOPASSWD:    ALL"  >> /etc/sudoers

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -     && apt-get install -y nodejs
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/* \
           /usr/local/src/* \
           /tmp/*

# =========================================
# Python setting
# =========================================
RUN apt-get update\
 && apt-get install unzip\
 && apt-get install -y software-properties-common\
 && add-apt-repository ppa:deadsnakes/ppa\
 && apt-get update\
 && apt-get install -y ${PYTHON_VERSION} ${PYTHON_VERSION}-dev python3-distutils-extra\
 && wget -O ~/get-pip.py https://bootstrap.pypa.io/get-pip.py\
 && ${PYTHON_VERSION} ~/get-pip.py\
 && ln -s /usr/bin/${PYTHON_VERSION} /usr/local/bin/python3\
 && ln -s /usr/bin/${PYTHON_VERSION} /usr/local/bin/python

# =========================================
# Install OpenCV
# =========================================
RUN apt-get install -y --no-install-recommends libatlas-base-dev\
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler
RUN git clone --branch 4.0.1 https://github.com/opencv/opencv ~/opencv && \
mkdir -p ~/opencv/build && cd ~/opencv/build && \
cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_OPENCL=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          .. &&\
    make -j80 install && \
    ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2

# =======================================================
# Install python modules
#   * Require requirements.txt to install python modules
# =======================================================
COPY requirements.txt $WORK_DIR
RUN pip install -r requirements.txt &&\
    pip install bhtsne \
    pip install 'python-lsp-server[all]'

# =========================================
# Jupyter setting
# =========================================
RUN jupyter labextension install @jupyterlab/toc \
    @axlair/jupyterlab_vim \
    @ryantam626/jupyterlab_code_formatter \
    @jupyter-widgets/jupyterlab-manager \
    jupyterlab-plotly@4.14.3 \
    jupyterlab-vimrc
RUN jupyter nbextensions_configurator enable
RUN jupyter labextension enable toc jupyterlab-manager
RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter notebook --generate-config --allow-root
RUN ipython profile create
RUN rm -rf ~/.cache/pip
 
WORKDIR /
COPY jupyter_lab_config.py /root/.jupyter/

USER ${USER_NAME}
EXPOSE 8888 6006
