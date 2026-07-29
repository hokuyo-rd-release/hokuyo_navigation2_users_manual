= マッピング <sec-mapping>

「マッピング」は@sec-get-data で取得した rosbagをデシリアライズすることで3D点群地図(pcd)を作成することを指します。
本章ではマッピングのモードと操作手順について説明します。pcd を 2D占有格子地図(pgm) に変換する手順もマッピングの画面から操作しますが、これは手順の都合上、@sec-2d-map で説明します。

== マッピングモードの説明
マッピングボタンをクリックすると下記 `p2o, lio_raw, pcd2pgm` の3種類のモードが使用できます。
p2oに関しては、さらに3つのサブモードがあり、GNSSの受信状況に応じて使い分けます。\
/ `p2o`: グラフベース最適化を用いて3D点群地図を作成します。p2o には、下記3つのモードがあり、それぞれを使用するために、GNSSの受信状況に応じて使い分けます。
  rosbag をシリアライズして生データを解析するため高速に実行可能です。他のパラメータも地図作成コンフィグから設定可能です。詳細は、@sec-config と、@tab-bag-topics を参照して下さい。
  
  #text(size: 9pt)[
  - GNSS補正モード： RTK-GNSSのROSトピック `sensor_msgs/NavSatFix` の内、地図作成コンフィグで設定したGNSSの共分散の閾値以下の高精度な緯度・経度・高度データを抽出し、地図を作成します。
    デフォルトの地図作成モードです。使用するトピックは、@tab-bag-topics の地図作成コンフィグで指定された、 `nav_msgs/Odometry`, `sensor_msgs/PointCloud2, sensor_msgs/NavSatFix` の3種類です。地図作成コンフィグで `slam_mode` パラメータを `gravity` 以外の任意の文字列で設定した際に使用可能です。
  - IMU補正モード： IMUデータを用いてLIOを補正することで地図作成するモードです。 @sec-config で解説した地図作成コンフィグで `slam_mode` パラメータを `gravity` と設定することで使用可能です。
    使用するトピックは、@tab-bag-topics の `nav_msgs/Odometry, sensor_msgs/PointCloud2, sensor_msgs/Imu` の3種類です。
  - z軸0補正モード： gnssモードの内部の機能です。共分散値の閾値よりも小さい値のfixトピックが少ない、またはない場合、z軸を0として制約をかけて3D点群地図の鉛直方向の反りの軽減します。これはGNSSの共分散の閾値以下のfixトピックがパラメータ `fix_rate` %以下なら実行されます。
  ]

/ `lio_raw`: LIOを補正せず、3D点群をLIOの軌跡に沿って並べて地図を作るモードです。LIOは移動距離に応じて累積誤差が蓄積するため、目安として、100m以上直進する場合、進行方向に対して鉛直方向の反りが発生する可能性があります。例えば、GNSSが使用できない屋内環境等で、IMU補正モードと併用して活用してください。
  @sec-config の地図作成コンフィグで使用されるパラメータの内 `pointcloud_topic, lio_topic, pc_save_distance` はp2oと共用で, `orig_frame, target_frame` は本モード固有のパラメータです。\
/ `pcd2pgm`: p2o, lio_raw で生成した3D点群地図をpgm形式の2D占有格子地図に変換します。@sec-config の地図作成コンフィグで使用されるパラメータの内 `thre_z_min, thre_z_max, map_resolution, thres_point_count, flag_pass_through, thre_radius` を使用します。
  変換の際に使用するwaypointファイルを選択すると、waypointに沿って2D地図の経路上の静的障害物を除去することができます。詳細は @sec-2d-map で解説します。

== 3D地図の作成
以下、「p2o」モードを例として説明しますが、「lio_raw」モードでも操作は同じです。

+ @sub3 「マッピング」ボタンをクリックします。
+ @sub25 で「p2o」ボタンをクリックします。

#figure(
  grid(
    columns: (1fr, 1.2fr),
    gutter: 10pt,
    [#figure(image("img/25.png", width: 100%), caption: [マッピングモードの選択画面]) <sub25>],
    [#figure(image("img/26.png", width: 100%), caption: [rosbagの選択画面]) <sub26>],
  ),
  caption: [マッピングモードの選択画面],
) <im13>

+ @sub26 で地図作成に使用するrosbagファイルを選択し、「ディレクトリを選択」画面をクリックしてください。
+ @sub27 で作成する地図のファイル名を入力し、そのまま実行するか、もしくは、パラメータ設定ファイル(CSV)で作成したパラメータファイルを指定して「p2o マッピングを開始」をクリックすると処理が開始されます。#footnote[以前に作成した地図と同じ名前を入力した場合上書きされるため注意が必要です。]

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/27.png", width: 100%), caption: [地図作成実行画面]) <sub27>],
    [#figure(image("img/28.png", width: 100%), caption: [実行時のターミナル]) <sub28>],
  ),
  caption: [地図作成の様子],
) <im14>

+ @sub28 のように表示されたら実行が正常に完了しています。#footnote[実行時間はrosbagのサイズに依存しますが、およそ30秒 ～ 1分程度です。]
+ 実行後、@sub27 の画面が以下のように変わります。「3Dビューワで確認」ボタンをクリックすると、3D Viewer が起動します。
  3D地図・経路が自動で作成されているので、@sub30 の画面で「PCDファイル」と「ウェイポイントファイル」からファイルを選択し、「選択した要素をロード」ボタンをクリックすると
  3D Viewer でデータを確認することができます。

#figure(
  grid(
    columns: (1fr, 1.1fr),
    gutter: 10pt,
    [#figure(image("img/29.png", width: 100%), caption: [地図作成実行後の画面]) <sub29>],
    [#figure(image("img/30.png", width: 100%), caption: [3D Viewerで経路と地図を確認]) <sub30>],
  ),
  caption: [3D地図と経路の確認],
) <im15>

#figure(
  image("img/31.png", width: 95%),
  caption: [3D Viewer上で3D点群地図と経路を表示],
) <im16>

+ 実行完了後、@sub28 のターミナルと、@sub29 のブラウザタブは閉じて下さい。

=== p2o 地図の説明
p2o により作成された3D地図は、UTM座標系を基準座標が原点 `origin` となるように並行移動したものです。
基準座標とは、その計測エリアの基準となる中心点のことで、この中心点からの相対的なメートル差分として扱われます。
並行移動後の地図は、`origin` を原点しており、3D Viewer 上の `x` を東、`y` を北、`z` を鉛直上方としております。
p2o 実行後は、3D地図のみではなく、計測エリアの基準となる中心点と、緯度・経度・高度の初期位置、初期姿勢(UTM座標系の `x` 方向を(0, 0, 0, 1)としたクォータニオン)と初期位置が
`... ../hokuyo_navigation2/hokuyo_navigation2/data/<MAP_NAME>` に出力されます。

=== lio_raw 地図の説明
lio_rawにより作成された3D地図は、オドメトリ座標系を基にした3D地図です。センサの起動した位置を原点、その際の `x` 方向を初期姿勢(0, 0, 0, 1)とします。
センサ正面方向を `x`, センサから見て正面左方向を `y`、センサ正面から見て鉛直上方を `z` となります。
lio_raw実行後は、3D地図のみではなく、これらの初期位置、初期姿勢が `... ../hokuyo_navigation2/hokuyo_navigation2/data/<MAP_NAME>` にテキストとして出力されます。

#pagebreak()