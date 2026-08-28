#import "utils.typ": *

= セットアップ <sec-setup>

本章では、`hokuyo_navigation2` を新しいパソコンに導入する手順を説明します。
すでに導入済みのロボットを操作するだけの方は、本章を読み飛ばして @sec-gui へ進んでください。

#plain[
  この章でやることは、大きく分けて次の 4 つです。

  + ROS 2 という土台のソフトウェアを入れる
  + `hokuyo_navigation2` のソースコードを取ってくる
  + 部品（ライブラリ）を入れて、ビルド（組み立て）する
  + 通信の通り道（ファイアウォールの穴）を開ける
]

#warn[
  本章の作業は#tsuyo[インターネットに接続されたパソコン]で行ってください。
  すべて終えるまでに、パソコンの性能にもよりますが#tsuyo[1〜3 時間程度]かかります。
  途中で中断しても、同じコマンドをもう一度実行すれば続きから進められます。
]

== 構成を選ぶ <subsec-setup-distro>

本ソフトウェアは、@tab-setup-distro に示す 2 つの構成に対応しています。
#tsuyo[どちらか一方を選び、本章では最後までその構成の手順だけをたどってください。]
2 つの手順を混ぜると、パッケージ名が食い違ってビルドに失敗します。

#figure(
  stable(
    columns: (auto, 1fr, 1fr),
    [*項目*], [*構成A*], [*構成B*],
    [OS], [`Ubuntu 22.04 LTS`], [`Ubuntu 24.04 LTS`],
    [ROS 2], [`Humble Hawksbill`], [`Jazzy Jalisco`],
    [Python], [3.10], [3.12],
    [取得するブランチ], [`release`（既定）], [`jazzy`],
    [apt パッケージの接頭辞], [`ros-humble-…`], [`ros-jazzy-…`],
    [`pip3` の追加オプション], [不要], [`--user --break-system-packages` が必須],
    [こんな方に], [既存の運用に合わせたい], [新規に導入する],
  ),
  caption: [対応する 2 つの構成],
) <tab-setup-distro>

#note[
  すでに ROS 2 が入っているパソコンでは、次のコマンドでどちらの構成かを確認できます。
  何も表示されない場合は、まだ ROS 2 が入っていません。

  #terminal[```bash
lsb_release -d       # Ubuntu のバージョン
echo $ROS_DISTRO     # humble または jazzy
```]
]

#danger[
  #tsuyo[1 台のパソコンに Humble と Jazzy を同時に入れないでください。]
  両方の `setup.bash` が `~/.bashrc` に書かれていると、
  ビルド時に別のバージョンのライブラリが混ざり、
  原因の分かりにくい実行時エラーが発生します（@err-distro-mix）。
]

== ROS 2 のインストール <subsec-setup-ros2>

=== リポジトリの登録

どちらの構成でも、まず ROS 2 の配布元をシステムに登録します。
次のコマンドは#tsuyo[両方の構成で共通]です。

#terminal[```bash
sudo apt update && sudo apt install -y curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
```]

=== 本体の導入

ここから構成ごとに分かれます。#tsuyo[自分の構成の枠だけ]を実行してください。

#humble[
  #terminal[```bash
sudo apt install -y ros-humble-desktop-full
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```]
]

#jazzy[
  #terminal[```bash
sudo apt install -y ros-jazzy-desktop
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```]

  #note[
    Jazzy では `desktop-full` に含まれる Gazebo Classic が廃止されています。
    本ソフトウェアは Gazebo を使用しないため、`ros-jazzy-desktop` で問題ありません。
  ]
]

=== 導入できたかの確認

2 つの端末を開き、それぞれで次を実行します。
片方に `Publishing:`、もう片方に `I heard:` が流れ続ければ成功です。
#kbd[Ctrl] + #kbd[C] で止めてください。

#terminal[```bash
# 端末 1
ros2 run demo_nodes_cpp talker
# 端末 2
ros2 run demo_nodes_cpp listener
```]

#console(title: "端末 2（listener）の表示例")[```
[INFO] [1730000000.123456789] [listener]: I heard: [Hello World: 1]
[INFO] [1730000001.123456789] [listener]: I heard: [Hello World: 2]
```]

#warn[
  何も表示されない場合は、ROS 2 のインストールか、
  端末で `source` を実行し忘れています。@err-ros-notfound を参照してください。
]

=== ビルドツールとワークスペース

#terminal[```bash
sudo apt install -y python3-rosdep python3-colcon-common-extensions git
sudo rosdep init
rosdep update
```]

#note[
  `sudo rosdep init` は、すでに実行済みの場合
  `ERROR: default sources list file already exists` と表示されますが、
  #tsuyo[問題ありません]。そのまま次へ進んでください。
]

作業用のフォルダ（ワークスペース）を作ります。
本書では以降 #path[~/colcon_ws] を使う前提で説明します。

#terminal[```bash
mkdir -p ~/colcon_ws/src
cd ~/colcon_ws
colcon build
echo "source $HOME/colcon_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```]

== ソースコードの取得 <subsec-setup-clone>

=== 補助ツールの導入

GUI から端末を開いたりウィンドウを操作したりするために、次のツールが必要です。
#tsuyo[この手順を飛ばすと、GUI のボタンを押しても何も起きません。]

#terminal[```bash
sudo apt-get install -y tree xdotool wmctrl zenity bc python3-pip
```]

=== リポジトリのクローン

`hokuyo_navigation2` は複数のリポジトリをまとめた構成のため、
#tsuyo[`--recursive` を必ず付けて]クローンしてください。

#humble[
  #terminal[```bash
cd ~/colcon_ws/src
git clone https://github.com/Hokuyo-aut/hokuyo_rsf.git
git clone --recursive https://github.com/Hokuyo-aut/hokuyo_navigation2.git
```]
]

#jazzy[
  #terminal[```bash
cd ~/colcon_ws/src
git clone https://github.com/Hokuyo-aut/hokuyo_rsf.git
git clone --recursive -b jazzy https://github.com/Hokuyo-aut/hokuyo_navigation2.git
```]
]

#warn[
  `--recursive` を付け忘れると、子リポジトリのフォルダが空のままになり、
  後のビルドが必ず失敗します。付け忘れた場合の復旧方法は @err-submodule を参照してください。
]

クローン後、各フォルダに中身が入っているか確認します。
#tsuyo[すべてに複数のファイルが表示されれば正常]です。
`total 0` と表示されるフォルダがあれば、サブモジュールが取得できていません。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
ls hokuyo_navigation2 hokuyo_navigation2_gui vizanti hokuyo_slam_ros2 \
   waypoint_manager lio_nav2_bringup simple_fastlio_localization_ros2 \
   fix2xyz_packages_ros2 jsk_visualization rosbridge_suite nmea_msgs
```]

=== 依存パッケージの解決

#terminal[```bash
cd ~/colcon_ws
rosdep update
rosdep install --from-paths src/hokuyo_navigation2 --ignore-src -r -y
```]

#note[
  この段階で次の 3 つのエラーが表示されますが、
  #tsuyo[いずれも想定どおりで、無視して先へ進んでかまいません]。
  理由は @tab-rosdep-errors のとおりです。

  #figure(
    stable(
      columns: (auto, 1fr),
      [*解決できないと言われるもの*], [*理由*],
      [`move_base_msgs`],
      [ROS 1 時代のパッケージで、本ソフトウェアでは使用しません],
      [`tf-transformations`],
      [この直後の手順で apt から個別に導入します],
      [`PROJ`],
      [`hokuyo_slam_ros2` のビルド手順でソースから導入します],
    ),
    caption: [`rosdep` が解決できない依存（無視してよいもの）],
  ) <tab-rosdep-errors>
]

続いて、`rosdep` が解決できなかったパッケージを個別に導入します。

#humble[
  #terminal[```bash
sudo apt-get install -y ros-humble-tf-transformations \
  ros-humble-joint-state-publisher ros-humble-robot-state-publisher \
  ros-humble-pointcloud-to-laserscan ros-humble-navigation2 ros-humble-nav2-bringup
```]
]

#jazzy[
  #terminal[```bash
sudo apt-get install -y ros-jazzy-tf-transformations \
  ros-jazzy-joint-state-publisher ros-jazzy-robot-state-publisher \
  ros-jazzy-pointcloud-to-laserscan ros-jazzy-navigation2 ros-jazzy-nav2-bringup
```]
]

== Python パッケージの導入 <subsec-setup-pip>

マッピングと GUI サーバは Python で動いており、@tab-pip-packages の主要なパッケージを使用します。

#figure(
  stable(
    columns: (auto, 1fr),
    [*パッケージ*], [*使いどころ*],
    [`open3d`], [点群の読み書き、2D 地図への変換],
    [`scipy`, `numpy`], [座標変換とフィルタ処理],
    [`pyproj`], [緯度経度と直交座標の相互変換],
    [`transforms3d`], [ウェイポイント抽出時の姿勢計算],
    [`Flask`, `Flask_Sockets`, `gevent`], [GUI サーバ本体],
    [`PyQt5`], [rosbag フィルタの画面],
    [`tqdm`], [処理の進捗表示],
  ),
  caption: [主な Python パッケージ],
) <tab-pip-packages>

#humble[
  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip3 install -r requirements.txt
```]
]

#jazzy[
  Ubuntu 24.04（Python 3.12）は #tsuyo[PEP 668] により「外部管理環境」となっており、
  オプションなしで `pip3 install` すると次のエラーで失敗します。

  #console(title: "オプションを付けずに実行した場合")[```
error: externally-managed-environment

× This environment is externally managed
```]

  次のように `--user --break-system-packages` を付けて、
  ユーザ環境（#path[~/.local]）へ導入してください。

  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip3 install --user --break-system-packages -r requirements.txt
```]

  導入先の #path[~/.local/bin] に PATH が通っていない場合は追加します。

  #terminal[```bash
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```]
]

#tip[
  導入できたかは、次のコマンドで確認できます。
  エラーが出ず、バージョン番号が表示されれば成功です。

  #terminal[```bash
python3 -c "import open3d, scipy, numpy, pyproj, transforms3d; print('OK')"
```]

  失敗する場合は @err-py-module を参照してください。
]

== モータドライバの導入 <subsec-setup-motor>

本ソフトウェアは、サンプルとして `icart_mini_driver_ros2`（`yp-spur` に依存）を使用します。
#tsuyo[お使いのロボットが別のモータドライバを使う場合、この節は読み飛ばし、
@subsec-setup-userdriver を参照してください。]

=== yp-spur

#terminal[```bash
sudo apt-get install -y libmodbus-dev
mkdir -p ~/hokuyo_lib && cd ~/hokuyo_lib
git clone https://github.com/hokuyo-rd-release/yp-spur.git
cd yp-spur && mkdir -p build && cd build
cmake .. && make
sudo make install
```]

導入できたかは、次の 2 つの端末で確認します。

#terminal[```bash
# 端末 1（<...> は実際のパラメータファイルのパスに置き換える）
ypspur-coordinator -d /dev/ttyUSB0 --blvr -p <PATH_TO_PARAM>/wizurg_lio.param

# 端末 2
cd ~/hokuyo_lib/yp-spur/build/sample
./run-test
```]

#warn[
  `/dev/ttyUSB0` を開けないというエラーが出る場合は、
  シリアルポートへのアクセス権限がありません。
  次を実行し、#tsuyo[いったんログアウトして入り直して]ください（@err-serial-perm）。

  #terminal[```bash
sudo usermod -aG dialout $USER
```]
]

=== icart_mini_driver_ros2

#terminal[```bash
cd ~/colcon_ws/src
git clone https://github.com/hokuyo-rd-release/icart_mini_driver_ros2.git
cd ~/colcon_ws
colcon build --symlink-install --packages-select icart_mini_driver
```]

== 3D SLAM（hokuyo_slam_ros2）のビルド <subsec-setup-slam>

#danger[
  `hokuyo_slam_ros2` は #tsuyo[`colcon build` では作られません]。
  本節のように `cmake` で個別にビルドする必要があります。
  この手順を飛ばすと、マッピング実行時に
  「エラー: 'run_p2o' 実行ファイルが見つかりませんでした。」と表示されます（@err-no-runp2o）。
]

=== ビルドに必要なライブラリ

#terminal[```bash
sudo apt-get install -y libsqlite3-dev sqlite3 libeigen3-dev \
  qtbase5-dev clang qtcreator libqt5x11extras5-dev
```]

=== PROJ

#humble[
  Ubuntu 22.04 の apt に含まれる PROJ で動作します。

  #terminal[```bash
sudo apt-get install -y libproj-dev proj-bin
```]
]

#jazzy[
  Ubuntu 24.04 の apt には PROJ 9.4.0 しかなく、
  本ソフトウェアは #tsuyo[9.4.1 以降]を必要とします。ソースから導入してください。

  #terminal[```bash
cd ~/hokuyo_lib
wget https://download.osgeo.org/proj/proj-9.4.1.tar.gz
tar -zxvf proj-9.4.1.tar.gz
cd proj-9.4.1 && mkdir -p build && cd build
cmake ..
cmake --build .
sudo cmake --build . --target install
```]
]

=== PCL

#jazzy[
  Ubuntu 24.04 の apt には PCL 1.14.0 しかないため、
  1.14.1 をソースからビルドして #path[/opt/pcl] へ導入します。

  #terminal[```bash
cd ~/hokuyo_lib
wget https://github.com/PointCloudLibrary/pcl/releases/download/pcl-1.14.1/source.tar.gz \
  -O pcl.tar.gz
tar -xvf pcl.tar.gz
cd pcl
cmake -Bbuild -DCMAKE_INSTALL_PREFIX=/opt/pcl .
cmake --build build
sudo cmake --install build
```]
]

#humble[
  Ubuntu 22.04 では apt の PCL で動作します。

  #terminal[```bash
sudo apt-get install -y libpcl-dev
```]
]

#warn[
  PCL のビルドは、パソコンの性能によっては#tsuyo[30 分以上かかります]。
  画面が止まったように見えても、完了するまでお待ちください。
  失敗する場合は @err-build-pcl を参照してください。
]

=== 本体のビルド

#jazzy[
  #terminal[```bash
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
echo 'export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl' >> ~/.bashrc
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
cmake -Bbuild . && cmake --build build
```]
]

#humble[
  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
cmake -Bbuild . && cmake --build build
```]
]

ビルドが成功すると、#path[hokuyo_slam_ros2/build/] に
`run_p2o`、`rearrange_pointcloud`、`p2o_viewer` の 3 つが作られます。

#terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2/build/ \
  | grep -e run_p2o -e rearrange_pointcloud
```]

== ワークスペース全体のビルド <subsec-setup-build>

=== 作業用フォルダの作成

地図・rosbag・経路の保存先を先に作っておきます。
#tsuyo[この手順を飛ばすと、GUI のファイル一覧が空のままになります。]

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
mkdir -p map rosbag waypoints data gnss_log
```]

=== ビルド

#terminal[```bash
cd ~/colcon_ws
colcon build
colcon build --symlink-install --packages-select \
  hokuyo_navigation2 lio_nav2_bringup simple_fastlio_localization
source ~/colcon_ws/install/setup.bash
```]

#note[
  2 回に分けているのには理由があります。
  1 回目でメッセージ定義などを含む全パッケージを作り、
  2 回目で#tsuyo[頻繁に書き換える 3 つ]を `--symlink-install` で作り直しています。
  `--symlink-install` を付けると、設定ファイルやスクリプトを編集したときに
  再ビルドしなくても変更が反映されます。
]

=== スクリプトへの実行権限

#tsuyo[この手順を飛ばすと、GUI のボタンを押しても何も起きません。]

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
chmod +x scripts/*.sh scripts/*/*.sh scripts/mapping/*.bash src/*.py
```]

== ファイアウォールの設定 <subsec-setup-firewall>

GUI とセンサの通信に必要なポートを開放します。
詳細な一覧は @tab-used-ports を参照してください。

#terminal[```bash
sudo ufw allow 5000,5001,5050,8000,9000,9090,10940/tcp
sudo ufw allow 7400:7800/udp
sudo ufw enable
sudo ufw status
```]

#warn[
  RSF センサとの通信ポートは #tsuyo[10940] です。
  設定ファイル #path[config/rsf_node_config.yaml] の `spel_port` の値と
  必ず一致させてください。
]

== セットアップの確認 <subsec-setup-verify>

インストールが正しく完了したか、次の 4 点で確認してください。
#tsuyo[1 つでも失敗する場合は、先に進まずに対処してください。]

#fstep(1, [3D SLAM の実行ファイルができているか], [
  #terminal[```bash
find ~/colcon_ws -name run_p2o -type f
```]
  パスが 1 行以上表示されれば成功です。
  何も表示されない場合は @err-no-runp2o を参照してください。
])
#fstep(2, [必要なフォルダができているか], [
  #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/
```]
  `map`、`waypoints`、`rosbag`、`config`、`scripts`、`data` が表示されれば成功です。
])
#fstep(3, [ROS 2 パッケージが認識されているか], [
  #terminal[```bash
source ~/colcon_ws/install/setup.bash
ros2 pkg list | grep -e hokuyo -e waypoint -e vizanti -e lio_nav2 -e fix2xyz
```]

  #console(title: "正常時の表示")[```
fix2xyz
hokuyo_navigation2
hokuyo_rsf
lio_nav2_bringup
simple_fastlio_localization
vizanti_server
waypoint_manager
```]

  表示されない場合は @err-build-fail を参照してください。
])
#fstep(4, [Python パッケージが揃っているか], [
  #terminal[```bash
python3 -c "import open3d, scipy, numpy, pyproj, transforms3d; print('OK')"
```]
  `OK` と表示されれば成功です。@err-py-module も参照してください。
])

== Docker でのセットアップ <subsec-setup-docker>

ビルド済みの環境をそのまま使いたい場合は、Docker イメージを利用できます。

/ 動作確認済み環境: Ubuntu 22.04 LTS / Ubuntu 24.04 LTS / WSL2

=== Docker の導入

#terminal[```bash
sudo apt-get install -y apt-transport-https ca-certificates curl \
  gnupg-agent software-properties-common
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```]

`sudo` なしで `docker` を使えるようにします。
#tsuyo[実行後はいったんログアウトして入り直してください。]

#terminal[```bash
sudo groupadd -f docker
sudo usermod -aG docker $USER
newgrp docker
```]

=== イメージのビルド

センサドライバのみのイメージを作る場合は `hokuyo_rsf`、
ナビゲーション一式のイメージを作る場合は `hokuyo_navigation2` の
#path[docker/] へ移動します。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/docker
docker build --network host -t hokuyo_navigation2:release .
```]

#note[
  `--network host` は、社内プロキシ環境などで発生する通信エラーを避けるためのものです。
  `-t` で指定した `hokuyo_navigation2:release` がイメージ名になります。
]

=== コンテナの作成と実行

#terminal[```bash
chmod +x run.bash
./run.bash -n hokuyo_navigation2 -s /path/to/your/ros2_ws
```]

#figure(
  stable(
    columns: (auto, 1fr),
    [*引数*], [*意味*],
    [`-n`], [使用する Docker イメージ名],
    [`-s`], [ホスト側と共有するディレクトリの#tsuyo[絶対パス]。
             ソースコードをホスト側で編集したい場合に指定します],
  ),
  caption: [`run.bash` の引数],
) <tab-docker-args>

コンテナから `exit` で抜けると、ホームディレクトリに
`<コンテナ名>.bash` が生成されます。
次回からはこのスクリプトを実行するだけでコンテナに入れます。

#terminal[```bash
cd ~
./hokuyo_navigation2.bash
```]

== お使いのモータドライバに合わせる <subsec-setup-userdriver>

本ソフトウェアは、モータドライバが#tsuyo[ROS 2 のトピックで速度指令を受け取る]ことを前提としています。
サンプルでは #path[scripts/navigation/nav_common.sh] の `launch_motor_driver` 関数から
`icart_mini_driver` を起動しています。
別のモータドライバを使う場合は、この関数の中身を書き換えてください。

#terminal[#text(size: 7.5pt)[
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
]]

#figure(
  stable(
    columns: (auto, 1fr),
    [*確認する項目*], [*内容*],
    [購読するトピック名],
    [既定は `wizurg/cmd_vel`（`geometry_msgs/Twist`）です。
     モータドライバ側の名前が違う場合は、
     #path[config/wizurg_opts/nav_opt_lio.csv] ではなく
     起動コマンドの `cmd_vel_topic` を合わせてください],
    [オドメトリ],
    [車輪オドメトリを使う場合は、`odom` → `base_link` の TF を
     モータドライバ側が出す構成に変更する必要があります（@subsec-tf）],
    [起動確認],
    [起動に時間がかかるドライバでは、関数内に待ち処理を追加してください],
  ),
  caption: [モータドライバ差し替え時の確認項目],
) <tab-userdriver>

書き換えたら、パッケージを作り直します。

#terminal[```bash
cd ~/colcon_ws
colcon build --symlink-install --packages-select hokuyo_navigation2
```]

== うまくいかないときは <subsec-setup-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [`ros2` コマンドが見つからない], [@err-ros-notfound],
    [`colcon build` が失敗する], [@err-build-fail],
    [`hokuyo_slam_ros2` のビルドが通らない], [@err-build-pcl],
    [サブモジュールのフォルダが空になっている], [@err-submodule],
    [`pip3 install` が `externally-managed-environment` で失敗する], [@err-pep668],
    [Python のパッケージが足りないと言われる], [@err-py-module],
    [シリアルポートを開けない], [@err-serial-perm],
    [Humble と Jazzy が混ざってしまった], [@err-distro-mix],
    [GUI サーバの起動時に Python のエラーが出る], [@err-server-py],
  ),
  caption: [セットアップでよくある症状],
) <tab-setup-trouble>

#pagebreak()
