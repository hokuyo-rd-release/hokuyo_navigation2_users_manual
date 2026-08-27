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

#capture-todo(
  "C-15",
  [`gnss_log/` に出力された CSV を開いた画面。fix 率の見方の説明に使用],
  height: 36mm,
)
#v(3pt)
#text(size: 8.5pt)[
  ※ 撮影待ちです。撮影依頼の詳細は @tab-capture-p3 を参照してください。
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