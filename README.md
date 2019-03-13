# Docker
Hiroki ADACHI作　オリジナルDockerfile

使用したかったサーバがCUDA10.0入っていたので，それ用のDockerfileを作成しました．
## 何が入っているか
* cuda
CUDA:10.0のイメージを作成する場合は```FROM```の行を以下に示すように変更
```
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
```
* python3.6  
コンテナ内でpythonと打つと3系が立ち上がるように設定した．

* numpy
* scipy
* pandas
* scikit-learn
* matplotlib
* Cython
* seaborn

* OpenCV (最新バージョン)
* Chainer & cupy (3系)
* pytorch (0.4.1)
* jupyter
* tensorflow (GPUバージョン)

## Jupyterを使いたい時
下のように実行してあげると使えるよ．ポートをしっかり設定してあげないと使えない．
```
docker run --runtime=nvidia -it -v {マウントしたいディレクトリ:/root} -p 8888:8888 --ipc=host --rm {imagename} jupyter notebook --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token= --notebook-dir='/root'
```
コマンドとオプションの説明
* run: コンテナを走らせる
* --runtime=nvidia: nvidia-docker (Ver2)でGPUを使用するコマンド
* -i コンテナにアタッチ
* -t 擬似ターミナルの割り当て
* -v {ローカルのディレクトリ:コンテナ内のマウント先}　ディレクトリのマウント
* -p ポートの解放
* --ipc IPC name space
* {imagename} ha618/original-contents:latest的な感じで REPOSITORY:TAG
* --rm コンテナからexitしたと同時にコンテナを削除するコマンド
* jupyter notebook jupyterの起動

それ以降はjupyterのオプション
