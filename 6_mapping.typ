#import "utils.typ": *

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
+ 実行後、@sub27 の画面が以下のように変わります。「3Dビューアで確認」ボタンをクリックすると、3D Viewer が起動します。
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

=== 正常に終わったかの見分け方 <subsubsec-mapping-success>

マッピングは#tsuyo[失敗しても端末が赤くならない]ことがあります。
「終わったように見えて、実は地図が空」という状態を避けるため、
次の 3 点で必ず確認してください。

#fstep(1, [端末の最後の行を読む], [
  #tsuyo[完了フラグの作成メッセージが出ていれば、処理は最後まで進んでいます。]

  #console(title: "p2o が正常に完了したときの端末（実行例）")[```
run_p2o
step 1: res=0.239873, convergence_score=0.614554 time=0.001492s
step 2: res=2.28576, convergence_score=0.706754 time=0.004373s
（中略：数百行の step が流れます）
step 300: res=0.172192, convergence_score=0.881252 time=0.00087s
data/kato_support/output.p2o: 0.407209s
Processing topic (mcap): /hokuyo3d/hokuyo_cloud2
Saved 112 point cloud files (mcap).
  PointCloud Distance Filter: 1 m
  Waypoint Distance Filter: 4 m
結合した点群: 14 枚 / 112 枚中 (合計 38196 点)
PCDファイルを保存しました: kato_support_Acord.pcd
Waypointファイルを保存しました: .../waypoints/kato_support.json
点群の平行移動を開始します。
点群の平行移動を終了しました。
P2O SLAM completion flag created: .../map/kato_support.P2O_DONE
```]

  #console(title: "lio_raw が正常に完了したときの端末（実行例）")[```
LIO-RAW処理とPCDファイル抽出を開始します... (入力Bag: 2026-08-07-14-27-kato-support, 出力PCD: kato_support.pcd)
Config: PCD=/hokuyo3d/hokuyo_cloud2, ODOM=/rsf/lio_imu_rate_odom, TF=/dummy_tf
Config: Frames=yvt -> lio_odom
Found MCAP file: .../rosbag/2026-08-07-14-27-kato-support/..._0.mcap
Starting data processing...
  [Index 00000] Waypoint added at (-0.06, -0.01). Total: 1
  [Index 00255] Waypoint added at (3.97, -0.14). Total: 2
  [Index 00362] Waypoint added at (8.13, -0.12). Total: 3

--- Processing Finished ---
Total points saved: 30021 points.
✅ Saved map successfully to .../map/kato_support.pcd (Binary/Compressed format)
✅ Waypoints saved successfully to .../waypoints/kato_support.json
   Total waypoints: 3
Building package hokuyo_navigation2 to include new map files...
Summary: 1 package finished [0.59s]
LIO-RAW処理とPCDファイル抽出が完了しました。
```]

  #tsuyo[点の数と経路点の数を必ず見てください。]
  p2o では `結合した点群: N 枚 / M 枚中 (合計 ... 点)`、
  lio_raw では `Total points saved:` と `Total waypoints:` が該当します。
  #tsuyo[`0 枚` や `0 点` になっていれば、地図として使えません。]

  点の数は `pc_save_distance` の設定で変わります。
  少なすぎると感じたら値を小さくしてください（@tab-pcsave-density）。
])

#fstep(2, [ファイルの大きさを確認する], [
  #terminal[```bash
ls -lh ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/<地図名>.pcd
```]

  #tsuyo[数百 KB 未満のときは、ほぼ空の地図です。]
  数十メートル走った rosbag なら、通常は 1 MB 以上になります。
])

#fstep(3, [3D Viewer で目視する], [
  地図を読み込んで、走った経路の形になっているかを確認します。
  点がまばらだったり、同じ場所が二重にずれて写っていたりする場合は
  作り直しが必要です（@subsec-mapping-choose）。
])

#danger[
  #tsuyo[「完了しました」と表示されても、地図が空のことがあります。]

  たとえば、コンフィグで指定した `lio_topic` が rosbag に含まれていない場合、
  端末には次のように #tsuyo[途中に 1 行だけエラーが出た後、
  「完了しました」まで進んでしまいます]。

  #console(title: "見落としやすい失敗の例（lio_raw）")[```
Reading topics: ['/hokuyo3d/hokuyo_cloud2', '/rsf/lio_imu_rate_odom'] from bag...
Error: Odometry data not found. Cannot generate waypoints.
Building package hokuyo_navigation2 to include new map files...
Summary: 1 package finished [0.40s]
LIO-RAW処理とPCDファイル抽出が完了しました。
Creating completion flag file at: .../map/<地図名>.LIO_RAW_DONE
```]

  この場合、`.pcd` は作られません。
  対処は @err-lioraw-silent を参照してください。\
  #tsuyo[端末は最後の行だけでなく、上へさかのぼって
  `Error` の文字が無いか確認してください。]

  設定の誤りごとに何が起きるかは @tab-mapping-misconfig に、
  「コアダンプ」と表示されて強制終了する条件は @tab-mapping-coredump に
  一覧をまとめています。
]

#warn[
  #tsuyo[`Config:` から始まる行は必ず読んでください。]
  ここに表示されるトピック名とフレーム名が実際のデータと合っていないと、
  エラーが出ないまま空の地図ができます。
  確認方法は @subsubsec-config-checktopic と @subsubsec-config-checkframe を参照してください。
]

#tip[
  rosbag にどのトピックが入っているかは、次のコマンドで確認できます。
  コンフィグの `pointcloud_topic` と `lio_topic` が
  #tsuyo[`Count:` が 0 でない行]に含まれている必要があります。

  #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>
```]

  #console(title: "確認の表示例")[```
Topic information: Topic: /fix | Type: sensor_msgs/msg/NavSatFix | Count: 28 | ...
                   Topic: /hokuyo3d/hokuyo_cloud2 | Type: sensor_msgs/msg/PointCloud2 | Count: 537 | ...
                   Topic: /rsf/lio_lidar_rate_odom | Type: nav_msgs/msg/Odometry | Count: 536 | ...
```]
]

=== p2o 地図の説明
p2o により作成された3D地図は、UTM座標系を基準座標が原点 `origin` となるように並行移動したものです。
基準座標とは、その計測エリアの基準となる中心点のことで、この中心点からの相対的なメートル差分として扱われます。
並行移動後の地図は、`origin` を原点しており、3D Viewer 上の `x` を東、`y` を北、`z` を鉛直上方としております。
p2o 実行後は、3D地図のみではなく、計測エリアの基準となる中心点と、緯度・経度・高度の初期位置、初期姿勢(UTM座標系の `x` 方向を(0, 0, 0, 1)としたクォータニオン)と初期位置が
#path[~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/\<地図名\>/] に出力されます。

=== lio_raw 地図の説明
lio_rawにより作成された3D地図は、オドメトリ座標系を基にした3D地図です。センサの起動した位置を原点、その際の `x` 方向を初期姿勢(0, 0, 0, 1)とします。
センサ正面方向を `x`, センサから見て正面左方向を `y`、センサ正面から見て鉛直上方を `z` となります。
lio_raw実行後は、3D地図のみではなく、これらの初期位置、初期姿勢が #path[~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/\<地図名\>/] にテキストとして出力されます。

== モードの選び方 <subsec-mapping-choose>

どのモードで作ればよいか迷ったときは、@tab-mapping-choose を参考にしてください。

#figure(
  stable(
    columns: (1fr, auto, 1fr),
    [*環境*], [*モード*], [*設定*],

    [空の開けた屋外。RTK-GNSS が安定して受信できる],
    [`p2o`],
    [`slam_mode` を `gnss` など `gravity` 以外にする（既定）],

    [屋内、屋根の下、地下。GNSS がまったく使えない],
    [`p2o`],
    [`slam_mode` を `gravity` にして IMU 補正モードで作る],

    [GNSS も使えず、`p2o` でも失敗する。距離が短い],
    [`lio_raw`],
    [設定変更は不要。ただし長距離ではゆがみます],
  ),
  caption: [環境に応じたマッピングモードの選択],
) <tab-mapping-choose>

#tip[
  マッピングはロボットを動かさずに実行でき、#tsuyo[何度でもやり直せます]。
  同じ rosbag に対してモードやパラメータを変えて作り直し、
  3D Viewer で見比べて一番良いものを採用するのが確実です。\
  ただし、#tsuyo[同じ地図名を指定すると上書きされます]。
  比較したいときは別の名前を付けてください。
]

#warn[
  マッピング開始時、端末の先頭に#tsuyo[読み込まれた設定値の一覧]が表示されます。
  設定を変更したときは、ここが意図どおりになっているか必ず確認してください。
  `WARNING: Config file not found at ...` と出ている場合は、
  設定ファイルが読めておらず既定値で動いています（@err-csv-order）。
]

== GNSS の品質を確認する <subsec-mapping-gnsslog>

`p2o` を GNSS 補正モードで実行すると、
その rosbag に含まれる GNSS データの品質が CSV として出力されます。
「地図がゆがむ」「GNSS 補正が効いていない気がする」というときは、ここを確認してください。

/ 出力先: #path[~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/gnss_log/]
/ ファイル名: `<地図名>_gnss_cov_<gnss_cov_threの値>.csv`

このファイルには、#tsuyo[設定した精度のしきい値（`gnss_cov_thre`）を満たしたデータの割合（fix 率）]
が記録されています。

#note[
  マッピング実行時、この fix 率が地図作成コンフィグの `fix_rate` を下回ると、
  端末に次のように表示され、#tsuyo[GNSS 補正の代わりに高さを 0 に固定する補正]に切り替わります。
  処理は続行され、地図自体は作られます。

  #console(title: "fix 率が低いときの端末表示")[```
fix トピックの共分散のfix率が 12.5% です。gnss_cov_threの値を大きくしてください。
Fix率が低いため、Z軸拘束(擬似観測)を追加してSLAMを続行します。
```]

  対処方法は @err-fix-rate を参照してください。
]

=== CSV の中身の読み方 <subsubsec-gnsslog-read>

出力される CSV は、#tsuyo[先頭 4 行に要約]が、5 行目以降に個々の測定値が並ぶ形式です。
表計算ソフトで開くほか、端末でも確認できます。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/gnss_log
head -4 <地図名>_gnss_cov_0.01.csv
```]

#console(title: "GNSS 品質ログの先頭 4 行（実行例）")[```
北方向のfix率[%],東方向のfix率[%],鉛直方向のfix率[%]
92.8571428571,92.8571428571,0.0000000000
北方向のばらつきの平均[m],東方向のばらつきの平均[m],鉛直方向のばらつきの平均[m]
0.0061515357,0.0061515357,0.0984245714
```]

#figure(
  stable(
    columns: (auto, 1fr),
    [*行*], [*意味*],
    [1〜2 行目],
    [#tsuyo[fix 率]。`gnss_cov_thre` 以下の精度だった測定の割合［%］。
     このうち#tsuyo[いちばん左（北方向）の値]がコンフィグの `fix_rate` と比較されます],
    [3〜4 行目],
    [ばらつきの平均［m］。値が小さいほど精度が高いことを表します],
    [5 行目以降],
    [1 回ごとの測定のばらつき。細かく調べたいときに使います],
  ),
  caption: [GNSS 品質ログの構成],
) <tab-gnsslog-format>

#note[
  上の例では北方向の fix 率が `92.86%` で、
  コンフィグの `fix_rate`（既定 `30`）を上回っているため、
  #tsuyo[GNSS を使った補正で地図が作られます]。
  鉛直方向の fix 率が `0.00%` になっていますが、
  判定に使われるのは北方向の値のみのため問題ありません。
]

== うまくいかないときは <subsec-mapping-trouble>

#tip[
  端末に表示された文言から原因を引くための
  #tsuyo[逆引き表]を @subsec-msg-index に用意しています。
  エラーの文言が本節の一覧に無い場合は、そちらを参照してください。
]

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [`エラー: ... に数値として読めない値が指定されました` と出る], [@err-savedist-nan],
    [`Segmentation fault (core dumped)` と出て終了する], [@err-runp2o-segv],
    [`Topic '...' not found in bag file.` と出る], [@err-topic-pc],
    [`can't open file: data/<地図名>/center_utm.txt` と出る], [@err-topic-lio],
    [`Error (ROS 2): Topic '...' not found` と出て処理が始まらない], [@err-topic-gnss],
    [`No point clouds were saved ...` だけ出て地図ができない], [@err-frame-mismatch],
    [「'run_p2o' 実行ファイルが見つかりませんでした」と出る], [@err-no-runp2o],
    [「Path ... does not exist」と出て終了する], [@err-bag-notfound],
    [端末がすぐ閉じる／何も表示されない], [@err-mapping-nostart],
    [`ModuleNotFoundError` などが出る], [@err-py-module],
    [p2o を実行しても何も起こらずに終わる], [@err-p2o-nogo],
    [GNSS のエラーが出て `p2o 開始` に進まない], [@err-gnsslog-fail],
    [「can't open file: ... center_utm.txt」と出る], [@err-no-valid-gnss],
    [「output.p2o is empty」と出て止まる], [@err-p2o-empty],
    [「run_p2o optimization failed」と出て止まる], [@err-p2o-optfail],
    [「Skipping malformed log line」が大量に出る], [@err-concat-broken],
    [fix 率が低いという警告が出る], [@err-fix-rate],
    [地図の座標が現場とかけ離れている], [@err-utm-zone],
    [IMU 補正モードで「Topic not found or not PointCloud2」と出る], [@err-gravity-mcap],
    [IMU 補正モードで「IMU topic ... not found」と出る], [@err-gravity-topic],
    [`lio_raw` が「pcd_tf_extractor.py がエラーコード ...」で止まる], [@err-lioraw-fail],
    [`lio_raw` は成功したのに地図が空], [@err-lioraw-silent],
    [完了と表示されたのに地図ができていない], [@err-flag-only],
    [ブラウザが「処理中」のまま終わらない], [@err-mapping-stuck],
    [設定を変えたのに反映されない], [@err-csv-order],
    [処理の途中で端末が突然閉じる], [@err-oom],
    [以前に作った地図が消えた], [@err-map-overwrite],
  ),
  caption: [マッピングでよくある症状],
) <tab-mapping-trouble>

#pagebreak()