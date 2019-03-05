#############################################
# Base image: https://github.com/ufoym/deepo
#############################################
FROM ufoym/deepo:all-jupyter

ENV DOCKERBUILD_CHAINER_VERSION=3.0.0 \
    DOCKERBUILD_CHAINERCV_VERSION=0.7.0 \
    DOCKERBUILD_PYTORCH_VERSION=0.4.1

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
#RUN pip uninstall  --yes torch torchvision

################
# pytorch
################
RUN pip install torch==${DOCKERBUILD_PYTORCH_VERSION}

################
# tqdm
################
RUN pip install tqdm

################
# chainer
################
RUN pip install chainer==${DOCKERBUILD_CHAINER_VERSION} \
                chainercv==${DOCKERBUILD_CHAINERCV_VERSION}
