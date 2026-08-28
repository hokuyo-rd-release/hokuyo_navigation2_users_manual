#import "utils.typ": *

= コンフィグファイルの設定 <sec-config>

コンフィグファイルは、地図作成等の動作に必要なパラメータを定義するためのファイルです。
コンフィグファイルの設定は、「地図作成」と「自律走行」の機能を使うために必要な手順です。
この操作は、@sub6 の「ファイル管理画面」から行います。地図作成を実行する際や、複数地図を切り替えて走行する際に、コンフィグファイルを選択して使用します。
コンフィグファイルは複数用意することができ、ユーザは必要に応じて適切なコンフィグファイルをGUIから選択して使用することができます。
コンフィグファイルの形式は、CSVで、以下の種類があります。
 
== 地図作成パラメータ用のコンフィグファイル
/ 地図作成コンフィグ: 地図作成・経路設計の動作に必要なパラメータを定義するためのファイルです。CSV形式で、各行にパラメータ名と値を定義します。#footnote[CSVファイル内に半角スペース（カンマの前後など）が含まれないように注意してください。正常に読み込まれない原因となります。]
  #path[~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts/mapping/] に保存されているシェルスクリプトが地図作成の実行時にこのコンフィグファイルを読み込んで#footnote[地図作成コンフィグファイルは、地図作成の実行時に読み込まれます。地図作成の実行前に、適切な値に設定して保存してください。地図作成の実行中にコンフィグファイルを編集しても、地図作成の動作には反映されません。]、
  1列目がパラメータ名、#tsuyo[2列目が実際に使われる値]、3列目は参考値です。設定を変えるときは #tsuyo[2列目だけ]を書き換えてください。#footnote[3列目の値は、あくまで参考値であり、実際の環境や使用するセンサに応じて適切な値に設定してください。例えば、`gnss_cov_thre`は、GNSSの受信状況や精度に応じて調整が必要です。]

出荷時のコンフィグファイル `config/hokuyo_slam_topics_cfg.csv` の内容を以下に示します。
左端の数字は#tsuyo[行番号]です。スクリプトはこの行番号で値を読み取るため、
編集するときはこの並び順そのものが重要になります。

#terminal[#text(size: 8pt)[
```csv
 1  オプション,指定値,デフォルト値
 2  gnss_topic,/fix,/fix
 3  pointcloud_topic,/hokuyo3d/hokuyo_cloud2,/hokuyo3d3/hokuyo_cloud2
 4  lio_topic,/rsf/lio_lidar_rate_odom,/hokuyo_lio/sync_odom
 5  run_lio,true,true
 6  gnss_cov_thre,0.01,0.01
 7  imu_topic,/hokuyo3d/imu
 8  slam_mode,gnss
 9  pc_save_distance,0.0
10  wp_save_distance,4.0
11  gnss_min_movement_thre,4.0
12  lio_min_movement_thre,0.1
13  gravity_stride,1
14  orig_frame,yvt,yvt
15  target_frame,lio_odom,lio_odom
16  thre_z_min,-0.2,-1.0
17  thre_z_max,2.0,20.0
18  map_resolution,0.05,0.05
19  thres_point_count,1,1
20  flag_pass_through,True,True
21  thre_radius,0.1,0.1
22  waypoint_tolerance,1.0,1.0
23  fix_rate,30,40
```
]]

#danger[
  このファイルを編集するときは、#tsuyo[行の順序を絶対に変えないでください。]\
  スクリプトはパラメータ名ではなく#tsuyo[上から何行目か]で値を読み取ります。
  行を入れ替えたり、使わない行を削除したりすると、
  以降の項目がすべて1つずつずれ、まったく別の設定として解釈されます。
  詳細と復旧方法は @err-csv-order を参照してください。
]

#note[
  1行目の見出し（`オプション,指定値,デフォルト値`）は読み飛ばされるため、
  文言そのものに意味はありません。ただし#tsuyo[削除はしないでください]。
  削除すると全体が1行ずれます。
]

=== パラメータ一覧 <subsubsec-config-paramlist>

@tab-config-params に全パラメータをまとめます。
「使う処理」の欄は、その値が#tsuyo[どの工程で読まれるか]を示します。
自分が使う工程のバッジが付いていない行は、値を変えても結果に影響しません。

#align(center, block(
  inset: (x: 10pt, y: 7pt), radius: 3pt, fill: luma(248), stroke: 0.5pt + luma(215),
  text(size: 9pt, grid(
    columns: (auto, auto),
    column-gutter: 16pt,
    row-gutter: 5pt,
    align: (right + horizon, left + horizon),
    tag-p2o,    [p2o（グラフ SLAM）で地図を作るときに読まれる],
    tag-lioraw, [lio_raw（LIO をそのまま使う）で地図を作るときに読まれる],
    tag-2d,     [3D 点群を 2D 地図（`.pgm`）に変換するときに読まれる],
    tag-gnss,   [GNSS による補正に関係する],
  )),
))

#figure(
  text(size: 8.5pt)[#paramtable(
    paramgroup("① どのデータを使うか（トピック名・フレーム名）"),
    [2], [`gnss_topic`], [`/fix`], [#tag-gnss #tag-p2o],
    [GNSS の位置トピック名。rosbag に実在する名前を書きます（@subsubsec-config-checktopic）],
    [3], [`pointcloud_topic`], [`/hokuyo3d/`\ `hokuyo_cloud2`], [#tag-p2o #tag-lioraw],
    [LiDAR の点群トピック名#footnote[`pointcloud_topic` と `lio_topic` の周期は同じ（例：共に 20 Hz）ものを指定してください。周期が異なる場合、地図作成の精度が低下する可能性があります。]。間違えると#tsuyo[空の地図]ができます（@err-topic-pc）],
    [4], [`lio_topic`], [`/rsf/`\ `lio_lidar_rate_odom`], [#tag-p2o #tag-lioraw],
    [LIO の自己位置（Odometry）トピック名。2 種類の違いは @tab-lio-topics],
    [7], [`imu_topic`], [`/hokuyo3d/imu`], [#tag-p2o],
    [IMU トピック名。`slam_mode` が `gravity` のときの姿勢補正に使います],
    [14], [`orig_frame`], [`yvt`], [#tag-lioraw],
    [LiDAR 側のフレーム名。センサ設定と一致させます（@tab-config-frame-map）],
    [15], [`target_frame`], [`lio_odom`], [#tag-lioraw],
    [LIO 側（基準）のフレーム名。間違えると#tsuyo[無言で空の地図]ができます（@err-frame-mismatch）],

    paramgroup("② 地図の作り方（モードと密度）"),
    [5], [`run_lio`], [`true`], [#tag-none],
    [本パッケージでは使いません。RSF 以外の LIO を扱うための拡張用の項目です],
    [8], [`slam_mode`], [`gnss`], [#tag-p2o],
    [`gravity` なら IMU だけで作図。#tsuyo[それ以外の文字列]なら GNSS 補正ありで作図],
    [9], [`pc_save_distance`], [`0.0`], [#tag-p2o #tag-lioraw],
    [点群を地図へ足し込む間隔［m］。#tsuyo[小さいほど密で重い地図]。`0` で間引きなし（@subsubsec-config-pcsave）],
    [10], [`wp_save_distance`], [`4.0`], [#tag-p2o #tag-lioraw],
    [経路点（waypoint）を置く間隔［m］。小さくすると経路点が増えます],
    [13], [`gravity_stride`], [`1`], [#tag-p2o],
    [自己位置を何個に 1 個使うかの間引き。`1` ですべて使用],

    paramgroup("③ GNSS を使うかどうかの判定"),
    [6], [`gnss_cov_thre`], [`0.01`], [#tag-gnss #tag-p2o],
    [GNSS を「精度が良い」とみなす分散の上限。小さいほど厳しく判定します],
    [23], [`fix_rate`], [`30`], [#tag-gnss #tag-p2o],
    [`gnss_cov_thre` を満たす GNSS の割合［%］の下限。これを下回ると GNSS 補正をあきらめ、高さ方向の反りを抑える補正に切り替わります],
    [11], [`gnss_min_movement_thre`], [`4.0`], [#tag-gnss #tag-p2o],
    [GNSS の点を採用する最小移動距離［m］。停止中のばらつきを捨てます],
    [12], [`lio_min_movement_thre`], [`0.1`], [#tag-p2o],
    [LIO の点を採用する最小移動距離［m］],

    paramgroup("④ 3D 点群を 2D 地図に変換するとき"),
    [16], [`thre_z_min`], [`-0.2`], [#tag-2d],
    [2D 化で使う点の#tsuyo[高さの下限]［m］。これより低い点（路面など）は捨てます],
    [17], [`thre_z_max`], [`2.0`], [#tag-2d],
    [2D 化で使う点の#tsuyo[高さの上限]［m］。これより高い点（天井・木の枝など）は捨てます],
    [18], [`map_resolution`], [`0.05`], [#tag-2d],
    [2D 地図の 1 画素が表す長さ［m］。小さいほど細かいが画像が大きくなります],
    [19], [`thres_point_count`], [`1`], [#tag-2d],
    [ノイズ除去の判定個数。大きいほどノイズに強いが細い柱が消えます（@subsubsec-config-noise）],
    [20], [`flag_pass_through`], [`True`], [#tag-2d],
    [`True` で、上の高さ範囲にある点だけを取り出します],
    [21], [`thre_radius`], [`0.1`], [#tag-2d],
    [ノイズ除去の探索半径［m］。大きいほど広く見ます（@subsubsec-config-noise）],
    [22], [`waypoint_tolerance`], [`1.0`], [#tag-2d],
    [経路の周囲を「通ってよい場所」として塗る幅［m］],
  )],
  caption: [地図作成コンフィグのパラメータ一覧],
) <tab-config-params>

#tip[
  「どの値をどちら向きに変えればよいか」で迷ったときは
  @tab-ref-param-symptom（症状から引く表）が便利です。
  付録の @tab-ref-mapping-params には、既定値と使用箇所を
  ソースコードの単位でまとめた一覧もあります。
]

=== ノイズ除去の 2 つのパラメータ <subsubsec-config-noise>

`thres_point_count` と `thre_radius` は#tsuyo[セット]で働きます。
「半径 `thre_radius` の球の中に、`thres_point_count` 個以上の仲間がいない点は
ノイズとみなして捨てる」という判定です。

#figure(
  stable(
    columns: (auto, 1fr, 1fr),
    [*変えかた*], [*良くなること*], [*悪くなること*],
    [`thres_point_count` を大きくする],
    [ぱらぱらした浮遊ノイズが消え、地図がきれいになります],
    [細いポール・ワイヤーなど、点が少ない#tsuyo[本物の障害物]まで消えます],
    [`thres_point_count` を小さくする],
    [1 点でも障害物として残すため、安全側になります],
    [ノイズが障害物として残り、「通れない場所」が増えます],
    [`thre_radius` を大きくする],
    [広い範囲で密度を見るため、まばらなノイズを消しやすくなります],
    [密度の低い実物（物体の角など）も消えるおそれがあります],
    [`thre_radius` を小さくする],
    [ごく近くに寄り集まった点だけを残すため、ゴースト除去に向きます],
    [近い距離で固まっているノイズは残ります],
  ),
  caption: [ノイズ除去パラメータの効き方],
) <tab-config-noise>

#note[
  #tsuyo[まずは出荷時の値のままで 1 回作ってみてください。]
  2D 地図に白い点々（実在しない障害物）が散っているときだけ、
  `thres_point_count` を `2`、`3` と少しずつ上げます。
  逆に、細い柱が地図から消えてしまうときは `1` に戻します。
  でき上がりの見分け方は @sec-2d-map を参照してください。
]

== 特に注意が必要なパラメータ <subsec-config-critical>

@tab-config-critical の 5 項目は、値を間違えると
#tsuyo[地図がまったく作れない]、あるいは
#tsuyo[エラーが出ないのに中身が空の地図ができる]という結果になります。
編集する前に本節を必ずお読みください。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*項目*], [*安全な値*], [*間違えたときに起きること*],
    [`pc_save_distance`], [`0`〜数 m],
    [大きすぎると地図が粗くなります。`0` で間引きなし（@tab-pcsave-density）],
    [`pointcloud_topic`], [rosbag に実在する名前],
    [空の地図ができ、完了と表示されます（@err-topic-pc）],
    [`lio_topic`], [rosbag に実在する名前],
    [空の地図ができ、完了と表示されます（@err-topic-lio）],
    [`gnss_topic`], [rosbag に実在する名前],
    [処理が始まらず、画面が「処理中」のまま止まります（@err-topic-gnss）],
    [`orig_frame` / `target_frame`], [センサ設定と同じ名前],
    [lio_raw で#tsuyo[何のエラーも出ずに]空の地図ができます（@err-frame-mismatch）],
  ),
  caption: [間違えると影響が大きいパラメータ],
) <tab-config-critical>

=== `pc_save_distance` と `wp_save_distance` <subsubsec-config-pcsave>

この 2 つは、どちらも#tsuyo[距離［m］]です。
`p2o` と `lio_raw` のどちらでも同じ意味で働きます。

#figure(
  stable(
    columns: (auto, 1fr),
    [*項目*], [*意味*],
    [`pc_save_distance`],
    [前回足し込んだ位置から、この距離だけ進むごとに点群を地図へ足し込みます。
     #tsuyo[小さくすると密で重い地図]、大きくすると粗くて軽い地図になります],
    [`wp_save_distance`],
    [前回置いた経路点から、この距離だけ進むごとに経路点を置きます。
     小さくすると経路点が増えます],
  ),
  caption: [2 つの保存間隔],
) <tab-pcsave-meaning>

#tsuyo[`0.3` のような 1 未満の小数を指定できます。]
実際にどれくらい変わるかを @tab-pcsave-density に示します
（走行距離およそ 8 m、点群 112 枚の rosbag での実測値）。

#figure(
  stable(
    columns: (auto, auto, auto, auto),
    [`pc_save_distance`], [*使われた点群*], [*地図の点数*], [*ファイルサイズ*],
    [`0.0`（出荷時・すべて）], [112 枚], [306,950 点], [約 8.9 MB],
    [`0.3`], [37 枚], [101,095 点], [約 2.9 MB],
    [`1.0`], [14 枚], [38,196 点], [約 1.1 MB],
    [`2.0`], [8 枚], [21,866 点], [約 0.6 MB],
  ),
  caption: [`pc_save_distance` と地図の密度（実測）],
) <tab-pcsave-density>

#tip[
  #tsuyo[迷ったら出荷時の `0.0` のままで構いません。]
  `0` は#tsuyo[間引かずにすべて]足し込む設定で、いちばん密な地図になります。

  - 地図が重くて 3D Viewer の表示が遅い → `1.0`、`2.0` と大きくします
  - 広い現場（数百 m 以上）を回る → はじめから `1.0` 前後にしておくと扱いやすくなります
  - 逆に、`2.0` にしたら壁の形が粗くなった → `0.5`、`0.3` と小さく戻します
]

#note[
  実行すると、端末に実際の間引き結果が表示されます。
  #tsuyo[「結合した点群」が 0 枚のときは地図ができていません。]

  #console(title: "点群を結合するときの端末表示")[```
  PointCloud Distance Filter: 0.3 m
  Waypoint Distance Filter: 4 m
結合した点群: 37 枚 / 112 枚中 (合計 101095 点)
PCDファイルを保存しました: <地図名>_Acord.pcd
```]
]

#note[
  以前に作成した地図と#tsuyo[同じ密度]で作り直したい場合は、
  当時と同じ値を指定してください。
  値を変えると、同じ rosbag からでも密度の異なる地図ができます。
]

=== トピック名が合っているか確かめる <subsubsec-config-checktopic>

`gnss_topic`、`pointcloud_topic`、`lio_topic` に書いた名前は、
#tsuyo[使用する rosbag に実際に入っている名前]と一字一句同じでなければなりません。
次のコマンドで確認できます。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ros2 bag info rosbag/<rosbag名>
```]

#console(title: "確認の表示例")[```
Topic information: Topic: /fix | Type: sensor_msgs/msg/NavSatFix | Count: 28 | ...
                   Topic: /hokuyo3d/hokuyo_cloud2 | Type: sensor_msgs/msg/PointCloud2 | Count: 537 | ...
                   Topic: /hokuyo3d/imu | Type: sensor_msgs/msg/Imu | Count: 27799 | ...
                   Topic: /rsf/lio_imu_rate_odom | Type: nav_msgs/msg/Odometry | Count: 27799 | ...
                   Topic: /rsf/lio_lidar_rate_odom | Type: nav_msgs/msg/Odometry | Count: 536 | ...
```]

#warn[
  #tsuyo[`Count:` が `0` のトピックは、名前があってもデータが入っていません。]
  一覧に名前が出ていても `Count: 0` なら、そのトピックは使えません。
  記録時にセンサが繋がっていなかった可能性があります（@err-no-sensor）。
]

#note[
  LIO のトピックは 2 種類あります。用途に応じて選んでください。

  #figure(
    stable(
      columns: (auto, auto, 1fr),
      [*トピック*], [*周期*], [*使いどころ*],
      [`/rsf/lio_lidar_rate_odom`], [LiDAR と同じ（低い）],
      [点群と時刻が揃うため、素直に対応が取れます],
      [`/rsf/lio_imu_rate_odom`], [IMU と同じ（高い）],
      [位置の間隔が細かく、点群との時刻合わせの精度が上がります],
    ),
    caption: [2 種類の LIO トピック],
  ) <tab-lio-topics>

  どちらでも地図は作れます。
  #tsuyo[ただし、rosbag に `Count: 0` でない方を選んでください。]
]

=== フレーム名が合っているか確かめる <subsubsec-config-checkframe>

`orig_frame` と `target_frame` は、#tsuyo[lio_raw モードでのみ]使われます。
`p2o` モードでは読み込まれないため、値が違っていても影響しません。

#danger[
  lio_raw では、この 2 つが LIO トピックの中身と一致しない場合、
  #tsuyo[エラーも警告も一切出さずに]点群が 1 点も保存されません。
  それでも「完了しました」と表示されるため、
  #tsuyo[最も気付きにくい失敗]です（@err-frame-mismatch）。
]

正しい値は、センサ設定ファイル
#path[config/rsf_node_config.yaml] に書かれています。
@tab-config-frame-map の対応どおりに、#tsuyo[そのまま写してください]。

#figure(
  stable(
    columns: (auto, auto, auto),
    [*地図作成コンフィグ*], [*センサ設定の項目*], [*既定値*],
    [`target_frame`], [`odom_frame`], [`lio_odom`],
    [`orig_frame`], [`lidr_frame`], [`yvt`],
  ),
  caption: [フレーム名の対応],
) <tab-config-frame-map>

#terminal[```bash
grep -e odom_frame -e lidr_frame \
  ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/rsf_node_config.yaml
```]

#console(title: "確認の表示例")[```
    odom_frame: "lio_odom"
    lidr_frame: "yvt"
```]

#tip[
  rosbag の中身から直接確かめたい場合は、次のコマンドを実行します。
  `header.frame_id` が `target_frame` に、
  `child_frame_id` が `orig_frame` に対応します。

  #terminal[#text(size: 7.5pt)[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
python3 - <<'EOF'
import rosbag2_py, glob, sys
from rclpy.serialization import deserialize_message
from rosidl_runtime_py.utilities import get_message
bag = "rosbag/<rosbag名>"           # ← ここを書き換える
topic = "/rsf/lio_imu_rate_odom"    # ← lio_topic に書いた名前
f = (glob.glob(bag+"/*.mcap") + glob.glob(bag+"/*.db3"))[0]
sid = "mcap" if f.endswith("mcap") else "sqlite3"
r = rosbag2_py.SequentialReader()
r.open(rosbag2_py.StorageOptions(uri=f, storage_id=sid),
       rosbag2_py.ConverterOptions("", ""))
types = {t.name: t.type for t in r.get_all_topics_and_types()}
while r.has_next():
    tn, data, _ = r.read_next()
    if tn == topic:
        m = deserialize_message(data, get_message(types[tn]))
        print("target_frame に書く値 :", m.header.frame_id)
        print("orig_frame   に書く値 :", m.child_frame_id)
        sys.exit()
print("そのトピックは rosbag にありません")
EOF
```]]

  #console(title: "確認の表示例")[```
target_frame に書く値 : lio_odom
orig_frame   に書く値 : yvt
```]
]

== 走行順序の定義
/ シナリオファイル: 複数の地図を切り替えて走行する際の地図走行順序を定義するためのファイルです。CSV形式で、各行に地図のファイル名と走行順序を定義します。#footnote[CSVファイル内に半角スペース（カンマの前後など）が含まれないように注意してください。正常に読み込まれない原因となります。]

#terminal[#text(size: 8pt)[
```csv
map_file,waypoint_file,nav_type,interval
map1,waypoint1,loc,10
map2,waypoint2,gnss,30
map3,waypoint3,loc,5
```
]]

こちらは#tsuyo[1 行が 1 つの地図]に対応し、上から順に走行します。
地図作成コンフィグとは違い、#tsuyo[1 行目は列名]で、2 行目以降が実際のデータです。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*列*], [*書く内容*], [*説明*],
    [`map_file`], [地図の名前（拡張子なし）],
    [3D 点群地図（`.pcd`）と 2D 地図（`.pgm`）の#tsuyo[両方に共通の名前]を書きます。
     `map1` と書いた場合、`map1.pcd` と `map1.pgm` の 2 つが使われます。
     #tsuyo[この 2 つのファイル名は必ず同じにしてください]],
    [`waypoint_file`], [経路の名前（拡張子なし）],
    [`.json` 形式の経路ファイルを指します。作り方は @sec-waypoint を参照してください],
    [`nav_type`], [`loc` または `gnss`],
    [`loc`: 3D 点群地図と照合して自己位置を求めます（屋内・GNSS が届かない場所向け）。\
     `gnss`: GNSS の位置をそのまま使います（空の開けた屋外向け）],
    [`interval`], [秒数],
    [次の地図へ切り替えるまでの待ち時間［s］。
     複数地図を切り替えて走る（multi\_map）ときにだけ使われます],
  ),
  caption: [シナリオファイルの列],
) <tab-config-scenario>

#warn[
  `map_file` と `waypoint_file` には、#tsuyo[拡張子を付けないでください]。
  また、ここに書いた名前のファイルが `map/` `waypoints/` に実在しない場合、
  走行はその行で止まります。ファイル一覧は「ファイル管理」画面で確認できます。
]

== 編集方法
コンフィグファイルは、「ファイル管理」の「設定ファイル管理」からブラウザ上で編集できます。
ブラウザ上での画面を @sub7 〜 @sub8 に示します。\
/ 地図作成コンフィグの編集: @sub7 の「テキスト編集」ボタンをクリックすると、@sub8 の画面が表示され、コンフィグファイルの内容がテキストエリアに表示されます。テキストエリア内で内容を編集し、「保存」ボタンをクリックすると、変更が保存されます。編集の際は、CSV形式を維持するように注意してください。例えば、パラメータ名と値の間はカンマで区切り、各行は改行で区切る必要があります。また、CSVファイル内に半角スペース（カンマの前後など）が含まれないようにしてください。正常に読み込まれない原因となります。\
/ シナリオファイルの編集: シナリオファイルも、地図作成コンフィグと同様の方法で編集できます。@sub7 の「テキスト編集」ボタンをクリックし、テキストエリア内で内容を編集して保存してください。シナリオファイルもCSV形式を維持するように注意してください。
  - シナリオファイルに関しては、@sub7 の「編集」ボタンをクリックした後に、@sub9 の画面が表示されます。これは専用のシナリオ編集画面で、シナリオファイルの内容を表形式で編集できるようになっています。表形式の編集画面では、地図ファイル名、経路ファイル名、走行モードをそれぞれの列に入力して編集できます。切り替え間隔は数値を入力します。行の追加・削除は、ボタンをクリックすると即座に実行されます。また、各行の左に、”三” の字のアイコンを画面の上下にドラッグアンドドロップすることで、行ごとの入れ替えが可能です。編集後は、「保存」ボタンをクリックして変更を保存してください。
/ ファイル名の編集: コンフィグファイルのファイル名を変更したい場合は、@sub7 の編集したいコンフィグファイルの文字列をダブルクリックすると、ファイル名を編集できるようになります。新しいファイル名を入力し、選択解除すると、ファイル名の変更が反映されます。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/7.png", width: 100%), caption: [設定ファイル管理]) <sub7>],
    [#figure(image("img/8.png", width: 100%), caption: [テキスト編集]) <sub8>],
    grid.cell(colspan: 2, [#figure(image("img/9.png", width: 90%), caption: [シナリオ編集]) <sub9>]),
  ),
  caption: [コンフィグファイルの編集画面],
) <im7>

== 編集後の確認 <subsec-config-verify>

コンフィグファイルを編集したら、#tsuyo[意図した値が読み込まれているか]を必ず確認してください。
マッピングを実行すると、端末の先頭に読み込まれた設定値の一覧が表示されます。

#console(title: "マッピング開始時に表示される設定値")[```
Loading config from: /home/hokuyo/colcon_ws/src/.../config/hokuyo_slam_topics_cfg.csv
gnss_topic: /fix
pointcloud_topic: /hokuyo3d/hokuyo_cloud2
lio_topic: /rsf/lio_lidar_rate_odom
gnss_cov_thre: 0.01
imu_topic: /hokuyo3d/imu
slam_mode: gnss
pc_save_distance: 0.0
wp_save_distance: 4.0
```]

#warn[
  `WARNING: Config file not found at ... Using default values.` と表示された場合は、
  #tsuyo[指定した設定ファイルが読めておらず、既定値で動いています]。
  マッピング実行時のファイル選択を確認してください。
]

実際に p2o マッピングを実行したときの端末表示を次に示します。
#tsuyo[この一覧と、自分が設定した値が一致していることを必ず確認してください。]

#console(title: "p2o マッピング開始直後の端末（実行例）")[```
hokuyo_slam (run_p2o) のバイナリを検索しています...
hokuyo_slam のバイナリディレクトリが見つかりました: .../hokuyo_slam_ros2/build
rosbag folder: .../rosbag/2026-08-07-14-27-kato-support exists.
current dir: .../hokuyo_navigation2/hokuyo_navigation2
rosbag dir: .../hokuyo_navigation2/hokuyo_navigation2/rosbag
ouput directory_name (Map Name): kato_support
rosbag file:  2026-08-07-14-27-kato-support
PCD Output Directory: .../hokuyo_navigation2/map
Flag File Name: kato_support.P2O_DONE
All args are checked.
Loading config from: .../config/hokuyo_slam_topics_cfg.csv
gnss_topic: /fix
pointcloud_topic: /hokuyo3d/hokuyo_cloud2
lio_topic: /rsf/lio_lidar_rate_odom
gnss_cov_thre: 0.01
imu_topic: /hokuyo3d/imu
slam_mode: gnss
pc_save_distance: 0.0
wp_save_distance: 4.0
gnss_min_movement_thre: 4.0
lio_min_movement_thre: 0.1
gravity_stride: 1
fix_rate: 30
```]

#tip[
  #tsuyo[表示されている値が、編集した値と違う場合]は、
  行の順序がずれています。@err-csv-order の手順で復旧してください。\
  よくある例として、`slam_mode` に `gnss` を設定したのに
  `lio_raw` と表示される場合は、上の行のどこかが増減しています。
]

== うまくいかないときは <subsec-config-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [設定を変えたのに反映されない], [@err-csv-order],
    [変えていない項目まで挙動が変わった], [@err-csv-order],
    [シナリオファイルが `CSVファイル` の一覧に出てこない], [@err-nav-no-csv],
    [ファイル名を変更しようとすると拒否される], [@err-rename],
    [ファイル選択画面でフォルダを開けない], [@err-path-denied],
  ),
  caption: [コンフィグファイルでよくある症状],
) <tab-config-trouble>

#pagebreak()