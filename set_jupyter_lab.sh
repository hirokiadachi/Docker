!/bin/bash

echo "*** Install Jupyter lab extensions ***"
echo "Install Node.js (preprocessing)"

sudo pip install --upgrade jupyterlab
# Node.jsの導入(バージョンは適宜修正してください)
sudo pip install curl
sudo curl -sL https://deb.nodesource.com/setup_14.x |bash -
sudo apt-get install -y --no-install-recommends nodejs

# Node.jsの最新版が上手く入らないので，以下のようにして対応
sudo apt install -y nodejs npm
sudo npm install n -g
sudo n stable
sudo apt purge -y nodejs npm

echo "Install extensions"

# 変数名や型、内容を常に横に表示しておける. デバッグのお供になるかも?
sudo jupyter labextension install @lckr/jupyterlab_variableinspector

# Install pytorch just in case 
pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121
pip install 'numpy<2.0'

# plotly用jupyter連携用extension
sudo jupyter labextension install @hokyjack/jupyterlab-monokai-plus
sudo jupyter labextension install @jupyterlab/toc
sudo jupyter labextension install jupyterlab-vimrc
sudo jupyter serverextension enable --py jupyterlab_code_formatter

jupyter lab --ip=0.0.0.0 --allow-root --no-browser --NotebookApp.allow_origin='*' --NotebookApp.allow_remote_access=True --NotebookApp.token= --notebook-dir="/home"