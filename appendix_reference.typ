#import "utils.typ": *

= 設定・パラメータ早見表 <sec-appendix-ref>

本付録は、設定値やコマンドを調べるための一覧です。
各項目の意味の詳しい説明は @sec-config を参照してください。

== 地図作成コンフィグの全パラメータ <subsec-ref-mapping-params>

地図作成コンフィグ（既定では #path[config/hokuyo_slam_topics_cfg.csv]）の全項目です。
「既定値」は、コンフィグファイルが読み込めなかった場合にスクリプトが使う値です。

#danger[
  このファイルを編集するときは、#tsuyo[行の順序を絶対に変えないでください。]\
  スクリプトは項目名ではなく#tsuyo[上から何行目か]で値を読み取ります。
  行を入れ替えたり、途中の行を削除したりすると、
  まったく別の項目として解釈され、原因の分かりにくい不具合になります。
  値を変えたいときは、#tsuyo[2 列目の値だけ]を書き換えてください。
]

#figure(
  stable(
    columns: (auto, auto, auto, 1fr),
    [*行*], [*項目名*], [*既定値*], [*意味と使われる処理*],

    [1], [`gnss_topic`], [`/fix`],
    [GNSS のトピック名（p2o）],

    [2], [`pointcloud_topic`], [`/hokuyo3d/hokuyo_cloud2`],
    [点群のトピック名（p2o、lio_raw）],

    [3], [`lio_topic`], [`/rsf/lio_lidar_rate_odom`],
    [LIO のトピック名（p2o、lio_raw）],

    [4], [`run_lio`], [`true`],
    [本パッケージでは使用しません（拡張用）],

    [5], [`gnss_cov_thre`], [`0.1`],
    [GNSS を「精度が良い」と判定する共分散のしきい値。
     小さいほど厳しい（p2o）],

    [6], [`imu_topic`], [`/imu/data`],
    [IMU のトピック名（p2o の IMU 補正モード）],

    [7], [`slam_mode`], [`p2o`],
    [`gravity` にすると IMU 補正モード。
     それ以外の文字列なら GNSS 補正モード（p2o）],

    [8], [`pc_save_distance`], [`1.0`],
    [点群を地図に足し込む間隔 [m]。小さいほど密で重い地図になる],

    [9], [`wp_save_distance`], [`4.0`],
    [経路点を置く間隔 [m]],

    [10], [`gnss_min_movement_thre`], [`4.0`],
    [GNSS を採用する最小移動量 [m]（p2o）],

    [11], [`lio_min_movement_thre`], [`0.1`],
    [グラフの点を作る最小移動量 [m]。
     大きすぎると点が作られない（p2o）],

    [12], [`gravity_stride`], [`1`],
    [オドメトリの間引き間隔。指定回数に 1 個を使用（p2o）],

    [13], [`orig_frame`], [`yvt`],
    [センサ側の座標系名（lio_raw）],

    [14], [`target_frame`], [`lio_odom`],
    [地図の基準となる座標系名（lio_raw）],

    [15], [`thre_z_min`], [`-1.0`],
    [2D 化で使う点群の高さの下限 [m]。
     上げると地面が消える（pcd2pgm）],

    [16], [`thre_z_max`], [`20.0`],
    [2D 化で使う点群の高さの上限 [m]。
     下げると天井が消える（pcd2pgm）],

    [17], [`map_resolution`], [`0.05`],
    [2D 地図の解像度 [m/画素]（pcd2pgm）],

    [18], [`thres_point_count`], [`1`],
    [ノイズ判定の点数。大きいほどノイズに強いが、
     細い柱も消える（pcd2pgm）],

    [19], [`flag_pass_through`], [`False`],
    [特定の高さの点だけを抽出するか（pcd2pgm）],

    [20], [`thre_radius`], [`0.1`],
    [ノイズ判定の検索半径 [m]。大きいほど広く判定する（pcd2pgm）],

    [21], [`waypoint_tolerance`], [`1.0`],
    [経路の周囲を通行可能とする半径 [m]（pcd2pgm）],

    [22], [`fix_rate`], [`40`],
    [GNSS 補正を行う最低 fix 率 [%]。
     これを下回ると Z 軸拘束に切り替わる（p2o）],
  ),
  caption: [地図作成コンフィグの全パラメータ],
) <tab-ref-mapping-params>

#note[
  行番号は#tsuyo[見出し行を除いた順番]です。
  ファイルの 1 行目は `オプション,指定値,デフォルト値` という見出しで、
  ここは読み飛ばされます。
]

=== 症状から引くパラメータ

#figure(
  stable(
    columns: (1fr, auto, auto),
    [*こうしたい／こうなった*], [*変える項目*], [*方向*],
    [2D 地図に地面が写ってしまう], [`thre_z_min`], [上げる],
    [2D 地図に天井が写ってしまう], [`thre_z_max`], [下げる],
    [細い柱やポールが 2D 地図から消える], [`thres_point_count`], [下げる],
    [浮いたノイズが 2D 地図に残る], [`thre_radius`], [上げる],
    [経路上に障害物が残って通れない], [`waypoint_tolerance`], [上げる],
    [2D 地図を細かくしたい], [`map_resolution`], [下げる],
    [3D 地図が粗い], [`pc_save_distance`], [下げる],
    [3D 地図が重すぎる], [`pc_save_distance`], [上げる],
    [経路点が多すぎる], [`wp_save_distance`], [上げる],
    [fix 率が低いと警告が出る], [`gnss_cov_thre`], [上げる],
    [GNSS 補正を使いたくない], [`slam_mode`], [`gravity` にする],
  ),
  caption: [症状から引くパラメータ調整表],
) <tab-ref-param-symptom>

== シナリオファイル <subsec-ref-scenario>

マルチマップ走行で使う CSV です。1 行目の見出しは次の文字列と完全に一致させます。

#terminal[```csv
map_file,waypoint_file,nav_type,interval
```]

#figure(
  stable(
    columns: (auto, 1fr),
    [*列*], [*内容*],
    [`map_file`], [使用する地図の名前（拡張子なし）],
    [`waypoint_file`], [使用する経路の名前（拡張子なし）],
    [`nav_type`], [`loc`（3D 地図との照合）または `gnss`（GNSS 利用）],
    [`interval`], [次の地図に移るまでの待ち時間 [s]],
  ),
  caption: [シナリオファイルの列],
) <tab-ref-scenario>

#warn[
  カンマの前後に半角スペースを入れないでください。
  また、`nav_type` に `loc` `gnss` 以外を書くと
  「警告: 不明なナビゲーションタイプです」と表示され、`loc` として扱われます。
]

== 使用ポート一覧 <subsec-ref-ports>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ポート*], [*プロトコル*], [*用途*],
    [5000, 5001], [TCP], [Vizanti サーバ],
    [5050], [TCP], [GUI サーバ（ブラウザからのアクセス先）],
    [9090], [TCP], [rosbridge（ブラウザと ROS 2 の中継）],
    [10940], [TCP], [RSF センサとの通信],
    [7400--7800], [UDP], [ROS 2（DDS）のノード探索],
  ),
  caption: [使用ポート一覧（付録）],
) <tab-ref-ports>

#terminal[```bash
sudo ufw allow 5000,5001,5050,8000,9000,9090,10940/tcp
sudo ufw allow 7400:7800/udp
sudo ufw enable
sudo ufw status
```]

== RSF センサの設定 <subsec-ref-rsf>

#path[config/rsf_node_config.yaml] の主な項目です。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*項目*], [*既定値*], [*意味*],
    [`spel_ip_address`], [`192.168.0.100`], [RSF の IP アドレス],
    [`spel_port`], [`10940`], [RSF の通信ポート],
    [`nav_sat_fix_topic`], [`/fix`], [GNSS の配信トピック名],
    [`hokuyo_cloud2_topic`], [`/hokuyo3d/hokuyo_cloud2`], [点群の配信トピック名],
    [`imu_topic`], [`/hokuyo3d/imu`], [IMU の配信トピック名],
    [`lidar_rate_odom_topic`], [`/rsf/lio_lidar_rate_odom`], [LIO（LiDAR 周期）],
    [`imu_rate_odom_topic`], [`/rsf/lio_imu_rate_odom`], [LIO（IMU 周期）],
    [`switch_odom_type_topic`], [`/rsf/rsf_odom_type`], [自己位置の種類の通知],
    [`odom_frame`], [`lio_odom`], [LIO の座標系名],
    [`lidr_frame`], [`yvt`], [LiDAR の座標系名],
  ),
  caption: [RSF センサ設定の主な項目],
) <tab-ref-rsf>

#warn[
  RSF の IP アドレスを変更した場合は、この `spel_ip_address` も必ず合わせてください。
  合っていないとセンサのデータが一切届きません（@err-no-sensor）。
]

== 確認によく使うコマンド <subsec-ref-commands>

トラブルの切り分けで使うコマンドをまとめます。
すべて#tsuyo[読み取るだけ]のコマンドで、システムを変更することはありません。

#figure(
  stable(
    columns: (1fr, 1fr),
    [*調べたいこと*], [*コマンド*],
    [いま動いているノードの一覧], [`ros2 node list`],
    [いま流れているトピックの一覧], [`ros2 topic list`],
    [そのトピックの流れる速さ], [`ros2 topic hz <トピック名>`],
    [そのトピックの中身を 1 件], [`ros2 topic echo <トピック名> --once`],
    [座標系のつながり（図）], [`ros2 run rqt_tf_tree rqt_tf_tree`],
    [rosbag の中身], [`ros2 bag info <rosbagフォルダ>`],
    [自分のパソコンの IP アドレス], [`hostname -I`],
    [RSF に通信が届くか], [`ping 192.168.0.100`],
    [ディスクの空き容量], [`df -h ~`],
    [ファイアウォールの状態], [`sudo ufw status`],
  ),
  caption: [確認によく使うコマンド],
) <tab-ref-commands>

#tip[
  `ros2` で始まるコマンドを実行する前に、
  次の 2 行を実行して ROS 2 の環境を読み込んでおいてください。
  読み込んでいないと「コマンドが見つかりません」と表示されます。

  #terminal[```bash
source /opt/ros/humble/setup.bash
source ~/colcon_ws/install/setup.bash
```]
]

== 生成されるファイルの一覧 <subsec-ref-files>

各工程で作られるファイルです。バックアップを取るときの参考にしてください。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*工程*], [*場所*], [*ファイル*],
    [データ取得], [`rosbag/`], [`<名前>/`（`.db3` または `.mcap` と `metadata.yaml` を含むフォルダ）],
    [マッピング], [`map/`], [`<地図名>.pcd`（3D 点群地図）],
    [マッピング], [`waypoints/`], [`<地図名>.json`（経路の下書き）],
    [マッピング], [`data/<地図名>/`], [`init_pose.txt`、`init_lat_lon_alt.txt`（初期位置）],
    [マッピング], [`gnss_log/`], [`<地図名>_gnss_cov_<しきい値>.csv`（GNSS 品質の記録）],
    [2D 地図変換], [`map/`], [`<地図名>.pgm`、`<地図名>.yaml`（2D 地図）],
  ),
  caption: [各工程で生成されるファイル],
) <tab-ref-files>

#danger[
  地図を別のパソコンへ移すときは、
  #tsuyo[`map/` だけでなく `waypoints/` と `data/<地図名>/` も一緒に]コピーしてください。
  `data/` を忘れると初期位置が分からなくなり、自律走行が正しく始まりません（@err-init-pose）。
]

#pagebreak()
