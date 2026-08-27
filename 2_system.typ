#import "utils.typ": *

= システム構成 <sec-system>

本章では、`hokuyo_navigation2` がどのようなソフトウェアの集まりでできているか、
また、地図作成から自律走行までの作業がどのような順序で進むかを説明します。

#plain[
  この章は「読まなくても操作はできる」章です。
  ただし、@sec-trouble のトラブルシューティングでは
  「どのプログラムが止まっているのか」を切り分けるために本章の用語を使います。
  エラーが出て困ったときに読み返せるよう、目印を付けておくことをおすすめします。
]

== システムの全体像 <subsec-overview>

`hokuyo_navigation2` は、RSF-X001（3D LiDAR と RTK-GNSS が一体になったセンサ。以下 RSF）1 台を中心に、
屋内・屋外の両方で自律走行を行うためのソフトウェア一式です。
ユーザは Web ブラウザの GUI だけを操作すればよく、
その裏側で複数の ROS 2 パッケージが連携して動作します。

#figure(
  image("img/sys_overview.png", width: 88%),
  caption: [`hokuyo_navigation2` で作成した 3D 点群地図と経路の例],
) <im-sys-overview>

システムは大きく次の 4 つの層に分かれます。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*層*], [*役割*], [*代表的なパッケージ*],
    [操作層],
    [ブラウザ上の GUI。ボタンを押すと下位層のスクリプトが起動する],
    [`hokuyo_navigation2_gui` \ `vizanti`],

    [制御・統合層],
    [シェルスクリプトと Launch ファイルで、各ノードの起動・停止・引数を管理する],
    [`hokuyo_navigation2`],

    [認識・推定層],
    [地図の作成、地図上での自己位置推定、座標変換を行う],
    [`hokuyo_slam_ros2` \ `simple_fastlio_localization` \ `fix2xyz_packages_ros2`],

    [走行制御層],
    [経路をたどり、モータドライバへ速度指令を出す],
    [`lio_nav2_bringup` (Nav2) \ `waypoint_manager`],
  ),
  caption: [システムの 4 層構造],
) <tab-layers>

== 作業の全体フロー <subsec-flow>

初めて現場で自律走行させるまでの手順は、必ず次の順序で進みます。
前の工程の出力が次の工程の入力になるため、順序を飛ばすことはできません。

#v(4pt)
#flow("① データ取得", "② マッピング", "③ 経路設計", "④ 2D地図変換", "⑤ 自律走行")
#v(6pt)

#figure(
  stable(
    columns: (auto, auto, 1fr, auto),
    [*工程*], [*章*], [*やること*], [*できあがるもの*],
    [① データ取得], [@sec-get-data],
    [ロボットを手動で走らせ、センサの生データを記録する],
    [rosbag],

    [② マッピング], [@sec-mapping],
    [rosbag から 3D 点群地図を作る（同時に経路の下書きもできる）],
    [`.pcd` \ `.json`],

    [③ 経路設計], [@sec-waypoint],
    [3D Viewer で経路（waypoint）を整える],
    [`.json`],

    [④ 2D 地図変換], [@sec-2d-map],
    [3D 点群地図を Nav2 が使う 2D 地図に変換する],
    [`.pgm` \ `.yaml`],

    [⑤ 自律走行], [@sec-navigation],
    [地図と経路を指定して自律走行させる],
    [走行],
  ),
  caption: [作業工程と成果物の対応],
) <tab-workflow>

#warn[
  ②〜④ で作られる 3D 地図（`.pcd`）・2D 地図（`.pgm`, `.yaml`）・経路（`.json`）は、
  #tsuyo[拡張子を除いたファイル名を一致させる]必要があります。
  例えば 3D 地図が `toyonaka.pcd` であれば、2D 地図は `toyonaka.pgm` と `toyonaka.yaml` にします。
  名前が食い違っていると、自律走行の起動時に地図が読み込めず失敗します（@err-map-name 参照）。
]

== リポジトリの構成 <subsec-repos>

`hokuyo_navigation2` は、複数のリポジトリを Git の #tsuyo[サブモジュール] としてまとめた構造になっています。
親リポジトリを `--recursive` 付きでクローンすると、@tab-repos の子リポジトリが同時に取得されます。

#terminal[```bash
git clone --recursive https://github.com/Hokuyo-aut/hokuyo_navigation2.git
```]

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*リポジトリ*], [*役割*], [*区分*],
    [`hokuyo_navigation2`],
    [本体。起動スクリプト、Launch ファイル、設定ファイル、
     地図・経路・rosbag の保存場所を持つ。GUI から呼ばれるシェルスクリプトはすべてここにある],
    [本体],

    [`hokuyo_navigation2_gui`],
    [ブラウザ用の GUI サーバ（Flask 製、ポート 5050）。ボタン操作を本体のスクリプト実行に橋渡しする],
    [GUI],

    [`vizanti`],
    [ブラウザ上で ROS トピックを可視化するツール。rosbag の記録とバーチャルジョイスティックによる手動操作に使う],
    [GUI],

    [`rosbridge_suite`],
    [WebSocket 経由でブラウザと ROS 2 をつなぐ中継役（ポート 9090）。`vizanti` が内部で使用する],
    [GUI],

    [`hokuyo_slam_ros2`],
    [3D SLAM の中核。グラフ最適化 `p2o` の実行ファイル `run_p2o` と、点群を並べ直す `rearrange_pointcloud` を提供する],
    [地図作成],

    [`simple_fastlio_localization_ros2`],
    [作成済みの 3D 点群地図と現在の点群を照合し、地図上での自分の位置を推定する],
    [自己位置推定],

    [`fix2xyz_packages_ros2`],
    [GNSS の緯度・経度（`NavSatFix`）と直交座標（XYZ）を相互変換する],
    [座標変換],

    [`lio_nav2_bringup`],
    [Nav2（ROS 2 の経路計画・障害物回避スタック）を、LIO ベースで動かすための起動設定一式],
    [走行制御],

    [`waypoint_manager`],
    [経路ファイル（`.json`）を読み、Nav2 に目標地点を 1 つずつ送るノード],
    [走行制御],

    [`jsk_visualization`],
    [RViz2 の追加表示プラグイン。画面上に GNSS 精度などの文字を重ねて表示するために使う],
    [表示],

    [`nmea_msgs`],
    [GNSS の NMEA 文（`Gpgga` など）を扱う ROS 2 メッセージ定義],
    [メッセージ],
  ),
  caption: [`hokuyo_navigation2` を構成するリポジトリ],
) <tab-repos>

#note[
  この他に、親リポジトリの外で個別に導入するものが 2 つあります。
  センサドライバの `hokuyo_rsf`（RSF 本体を動かす）と、
  サンプルのモータドライバ `icart_mini_driver_ros2`（`yp-spur` に依存）です。
  導入方法は @sec-setup を参照してください。
]

== データの流れ <subsec-dataflow>

センサから出たデータが、どのように地図・自己位置・速度指令へ変わっていくかを示します。

=== 地図作成のとき

#v(3pt)
#fstep(1, [RSF がデータを出す], [
  RSF のノード `hokuyo_rsf` が、点群（`/hokuyo3d/hokuyo_cloud2`）、IMU（`/hokuyo3d/imu`）、
  GNSS（`/fix`）、LiDAR 慣性オドメトリ＝LIO（`/rsf/lio_lidar_rate_odom`）を配信します。
])
#fstep(2, [rosbag に記録する], [
  `vizanti` の Bag Recorder が、上記のトピックをファイルに書き出します。
  ここまでが「データ取得」（@sec-get-data）です。
])
#fstep(3, [オフラインで地図にする], [
  記録した rosbag を読み直し、`p2o` または `lio_raw` で 3D 点群地図（`.pcd`）を作ります。
  同時に、走った軌跡から経路（`.json`）の下書きも出力されます。
])
#fstep(4, [2D 地図に落とす], [
  3D 点群地図のうち、指定した高さの範囲だけを平面に投影して `.pgm` と `.yaml` を作ります。
])

#note[
  ③ と ④ は #tsuyo[ロボットを走らせずに実行できます]。
  記録済みの rosbag さえあれば、机の上のパソコンだけで地図を作り直せます。
  パラメータを変えて何度も作り直せるのはこのためです。
]

=== 自律走行のとき

#v(3pt)
#fstep(1, [自分がどこにいるかを決める], [
  #tsuyo[LIO モード]（`nav_type` が `loc`）では、`simple_fastlio_localization` が
  現在の点群と 3D 点群地図を照合し、地図上の位置を求めます。\
  #tsuyo[GNSS モード]（`nav_type` が `gnss`）では、RSF が GNSS と LIO を切り替えながら出す位置を使います。
])
#fstep(2, [次に行く場所を決める], [
  `waypoint_manager` が経路ファイルを先頭から読み、Nav2 の `navigate_to_pose` アクションに
  目標地点を 1 つずつ送ります。
])
#fstep(3, [経路を計算する], [
  Nav2 が 2D 地図と現在位置から進む道筋を計算し、速度指令（`wizurg/cmd_vel`）を出します。
])
#fstep(4, [安全確認を通す], [
  `cmdvel_stopper` ノードが速度指令を中継します。停止指令が来ていれば速度をゼロにし、
  減速指令が来ていれば速度を制限してからモータドライバへ渡します。
])
#fstep(5, [モータが回る], [
  モータドライバが速度指令を受けて車輪を回します。
])

== 座標系（TF）の考え方 <subsec-tf>

ROS 2 では、「どの位置がどの基準から見た位置か」を #tsuyo[TF] という仕組みで管理します。
自律走行が正しく動くには、必要な座標系がすべてつながっている必要があります。

#figure(
  stable(
    columns: (auto, 1fr),
    [*座標系*], [*意味*],
    [`map`], [地図の原点。地図を作ったときの基準点],
    [`odom`], [LIO の 3 次元位置を平面に落とした座標系。Nav2 が使う],
    [`lio_odom`], [LIO（LiDAR 慣性オドメトリ）が出す 3 次元の座標系],
    [`base_link`], [ロボット本体。RSF（LiDAR）の位置と一致させている],
    [`yvt`], [RSF の LiDAR そのもののフレーム],
  ),
  caption: [主な座標系],
) <tab-frames>

必要なつながりは、走行モードによって異なります。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(
      image("img/frames_loc_ok.png", width: 100%),
      caption: [LIO モードで正常なとき。`map` → `odom` → `base_link` がつながっている],
    ) <sub-frames-ok>],
    [#figure(
      image("img/frames_gnss_switch.png", width: 100%),
      caption: [GNSS 切り替えモードのとき。`map` → `base_link` が直接つながる],
    ) <sub-frames-gnss>],
  ),
  caption: [走行モードごとの TF 構成],
) <im-frames>

#figure(
  image("img/frames_loc_ng.png", width: 62%),
  caption: [自己位置推定に失敗しているとき。`map` が他とつながっておらず、木が分断されている],
) <im-frames-ng>

#tip[
  TF がつながっているかどうかは、次のコマンドで図として確認できます。
  @im-frames-ng のように木が分断されていたら、自己位置推定が動いていません。
  対処は @err-tf-broken を参照してください。

  #terminal[```bash
ros2 run rqt_tf_tree rqt_tf_tree
```]
]

== 主要なトピック <subsec-topics>

トラブルの切り分けでは「そのトピックが流れているか」を調べるのが基本です。
確認によく使うトピックを @tab-topics に示します。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*トピック名*], [*メッセージ型*], [*内容*],
    [`/hokuyo3d/hokuyo_cloud2`], [`sensor_msgs/PointCloud2`], [RSF の 3D 点群],
    [`/hokuyo3d/imu`], [`sensor_msgs/Imu`], [RSF の IMU],
    [`/fix`], [`sensor_msgs/NavSatFix`], [GNSS の緯度・経度・高度と精度（共分散）],
    [`/gga`], [`nmea_msgs/Gpgga`], [GNSS の NMEA 文],
    [`/rsf/lio_lidar_rate_odom`], [`nav_msgs/Odometry`], [LIO の位置（LiDAR 周期）],
    [`/rsf/lio_imu_rate_odom`], [`nav_msgs/Odometry`], [LIO の位置（IMU 周期）],
    [`/rsf/rsf_odom_type`], [`std_msgs/String`], [いま GNSS と LIO のどちらを使っているか],
    [`/estimated_pose`], [`geometry_msgs/PoseStamped`], [地図上での推定位置],
    [`/map_cloud`], [`sensor_msgs/PointCloud2`], [読み込まれた 3D 点群地図],
    [`wizurg/cmd_vel`], [`geometry_msgs/Twist`], [ロボットへの速度指令],
    [`waypoints`], [`geometry_msgs/PoseArray`], [読み込まれた経路],
  ),
  caption: [確認に使う主要トピック],
) <tab-topics>

#tip[
  トピックが流れているかは次のコマンドで確認します。
  数値が表示され続ければ正常、`no new messages` のままなら止まっています。

  #terminal[```bash
# いま存在するトピックの一覧
ros2 topic list

# そのトピックが何 Hz で流れているか
ros2 topic hz /hokuyo3d/hokuyo_cloud2

# 中身を 1 件だけ見る
ros2 topic echo /fix --once
```]
]

== ファイルの置き場所 <subsec-dirs>

GUI から作成・選択するファイルは、すべて本体パッケージ配下の決まった場所に置かれます。
ファイルが「見つからない」系のエラーが出たときは、まずここを確認してください。

#terminal[```text
~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/
├── config/       設定ファイル (.csv, .yaml)
│   ├── hokuyo_slam_topics_cfg.csv   地図作成コンフィグ
│   ├── maps_and_waypoints.csv       シナリオファイル (マルチマップ走行)
│   ├── rsf_node_config.yaml         RSF センサの設定 (IP アドレス等)
│   ├── nav2/                        Nav2 のパラメータ
│   └── wizurg_opts/                 走行時の起動オプション
├── data/         地図ごとの初期位置情報 (自動生成)
│   └── <地図名>/init_pose.txt, init_lat_lon_alt.txt
├── map/          3D 点群地図 (.pcd) と 2D 地図 (.pgm, .yaml)
├── rosbag/       記録したセンサデータ
├── waypoints/    経路ファイル (.json)
└── scripts/      GUI から呼ばれるシェルスクリプト
```]

#danger[
  `map/`、`waypoints/`、`rosbag/`、`data/` の中身は、
  #tsuyo[実際に作った地図・経路そのもの]です。
  GUI の「ファイル管理」から削除すると元に戻せません。
  現場で使っている地図は、定期的に別の場所へコピーして保管してください。
]

#pagebreak()
