!/bin/bash

echo "*** Install Jupyter lab extensions ***"
echo "Install Node.js (preprocessing)"

pip install --upgrade jupyterlab
# Node.jsの導入(バージョンは適宜修正してください)
pip install curl
curl -sL https://deb.nodesource.com/setup_14.x |bash -
apt-get install -y --no-install-recommends nodejs

# Node.jsの最新版が上手く入らないので，以下のようにして対応
apt install -y nodejs npm
npm install n -g
n stable
apt purge -y nodejs npm

echo "Install extensions"

# 変数名や型、内容を常に横に表示しておける. デバッグのお供になるかも?
jupyter labextension install @lckr/jupyterlab_variableinspector

# Install pytorch just in case 
 pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121
# Tensorboard 連携
# TODO エラー吐くけど動くので放置
pip install jupyter-tensorboard
jupyter labextension install jupyterlab_tensorboard
jupyter serverextension enable --py jupyterlab_tensorboard

# plotly用jupyter連携用extension
jupyter labextension install jupyterlab-plotly@4.14.3

jupyter labextension install @hokyjack/jupyterlab-monokai-plus
jupyter labextension install @ryantam626/jupyterlab_code_formatter
jupyter labextension install @jupyterlab/toc
jupyter labextension install jupyterlab-vimrc
jupyter labextention install @axlair/jupyterlab_vim
jupyter serverextension enable --py jupyterlab_code_formatter

#jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --notebook-dir="/home"
jupyter lab --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token= --notebook-dir="/home"
