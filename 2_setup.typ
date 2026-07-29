#import "utils.typ": terminal

= セットアップ
本章では`hokuyo_navigation2`含めて全てのセットアップの方法について説明します。

== ROS 2のインストール
`Ubuntu 22.04 LTS` に `ROS 2 Humble Hawksbill` (以下、`humble`)をインストールする方法について説明します。
humble をインストールするには、以下の手順に従います。

humble のリポジトリを追加します。
#terminal[```bash
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
-o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```]

humble をインストールします。
#terminal[```bash
sudo apt update && sudo apt install ros-humble-desktop-full
```]

humble の環境をセットアップします。
#terminal[```bash
source /opt/ros/humble/setup.bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
```]

インストールの確認として動作テストを行います。
#terminal[```bash
# terminal 1
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
# terminal 2
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp listener
```]

環境設定を行います。
#terminal[```bash
sudo apt install python3-rosdep python3-colcon-common-extensions
sudo rosdep init
rosdep update
```]

Gazebo をインストールします。
#terminal[```bash
sudo apt-get install gazebo
sudo apt install ros-humble-gazebo-*
```]

rqt のプラグインをインストールします。
#terminal[```bash
sudo apt install ros-humble-rqt-*
```]

ビルドツールのインストールを行います。
#terminal[```bash
sudo apt install python3-colcon-common-extensions python3-rosdep
```]

ROS 2の初期設定を行います。
#terminal[```bash
sudo rosdep init 
rosdep update
```]

ROS 2ワークスペースの作成を行います。
#terminal[```bash
mkdir -p ~/colcon_ws/src
cd ~/colcon_ws
colcon build
```]

setup.bash をソースして、ROS 2の環境を有効にする設定を.bashrc に追加します。
#terminal[```bash
echo "source $HOME/colcon_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```]

== hokuyo_navigation2 のインストール
ここでは、ソースコードの取得とビルドについて説明します。また、Dockerにも対応しています。

=== ソースコードの取得とビルド
ターミナル操作を行うツールをインストールします。
#terminal[```bash
sudo apt-get install -y tree xdotool wmctrl zenity bc
```]

URDF依存パッケージをインストールします。
#terminal[```bash
sudo apt-get install ros-tf-transformations ros-humble-joint-state-publisher \
ros-humble-robot-state-publisher
```]

ROS2パッケージを取得します。
#terminal[```bash
cd ~/colcon_ws/src
git clone https://github.com/hokuyo_rsf.git
git clone --recursive https://github.com/Hokuyo-aut/hokuyo_navigation2.git
cd ~/colcon_ws
rosdep update
rosdep install -i --from-path src/hokuyo_navigation2 --ignore-src -r -y
colcon build --symlink-install
```]

pythonパッケージをインストールします。
#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip install -r requirements.txt
```]

サンプルを動作させるためのモータドライバをインストールします。
#terminal[```bash
# yp-spur をインストールします。
mkdir ~/hokuyo_lib
cd ~/hokuyo_lib
sudo apt-get install libmodbus-dev
git clone https://github.com/hokuyo-rd-release/yp-spur.git
cd yp-spur
mkdir build
cd build
cmake ..
make
sudo make install
# icart_mini_driver をインストールします。
cd ~/colcon_ws/src
git clone https://github.com/hokuyo-rd-release/icart_mini_driver_ros2.git
cd ~/colcon_ws
colcon build --symlink-install --packages-select icart_mini_driver
```]

hokuyo_slam_ros2 をインストールします。
#terminal[```bash
sudo apt-get install libsqlite3-dev sqlite3 libeigen3-dev qtbase5-dev clang qtcreator libqt5x11extras5-dev
# proj のインストール
cd ~/hokuyo_lib
wget https://download.osgeo.org/proj/proj-9.4.1.tar.gz
tar -xvf proj-9.4.1.tar.gz
cd proj-9.4.1
mkdir build
cd build
cmake ..
cmake --build . --target install
# pcl 1.14.1 ビルドに時間がかかります。
cd ~/hokuyo_lib
wget https://github.com/PointCloudLibrary/pcl/releases/download/pcl-1.14.1/source.tar.gz -O pcl.tar.gz
tar -xvf pcl.tar.gz
cd pcl
cmake -Bbuild -DCMAKE_INSTALL_PREFIX=/opt/pcl .
cmake --build build
sudo cmake --install build
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
# hokuyo_slam_ros2 のビルド
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
mkdir build
cmake -Bbuild . && cmake --build build
# colcon build
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
mkdir map/ rosbag/ waypoints/
cd ~/colcon_ws
colcon build
colcon build --symlink-install --packages-select hokuyo_navigation2 lio_nav2_bringup simple_fastlio_localization
```]

GUIを使用するためには、後述の「GUIサーバの起動」を行う前に、ファイアーウォールの設定でポート5050を開放する必要があります。
ファイアーウォールの設定の詳細は @sec-gui @tab-used-ports を参照してください。

=== Dockerでのセットアップ
Docker でのセットアップ方法について記載します。

/ 動作環境: Ubuntu 22.04 LTS, WSL2(Ubuntu 26.04 LTS)

Docker のインストールをします。

#terminal[```bash
# Ubuntu 24.04
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Ubuntu 26.04
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent \
software-properties-common
sudo chmod 0755 /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt install docker-ce docker-ce-cli containerd.io
```]

Docker コマンドの権限を取得します。

#terminal[```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```]

#terminal[```bash
# bash-completion
sudo apt-get install bash-completion
source /etc/bash_completion
rm /etc/apt/apt.conf.d/docker-clean
sudo apt-get update
```]

Dockerfileのクローン：hokuyo_rsf センサドライバのみビルド済みのイメージをビルドする場合、以下のリポジトリをクローンしDockerファイルがあるディレクトリへ移動します。
#terminal[```bash
cd <YOUR_ROS2_WS>
git clone https://github.com/Hokuyo-aut/hokuyo_rsf.git 
cd hokuyo_rsf/docker
```]

Dockerfileのクローン：ナビゲーションソフトウェアすべてビルド済みのイメージをビルドする場合、以下のリポジトリをクローンしDockerファイルがあるディレクトリへ移動します。
#terminal[```bash
cd <YOUR_ROS2_WS>
git clone https://github.com/hokuyo-rd-release/hokuyo_navigation2.git
cd hokuyo_navigation2/docker
```]

Dockerイメージのビルドを行います。提供されているDockerfile を使用してイメージを作成します。通信エラーを防ぐため
`--network host` オプションを付けて実行します。
#terminal[```bash
docker build --network host -t hokuyo_navigation2:release .
```]

/ ポイント: `-t` オプションでイメージ名(タグ)を`hokuyo_navigation2:release` として指定しています。(イメージ名は何でも構いませんが、以降のコマンドではこのイメージ名を使用します。)

コンテナの作成と実行を行います。作成したイメージを元にコンテナを起動します。このリポジトリには、
便利な起動用スクリプト`run.bash`が用意されています。
#terminal[```bash
chmod +x run.bash
./run.bash -n hokuyo_navigation2 -s /path/to/your/ros2_ws
```]

==== 引数の説明
/ `-n`: 使用するDockerイメージ名を指定します。\
/ `-s`: ホスト側のディレクトリをコンテナ内と共有するためのパス(絶対パス)を指定します。ソースコードの編集などをホスト側で行いたい場合に便利です。

コンテナ作成後は、exit してコンテナの外に出ると、homeディレクトリに`CONTAINER_NAME.bash` (`CONTAINER_NAME`は、自分で作成したコンテナの名前)が生成されます。
#terminal[```bash
cd
./CONTAINER_NAME.bash
```]
次回からは上記のスクリプトを実行すると自動でコンテナをスタートしてコンテナ内に入ることができます。

== ユーザ依存関連
上述のシステム構成において、お客様にてご準備頂くモータドライバの設定方法について説明します。
モータドライバはROS 2トピックで制御されることを前提としており、サンプルでは #link("https://github.com/hokuyo-rd-release/hokuyo_navigation2/blob/release/scripts/navigation/nav_common.sh")[こちらのシェルスクリプト `nav_common.sh`]
を通じてROS 2 モータドライバの起動コマンドを実行しております。`launch_motor_driver`関数で呼び出すモータのコマンドを変更して、`hokuyo_navigation2` パッケージを再度ビルドしてください。

#text(size: 7pt)[
```bash
# モータドライバを起動する関数
launch_motor_driver() {
    if [ "${use_motor_driver}" = "true" ]; then
        echo "モータドライバを起動します..."
        gnome-terminal -- bash -c "ros2 launch hokuyo_navigation2 icart_mini_drive_launch.xml; bash"
        echo "モータドライバ関連ノードの起動を待っています..."
        echo "モータドライバ関連ノードの起動を確認しました。"
    fi
}
```
]

#pagebreak()