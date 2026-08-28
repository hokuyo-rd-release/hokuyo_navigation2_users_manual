#import "utils.typ": *

= パッケージリファレンス <sec-appendix-packages>

本付録では、`hokuyo_navigation2` を構成する各リポジトリの詳細をまとめます。
通常の操作では読む必要はありませんが、
トラブルの原因を深く調べたい場合や、システムを拡張したい場合に参照してください。

#note[
  各リポジトリは Git のサブモジュールとして親リポジトリにまとめられています。
  親リポジトリを `--recursive` 付きでクローンすれば、すべてが一度に取得されます。
  取得に失敗した場合は @err-submodule を参照してください。
]

== リポジトリ一覧 <subsec-pkg-list>

親リポジトリ #tsuyo[`Hokuyo-aut/hokuyo_navigation2`] に、
@tab-pkg-submodules の 12 個のリポジトリがサブモジュールとして登録されています。
#tsuyo[ブランチが指定されているものは、そのブランチが取得されます。]

#figure(
  stable(
    columns: (auto, auto, auto),
    [*フォルダ名*], [*取得元*], [*ブランチ*],
    [`hokuyo_navigation2`], [`hokuyo-rd-release/hokuyo_navigation2`], [`jazzy`],
    [`hokuyo_navigation2_gui`], [`hokuyo-rd-release/hokuyo_navigation2_gui`], [既定],
    [`vizanti`], [`hokuyo-rd-release/vizanti`], [`release`],
    [`rosbridge_suite`], [`hokuyo-rd-release/rosbridge_suite`], [`jazzy`],
    [`hokuyo_slam_ros2`], [`hokuyo-rd-release/hokuyo_slam_ros2`], [既定],
    [`simple_fastlio_localization_ros2`], [`hokuyo-rd/simple_fastlio_localization_ros2`], [`release`],
    [`fix2xyz_packages_ros2`], [`hokuyo-rd-release/fix2xyz_packages_ros2`], [既定],
    [`lio_nav2_bringup`], [`hokuyo-rd-release/lio_nav2_bringup`], [`release`],
    [`waypoint_manager`], [`hokuyo-rd-release/waypoint_manager`], [既定],
    [`jsk_visualization`], [`hokuyo-rd-release/jsk_visualization`], [`jazzy`],
    [`nmea_msgs`], [`hokuyo-rd-release/nmea_msgs`], [`ros2`],
    [`doc/hokuyo_navigation2_`\ `users_manual`],
    [`hokuyo-rd-release/hokuyo_navigation2_users_manual`], [既定],
  ),
  caption: [サブモジュールとして登録されているリポジトリ],
) <tab-pkg-submodules>

#note[
  #dist-humble を使う場合、親リポジトリは `release` ブランチを取得します。
  そのときサブモジュールのブランチ指定も `release` 側の内容になります。
  上表は本書の #dist-jazzy 側（`jazzy` ブランチ）の登録内容です。
]

親リポジトリの外で、個別に導入するものが 2 つあります。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*名前*], [*取得元*], [*役割*],
    [`hokuyo_rsf`], [`Hokuyo-aut/hokuyo_rsf`],
    [RSF-X001 センサのドライバ。点群・IMU・GNSS・LIO を配信する。
     #tsuyo[これが無いとセンサからデータが取得できません]],
    [`icart_mini_driver_ros2`], [`hokuyo-rd-release/icart_mini_driver_ros2`],
    [サンプルのモータドライバ。`yp-spur` に依存します。
     別のモータドライバを使う場合は不要です（@subsec-setup-userdriver）],
  ),
  caption: [親リポジトリ外で導入するもの],
) <tab-pkg-external-repos>

=== サブモジュールの状態を確認する

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
git submodule status
```]

#console(title: "正常な場合の表示")[```
 a1b2c3d4... fix2xyz_packages_ros2 (heads/main)
 e5f6a7b8... hokuyo_navigation2 (heads/jazzy)
 ...
```]

#warn[
  行の先頭に `-`（マイナス）が付いているものは、
  #tsuyo[まだ取得されていません]。次のコマンドで取得してください。

  #terminal[```bash
git submodule update --init --recursive
```]
]

=== どのリポジトリがどの工程で使われるか

#figure(
  stable(
    columns: (auto, 1fr),
    [*工程*], [*主に動くリポジトリ*],
    [GUI の操作], [`hokuyo_navigation2_gui`、`vizanti`、`rosbridge_suite`],
    [データ取得], [`hokuyo_rsf`、`vizanti`、`icart_mini_driver_ros2`],
    [マッピング（p2o）], [`hokuyo_slam_ros2`、`hokuyo_navigation2`、`fix2xyz_packages_ros2`],
    [マッピング（lio_raw）], [`hokuyo_navigation2`],
    [2D 地図変換], [`hokuyo_navigation2`],
    [経路設計], [`hokuyo_navigation2_gui`（Map Viewer）],
    [自律走行（loc）],
    [`simple_fastlio_localization_ros2`、`lio_nav2_bringup`、`waypoint_manager`、
     `jsk_visualization`],
    [自律走行（gnss）],
    [`hokuyo_rsf`、`fix2xyz_packages_ros2`、`lio_nav2_bringup`、`waypoint_manager`、
     `jsk_visualization`],
  ),
  caption: [工程ごとに動くリポジトリ],
) <tab-pkg-by-stage>

#tip[
  エラーが出た工程が分かれば、
  この表から#tsuyo[疑うべきリポジトリ]を絞り込めます。
  たとえば `loc` モードでだけ走行できない場合は、
  `simple_fastlio_localization_ros2` の周辺が原因である可能性が高くなります。
]

== hokuyo_navigation2（本体） <subsec-pkg-core>

システム全体の中心となるパッケージです。
GUI から呼ばれるシェルスクリプト、Launch ファイル、設定ファイル、
および地図・経路・rosbag の保存場所を持ちます。

/ リポジトリ: `hokuyo-rd-release/hokuyo_navigation2`（ブランチ `release`）

=== ROS 2 ノード

#figure(
  stable(
    columns: (auto, 1fr),
    [*ノード*], [*役割*],
    [`gnss_lio_debug`],
    [GNSS の精度、自己位置の種類、LIO の更新頻度を RViz2 の画面に
     文字として重ねて表示します。色で状態を表します（@tab-gnss-color 〜 @tab-lio-color）],

    [`cmdvel_stopper`],
    [速度指令を中継する安全機能ノード。停止指令を受けたら速度をゼロに、
     減速指令を受けたら速度を制限してからモータドライバへ渡します],

    [`odom_to_tf`],
    [オドメトリのメッセージから TF を作って配信します。
     GNSS 切り替えモードで `map` → `base_link` を作るために使われます],

    [`pointcloud_transform_for_loc`],
    [自己位置推定用に点群を座標変換します。
     `simple_fastlio_localization` の入力を作るために使われます],
  ),
  caption: [`hokuyo_navigation2` のノード],
) <tab-pkg-core-nodes>

=== 主なスクリプト

#figure(
  stable(
    columns: (auto, 1fr),
    [*スクリプト*], [*役割*],
    [`scripts/start_server.sh`], [GUI サーバと Vizanti サーバを起動します],
    [`scripts/stop_server.sh`], [上記のサーバを停止します],
    [`scripts/start_getting_rosbag.sh`], [データ取得モードを開始します],
    [`scripts/start_mapping.sh`], [マッピング（`p2o` / `lio_raw` / `pcd2pgm`）を振り分けて起動します],
    [`scripts/start_navigation.sh`], [自律走行（単一／マルチ）を振り分けて起動します],
    [`scripts/setup_ros_env.sh`], [ワークスペースの位置を自動判定し、ROS 2 環境を読み込みます],
    [`scripts/coordinator.sh`], [GUI を使わず、端末のメニューから操作するための統合スクリプト],
    [`scripts/mapping/hokuyo_slam.bash`], [`p2o` による 3D 地図作成の本体処理],
    [`scripts/mapping/lio_raw.bash`], [`lio_raw` による 3D 地図作成の本体処理],
    [`scripts/mapping/pcd2pgm.bash`], [3D 点群地図を 2D 占有格子地図に変換する処理],
    [`scripts/navigation/nav_common.sh`], [走行スクリプトの共通関数（設定読み込み、初期位置、起動処理）],
    [`scripts/navigation/nav_single_map.sh`], [単一マップ走行],
    [`scripts/navigation/nav_multi_map.sh`], [マルチマップ走行],
    [`scripts/ctrl/web_kill_all_rosnode.sh`], [GUI の #btn[ロボット停止] から呼ばれる緊急停止],
    [`scripts/ctrl/multi_map_kill.sh`], [マルチマップ走行の地図切り替え時にノードを終了します],
  ),
  caption: [`hokuyo_navigation2` の主なスクリプト],
) <tab-pkg-core-scripts>

#warn[
  本パッケージはサンプルとして、モータドライバに `icart_mini_driver_ros2` を使う構成になっています。
  別のモータドライバを使用する場合は、
  #path[scripts/navigation/nav_common.sh] の `launch_motor_driver` 関数を
  ご使用のドライバの起動コマンドに書き換え、
  `hokuyo_navigation2` を再ビルドしてください。
]

=== 端末から操作する（coordinator）

GUI を使わずに、端末のメニューから操作することもできます。
#tsuyo[ただし、経路の編集機能はありません。]経路の編集は GUI の Map Viewer で行ってください。

#terminal[```bash
ros2 run hokuyo_navigation2 coordinator.sh
```]

#figure(
  image("img/repo_coordinator.png", width: 55%),
  caption: [`coordinator.sh` のメニュー画面],
) <im-coordinator>

選択できる項目は、`start_get_rosbag`（データ取得）、
`start_mapping`（地図作成・2D 変換）、`start_navigation`（自律走行）の 3 つです。

== hokuyo_navigation2_gui（GUI） <subsec-pkg-gui>

ブラウザ用の操作画面を提供する Flask 製のサーバです。
ボタン操作を受け取り、本体パッケージのシェルスクリプトを実行します。

/ リポジトリ: `hokuyo-rd-release/hokuyo_navigation2_gui`
/ 待ち受けポート: 5050（TCP）
/ 起動確認: 端末に `Flask Server starting at http://0.0.0.0:5050` と表示されること

#figure(
  stable(
    columns: (auto, 1fr),
    [*画面*], [*役割*],
    [メイン画面], [各機能への入口。現在のモードを表示します],
    [マッピング], [`p2o` / `lio_raw` / `pcd2pgm` の選択と実行],
    [自律走行], [走行モード・地図・経路の選択と実行（安全確認のチェック欄付き）],
    [ファイル管理], [地図・経路・設定ファイルの閲覧、名前変更、削除],
    [Map Viewer], [3D/2D 地図と経路の表示、経路の編集],
    [CSV エディタ], [マルチマップ走行のシナリオを表形式で編集],
    [テキストエディタ], [設定ファイルを文字として直接編集],
  ),
  caption: [GUI が提供する画面],
) <tab-pkg-gui-pages>

#note[
  GUI は #tsuyo[完了の目印となるファイル]を監視することで、
  マッピングなどの長い処理の終了を検知しています。
  そのため、処理を実行している端末側が異常終了すると、
  ブラウザは「処理中」の表示のまま止まります（@err-mapping-stuck）。
  ブラウザが止まって見えるときは、必ず端末側を確認してください。
]

=== 依存する Python パッケージ

#terminal[```bash
pip3 install flask flask-sockets gevent gevent-websocket websockets pyyaml
```]

== vizanti（ブラウザ上の可視化ツール） <subsec-pkg-vizanti>

ブラウザ上で ROS 2 のトピックを表示・操作するツールです。
本システムでは主に、#tsuyo[rosbag の記録]と
#tsuyo[バーチャルジョイスティックによる手動操作]に使用します。

/ リポジトリ: `hokuyo-rd-release/vizanti`（ブランチ `ATC_2025`）
/ 使用ポート: 5000, 5001（TCP）
/ 起動コマンド: `ros2 launch vizanti_server vizanti_server.launch.py`

#figure(
  stable(
    columns: (auto, 1fr),
    [*機能*], [*本書での使われ方*],
    [Bag Recorder], [センサデータを rosbag として記録する（@subsubsec-vizanti-bag）],
    [Teleop Joystick], [ロボットを手動で走らせる（@subsubsec-vizanti-teleop）],
    [Pose Tracker], [走行中の軌跡を表示し、LIO が動いているか確認する],
    [TF], [座標系の名前と親子関係を確認する（@subsubsec-vizanti-tf）],
    [Global Settings], [表示の基準フレームを決める（@subsubsec-vizanti-fixedframe）],
  ),
  caption: [本システムで使う Vizanti の機能],
) <tab-pkg-vizanti>

Vizanti には、上記のほかにも多数のウィジェットが用意されています。
@tab-pkg-vizanti-all に、＋ ボタンの「By Type」タブに並ぶものを示します。
#tsuyo[本システムの運用で必要なのは @tab-pkg-vizanti の 5 つだけ]で、
その他は追加しても構いませんが、動作の保証対象外です。

#figure(
  stable(
    columns: (auto, 1fr),
    [*ウィジェット*], [*内容*],
    [Grid], [基準フレームの原点を中心とした方眼],
    [TF], [座標系（フレーム）の階層],
    [Robot Model], [ロボットの見た目を表す画像],
    [Parameter Reconfigure], [ノードのパラメータを表示・編集する],
    [Bag Recorder], [rosbag を記録する],
    [Node Manager], [ノードを起動・停止する],
    [Folder], [ウィジェットをまとめる],
    [Topic Inspector], [トピックの中身を文字列で表示する],
    [Teleop Joystick], [`geometry_msgs/Twist` で速度指令を送る],
    [2D Pose Estimate], [初期位置（`initialpose`）を送る],
    [2D Nav Goal], [目標位置（`PoseStamped`）を送る],
    [Waypoint Mission], [経由点の列を送る],
    [Area Mission], [走行させたい領域を指定する],
    [Button], [任意のトピックを送るボタンを置く],
    [Pose Tracker], [`Odometry` の軌跡を矢印で描く],
    [Point Cloud], [点群を表示する#tsuyo[（本システムの点群には非対応）]。@err-viz-pointcloud],
    [Laser Scan], [2D の `LaserScan` を表示する],
    [Map / Grid Cells], [占有格子地図（`OccupancyGrid`）やセル集合を表示する],
    [Path / Pose / Pose Array], [経路や姿勢を表示する],
    [Marker Array], [`visualization_msgs` のマーカを表示する],
    [Satelite Tiles], [`NavSatFix` の位置に衛星写真を重ねる],
    [Compressed Image], [カメラ画像を表示する],
    [Attitude Indicator / Speedometer / Altimeter], [IMU・速度・高度の計器表示],
    [Battery / Temperature / Range], [各種センサの数値表示],
    [Rosbridge Client], [別の rosbridge サーバへの接続を追加する],
  ),
  caption: [Vizanti のウィジェット一覧（「By Type」タブ）],
) <tab-pkg-vizanti-all>

== rosbridge_suite（ブラウザと ROS の橋渡し） <subsec-pkg-rosbridge>

WebSocket を使って、ブラウザから ROS 2 のトピックを読み書きできるようにする中継役です。
`vizanti` が内部で使用します。利用者が直接操作することはありません。

/ リポジトリ: `hokuyo-rd-release/rosbridge_suite`（ブランチ `jazzy`）
/ 使用ポート: 9090（TCP）

#warn[
  #tsuyo[このパッケージは、使用する ROS ディストリビューションに合った
  ブランチを使ってください。]
  #dist-jazzy では `jazzy`、#dist-humble では `humble` です。\
  合っていないブランチのままビルドすると、`rosapi` ノードが起動直後に停止し、
  Vizanti のトピック一覧がすべて空になります。
  こうなると rosbag の記録もジョイスティックの設定もできません。
  症状と直し方は @err-vizanti-rosapi を参照してください。
]

#note[
  Vizanti の端末に
  `WebSocketClosedError: Tried to write to a closed websocket`
  という警告が繰り返し出ることがありますが、
  これはブラウザのタブを閉じたときに出る#tsuyo[正常な警告]です。対処は不要です。
]

== hokuyo_slam_ros2（3D SLAM） <subsec-pkg-slam>

3D 点群地図を作るための中核となるライブラリと実行ファイルを提供します。
グラフ最適化アルゴリズム `p2o` を実装しています。

/ リポジトリ: `hokuyo-rd-release/hokuyo_slam_ros2`
/ 依存: PCL 1.14、PROJ 9.4、Eigen3、C++14

#figure(
  stable(
    columns: (auto, 1fr),
    [*実行ファイル*], [*役割*],
    [`run_p2o`], [位置のグラフを最適化し、ゆがみの少ない軌跡を求めます],
    [`rearrange_pointcloud`], [最適化後の軌跡に沿って点群を並べ直し、
     3D 点群地図と経路の下書きを出力します],
  ),
  caption: [`hokuyo_slam_ros2` の実行ファイル],
) <tab-pkg-slam>

#danger[
  このパッケージは #tsuyo[`colcon build` では作られません]。
  `cmake` を使って個別にビルドする必要があります。
  ビルドを忘れると、マッピング実行時に
  「エラー: 'run_p2o' 実行ファイルが見つかりませんでした。」と表示されます（@err-no-runp2o）。

  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
mkdir -p build
cmake -Bbuild . && cmake --build build
```]
]

== simple_fastlio_localization（自己位置推定） <subsec-pkg-loc>

作成済みの 3D 点群地図と、現在センサが見ている点群を照合し、
地図上での自分の位置を求めます。`loc` モードの走行で使われます。

/ リポジトリ: `hokuyo-rd/simple_fastlio_localization_ros2`（ブランチ `release`）
/ ノード: `localization_node`

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*パラメータ*], [*本システムでの値*], [*意味*],
    [`map_file`], [`map/<地図名>.pcd`], [照合に使う 3D 点群地図（必須）],
    [`initial_pose`], [`data/<地図名>/init_pose.txt` の値], [初期位置と姿勢],
    [`frames_accumulate`], [4], [照合のために貯める点群のフレーム数],
    [`publish_2d_pose`], [true], [Nav2 用に `map` → `odom` の変換を配信する],
    [`visualize_registration_result`], [true], [照合の成否に応じて点群の色を変える],
    [`enable_lio_only_update`], [true], [照合が行われない間も LIO で位置を更新し続ける],
    [`asynchronous_registration`], [false], [非同期照合。処理が重くなるため無効を推奨],
  ),
  caption: [`localization_node` の主なパラメータ],
) <tab-pkg-loc-params>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*トピック*], [*方向*], [*内容*],
    [`/Odometry`], [入力], [LIO のオドメトリ（本システムでは `/rsf/lio_imu_rate_odom`）],
    [`/cloud_registered`], [入力], [LIO 座標系の点群（本システムでは `/rsf/aligned`）],
    [`/estimated_pose`], [出力], [地図座標系での推定位置],
    [`/map_cloud`], [出力], [読み込んだ 3D 点群地図],
    [`/tf`], [出力], [`map` → `odom` の座標変換],
  ),
  caption: [`localization_node` の主なトピック],
) <tab-pkg-loc-topics>

== lio_nav2_bringup（Nav2 の起動設定） <subsec-pkg-nav2>

ROS 2 の自律走行スタック Nav2 を、本システムの構成で動かすための起動設定一式です。
標準の Nav2 から `amcl`（2D の自己位置推定）を取り除き、
代わりに `simple_fastlio_localization` の結果を使う構成になっています。

/ リポジトリ: `hokuyo-rd-release/lio_nav2_bringup`（ブランチ `release`）
/ 起動ファイル: `navigation_launch.py`

#figure(
  stable(
    columns: (auto, 1fr),
    [*前提条件*], [*内容*],
    [地図の原点], [2D 地図と 3D 地図の原点が一致していること],
    [`map` → `lio_odom`], [3 次元での位置姿勢],
    [`map` → `odom`], [上記を平面に投影したもの（Nav2 が使用）],
    [`base_link`], [RSF（LiDAR）の位置と一致させる],
    [オドメトリ], [#tsuyo[LIO のみ]。車輪オドメトリは使用しません（@subsec-tf）],
  ),
  caption: [`lio_nav2_bringup` の前提となる座標系],
) <tab-pkg-nav2-frames>

本システムでは、走行モードに応じて 2 つのパラメータファイルを使い分けます。

#figure(
  stable(
    columns: (auto, 1fr),
    [*走行モード*], [*パラメータファイル*],
    [`loc`（LIO）], [`config/nav2/nav2_params.yaml`],
    [`gnss`（GNSS 切り替え）], [`config/nav2/nav2_gnss_switch_params.yaml`],
  ),
  caption: [走行モードとパラメータファイル],
) <tab-pkg-nav2-params>

== waypoint_manager（経路の追従） <subsec-pkg-wp>

経路ファイル（`.json`）を読み込み、Nav2 に目標地点を 1 つずつ送るノードです。

/ リポジトリ: `hokuyo-rd-release/waypoint_manager`
/ 実行: `ros2 run waypoint_manager waypoint_manager <経路名>.json [--once]`

#note[
  `--once` を付けると、最後の地点で終了します。付けない場合は先頭に戻って周回します。\
  本システムでは、#tsuyo[単一マップ走行では周回、マルチマップ走行では `--once`]
  で実行されます。マルチマップでは各地図を 1 周したら次の地図へ進むためです。
]

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*パラメータ*], [*既定値*], [*意味*],
    [`use_gnss_switch`], [`False`], [GNSS/LIO の切り替えが安定するまで待つ機能を使うか],
    [`xy_goal_tolerance`], [0.25], [到着判定の距離許容誤差 [m]],
    [`yaw_goal_tolerance`], [0.25], [到着判定の角度許容誤差 [rad]],
    [`cmd_vel_topic`], [`/cmd_vel`], [速度指令のトピック名（本システムでは `wizurg/cmd_vel`）],
    [`original_speed`], [0.56], [`normal` 属性で復帰する速度 [m/s]],
    [`initialize_cmd_vel_linear_x`], [0.1], [初期化動作時の前進速度 [m/s]],
  ),
  caption: [`waypoint_manager` の主なパラメータ],
) <tab-pkg-wp-params>

=== 主な動作

+ 経路ファイルから地点と属性を読み込みます。
+ `use_gnss_switch` が有効な場合、自己位置の種類が「LIO (raw)」以外になるまで、
  微速で前進しながら待機します。
+ Nav2 に目標地点を順に送ります。
  到着判定は Nav2 の判定とは別に、地点ごとの許容誤差で独自に行います。
+ 地点を#tsuyo[通り過ぎたことを検知すると、自動的に次の地点へ切り替えます]。
+ 地点の属性（`normal` / `stop` / `slow`）に応じた指令を出します。

== fix2xyz_packages_ros2（座標変換） <subsec-pkg-fix2xyz>

GNSS の緯度・経度と、地図上の直交座標（XYZ）を相互に変換するツールです。

/ リポジトリ: `hokuyo-rd-release/fix2xyz_packages_ros2`

#figure(
  stable(
    columns: (auto, 1fr),
    [*パッケージ／ノード*], [*役割*],
    [`fix2xyz` / `fix2xyz_node`], [緯度経度から地図座標へ変換します],
    [`fix2xyz` / `xyz2fix_node`], [地図座標から緯度経度へ変換します],
    [`fix2xyz` / `fix_odom_to_fix_orient`], [位置に姿勢の情報を付けた独自メッセージを作ります],
    [`fix_msgs`], [`NavSatFix` に姿勢を加えた独自メッセージ `FixWithOrientation` を定義します],
  ),
  caption: [`fix2xyz_packages_ros2` の構成],
) <tab-pkg-fix2xyz>

変換の基準となる緯度経度は、地図ごとに保存された
#path[data/<地図名>/init_lat_lon_alt.txt] の値が使われます。
このファイルが無いと、緯度 35 度・経度 135 度という仮の値が使われるため、
GNSS モードの走行が正しく動きません（@err-init-pose）。

== jsk_visualization（RViz2 の表示プラグイン） <subsec-pkg-jsk>

RViz2 の画面に文字やグラフを重ねて表示するためのプラグイン集です。
本システムでは、`gnss_lio_debug` ノードが出す
GNSS の精度・自己位置の種類・LIO の更新頻度の表示に使われます。

/ リポジトリ: `hokuyo-rd-release/jsk_visualization`

#note[
  このパッケージが無いと、RViz2 の画面に
  @tab-gnss-color 〜 @tab-lio-color の状態表示が出ません。
  走行そのものは可能ですが、#tsuyo[状態を目視で確認できなくなる]ため、
  必ず導入してください。
]

== nmea_msgs（GNSS のメッセージ定義） <subsec-pkg-nmea>

GNSS 受信機が出力する NMEA 文（`Gpgga` など）を ROS 2 で扱うためのメッセージ定義です。
データ取得時に記録するトピック `/gga` がこの型を使用します。

/ リポジトリ: `hokuyo-rd-release/nmea_msgs`（ブランチ `ros2`）

== 親リポジトリ外で導入するもの <subsec-pkg-external>

次の 2 つは親リポジトリのサブモジュールに含まれておらず、個別に導入します。

#figure(
  stable(
    columns: (auto, 1fr),
    [*パッケージ*], [*役割*],
    [`hokuyo_rsf`],
    [RSF センサの ROS 2 ドライバ。点群・IMU・GNSS・LIO のトピックを配信します。
     設定は #path[config/rsf_node_config.yaml] で行います],

    [`icart_mini_driver_ros2`],
    [サンプルのモータドライバ。`yp-spur` に依存します。
     別のロボットを使う場合は、これに代えてご使用のドライバを導入してください],
  ),
  caption: [個別に導入するパッケージ],
) <tab-pkg-external>

#pagebreak()
