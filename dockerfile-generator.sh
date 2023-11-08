#! /bin/bash

read -p "Type dockerfile name: " FILE_NAME
TF=`test -f $FILE_NAME && echo 'TRUE' || echo 'FALSE'`
echo $TF
if [ "$TF" = "TRUE" ]; then
  while :
  do
  read -p "Does previous Dockerfile remove? (y/n): " REMOVE
  if [ "$REMOVE" = "Y" ] || [ "$REMOVE" = "y" ]; then
    rm $FILE_NAME
    break
  elif [ "$REMOVE" = "N" ] || [ "$REMOVE" = "n" ]; then
    read -p "Type other file name: " FILE_NAME
    break
  else
    read -p "Does previous Dockerfile remove? (y/n): " REMOVE
  fi
  done
fi

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

read -p "Select cuda version (10.2/11.7.1): " CUDA_VER
while :
do
  if [ "$CUDA_VER" = "10.2" ] || [ "$CUDA_VER" = "11.7.1" ]; then
    echo "==> Use cuda version: $CUDA_VER"
    break
  else
    read -p "Select cuda version (10.2/11.7.1): " CUDA_VER
  fi
done

id 
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

read -p "Do you use sudo and authorize user? (y/n): " SUDO
while :
do
  if [ "$SUDO" = "Y" ] || [ "$SUDO" = "y" ] || [ "$SUDO" = "N" ] || [ "$SUDO" = "n" ]; then
    break
  else
    read -p "Do you use sudo and authorize user? (y/n): " SUDO
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

if [ "$UBUNTU_VER" = "18.04" ]; then
  PYTHON_VER=python3.7
elif [ "$UBUNTU_VER" = "20.04" ]; then
  PYTHON_VER=python3.7
fi

echo \
"#####################################################################
# This Dockerfile was generated by dockerfile-generator.sh
# Image build:
#   docker build --force-rm=true --rm=true -t {REPOSITORY}:{TAG} --no-cache=true .
# Container build:
#   docker run --runtim=nvidia --rm -it -u {USER ID}:{GROUP ID} -p {PORT NUM}:8888 -v {local dir}:/home/{USER NAME} --ipc=host --name {CONTAINER NAME} {REPOSITORY}:{TAG}
#####################################################################

# =========================================
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
ARG PYTHON_VERSION=$PYTHON_VER

ENV LD_LIBRARY_PATH=/usr/local/lib:\${LD_LIBRARY_PATH}
ENV CPATH=/usr/local/include:\${CPATH}
ENV CUDA_PATH=/usr/local/cuda
ENV CPATH=\${CUDA_PATH}/include:\${CPATH}
ENV LD_LIBRARY_PATH=\${CUDA_PATH}/lib64:\${CUDA_PATH}/lib:\${LD_LIBRARY_PATH}
ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/root/\${USER_NAME}
WORKDIR \$WORK_DIR
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime" >> $FILE_NAME

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
    apt-get upgrade -y &&\\
    apt-get install -y libgl1-mesa-dev
 
RUN apt-get install -y --no-install-recommends build-essential\\
                                               apt-utils\\
                                               ca-certificates\\
                                               make\\
                                               cmake\\
                                               wget\\
                                               git\\
                                               curl\\
                                               vim\\
                                               tmux\\
                                               openssh-server" >> $FILE_NAME

if [ "$SUDO" = "y" ] || [ "$SUDO" = "Y" ]; then
echo \
"
RUN apt-get install -y --no-install-recommends sudo
RUN groupadd -g \${GID} \${USER_NAME} && \\
    useradd -m -s /bin/bash -u \${UID} -g \${GID} -G sudo \${USER_NAME} && \\
    echo \"\${USER_NAME}:\${USER_NAME}\" | chpasswd && \\
    echo \"%\${USER_NAME}    ALL=(ALL)   NOPASSWD:    ALL\"  >> /etc/sudoers" >> $FILE_NAME
fi

echo \
"
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs
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
 && apt-get install -y \${PYTHON_VERSION}-distutils\\
 && apt-get install -y \${PYTHON_VERSION} \${PYTHON_VERSION}-dev python3-distutils-extra\\
 && wget -O ~/get-pip.py https://bootstrap.pypa.io/get-pip.py\\
 && \${PYTHON_VERSION} ~/get-pip.py\\
 && ln -s /usr/bin/\${PYTHON_VERSION} /usr/local/bin/python3\\
 && ln -s /usr/bin/\${PYTHON_VERSION} /usr/local/bin/python\\
 && wget -O- https://aka.ms/install-vscode-server/setup.sh | sh" >> $FILE_NAME
 
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
COPY ./requirements/_requirements_base.txt /opt/
COPY ./requirements/requirements_nvidia.txt /opt/
RUN python -m pip --no-cache-dir install -r /opt/requirements_nvidia.txt && rm /opt/_requirements_base.txt && rm /opt/requirements_nvidia.txt
RUN python -m pip install jupyter matplotlib tqdm
RUN python -m pip install jupyter_http_over_ws" >> $FILE_NAME
    
echo \
"
# =======================================================
# Install python modules
#   * Require requirements.txt to install python modules
# =======================================================
COPY requirements.txt \$WORK_DIR
RUN pip install -r requirements.txt &&\\
    pip install bhtsne &&\\
    pip install 'python-lsp-server[all]'">> $FILE_NAME

echo \
"
# =======================================================
# Pytorch version 1.10.1
# =======================================================">> $FILE_NAME
if [ "$CUDA_VER" = "11.4.0" ]; then
  echo \
  "RUN pip install torch torchvision torchaudio">> $FILE_NAME
elif [ "$CUDA_VER" = "10.2" ]; then
  echo \
  "RUN pip install torch==1.10.1+cu102 torchvision==0.11.2+cu102 torchaudio==0.10.1 -f https://download.pytorch.org/whl/cu102/torch_stable.html">> $FILE_NAME
fi

echo \
"
# ========================================
# VS Code Server
# ========================================
RUN apt-get update &&\\
    apt-get install -y locales &&\\
    locale-gen ja_JP.UTF-8 &&\\
    echo \"export LANG=ja_JP.UTF-8\" >> ~/.bashrc
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://code-server/dev/install.sh | sh
#RUN code-server \ 
#  --install-extension ms-python.python \
#  --install-extension ms-ceintl.vscode-language-pack-ja" >> $FILE_NAME

    
echo \
"
# =========================================
# Jupyter setting
# =========================================
#RUN jupyter labextension install @jupyterlab/toc \\
#    @axlair/jupyterlab_vim \\
#    @ryantam626/jupyterlab_code_formatter \\
#    @jupyter-widgets/jupyterlab-manager \\
#    jupyterlab-plotly@4.14.3
RUN jupyter nbextensions_configurator enable
RUN jupyter labextension enable toc jupyterlab-manager
#RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter notebook --generate-config --allow-root
RUN ipython profile create
RUN rm -rf ~/.cache/pip
 
WORKDIR /
COPY jupyter_lab_config.py /root/.jupyter/" >> $FILE_NAME

echo \
"
USER \${USER_NAME}
EXPOSE 8888 6006" >> $FILE_NAME
