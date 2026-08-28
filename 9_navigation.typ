#import "utils.typ": *

= 自律走行 <sec-navigation>

本章では、作成した地図と経路を使ってロボットを自律走行させる手順を説明します。
@sec-mapping の 3D 地図、@sec-waypoint の経路、@sec-2d-map の 2D 地図がそろっていることが前提です。

#danger[
  自律走行はロボットが自分で動き出す機能です。開始前に必ず次を確認してください。
  - ロボットの進路上と周囲に人・物がないこと
  - 一時停止スイッチ（非常停止）がすぐ押せる位置にオペレータがいること
  - 初めての経路では、ロボットの横に付いて歩ける速度に設定してあること

  GUI の開始画面には確認用のチェック欄があり、
  #tsuyo[すべてにチェックを入れるまで開始ボタンは押せません]。
  これは操作ミスを防ぐための仕組みです。チェックを形式的に入れるのではなく、
  実際に目で確認してから入れてください。
]

== 走行モードの選び方 <subsec-nav-mode>

自律走行には 3 つのモードがあり、GUI の `NAVTYPE` で選びます。
まず「単一マップか、マルチマップか」を決め、単一マップの場合は「GNSS か LIO か」を決めます。

#figure(
  stable(
    columns: (auto, 1fr, 1fr),
    [*NAVTYPE*], [*どんなときに使うか*], [*自己位置の求め方*],

    [`single_map_loc`],
    [1 つの地図の中を走る。屋内、屋根の下、ビルの谷間など
     #tsuyo[GNSS が届きにくい場所]。迷ったらまずこれ],
    [3D 点群地図と現在の点群を照合して求める
     （`simple_fastlio_localization`）],

    [`single_map_gnss`],
    [1 つの地図の中を走る。#tsuyo[空が開けた屋外]で、
     RTK-GNSS が安定して受信できる場所],
    [RSF が GNSS と LIO を自動で切り替えて出す位置を使う],

    [`multi_map`],
    [複数の地図を順番に切り替えて走る。
     広い敷地を区画ごとに分けて地図化した場合など],
    [地図ごとにシナリオファイルで `loc` / `gnss` を指定する],
  ),
  caption: [走行モードの選択],
) <tab-nav-type>

#plain[
  `loc` は「地図と見比べて自分の位置を知る」方式、
  `gnss` は「衛星で自分の位置を知る」方式です。\
  屋内では衛星の電波が届かないので `loc`、
  広い屋外では地図に特徴が少なく見比べにくいので `gnss`、と覚えておけば大きく外しません。
]

#note[
  モードによって必要な TF のつながり方が変わります（@subsec-tf）。
  `loc` では `map` → `odom` → `base_link`、
  `gnss` では `map` → `base_link` が必要です。
  走り出さないときは、まずここを疑ってください。
]

== 単一マップ走行の手順 <subsec-nav-single>

+ メイン画面の #btn[自律走行] をクリックします。@sub-nav-popup の画面が開きます。

+ 表示された 3 つのチェック欄を、#tsuyo[実際に確認しながら]チェックします。
  - 一時停止スイッチをオンしていること
  - オペレータが周りの安全を確認していること
  - フリースイッチをオフしていること

  #note[
    3 つすべてにチェックを入れるまで、#btn[自律走行開始] ボタンは灰色のまま押せません。
    押せない場合はチェックの入れ忘れです。
  ]

+ `NAVTYPE` のプルダウンから `single_map_gnss` または `single_map_loc` を選びます。
  選ぶと `MAPFILE` と `WPFILE` の欄が表示されます。

+ `MAPFILE` で走行に使う地図を、`WPFILE` で経路を選びます。

  #warn[
    `MAPFILE` の一覧には、`map/` フォルダにある #tsuyo[`.yaml` ファイル]の名前だけが表示されます。
    @sec-2d-map の 2D 地図変換を行っていない地図は、ここに出てきません。
    地図が一覧に無い場合は @err-nav-no-map を参照してください。
  ]

+ #btn[自律走行開始] をクリックします。
  「自律走行が開始されました。周囲の安全に気をつけて下さい。」と表示され、
  新しいタブと複数の端末が開きます。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 8pt,
    [#figure(
      image("img/g_popup_nav_loc.png", width: 100%),
      caption: [単一マップ走行（`single_map_loc`）。\
                `MAPFILE` と `WPFILE` の欄が出る],
    ) <sub-nav-popup>],
    [#figure(
      image("img/g_popup_nav_multi.png", width: 100%),
      caption: [マルチマップ走行（`multi_map`）。\
                代わりに `CSVファイル` の欄が出る],
    ) <sub-nav-multi-popup>],
  ),
  caption: [`NAVTYPE` の選択によって変わる開始画面],
) <im-nav-popup>

#note[
  `NAVTYPE` を選ぶと、その下に出る欄が入れ替わります。
  #tsuyo[`multi_map` を選ぶと `MAPFILE` と `WPFILE` は消え、
  代わりに `CSVファイル` が現れます。]
  欄が見当たらない場合は `NAVTYPE` の選択を確認してください。
]

=== 開始後に内部で起きていること <subsubsec-nav-inside>

開始ボタンを押すと、次の順序で処理が進みます。
端末に流れる文字はこの順番で出てくるので、#tsuyo[どこで止まったかを見れば原因の見当がつきます]。

#v(3pt)
#fstep(1, [残っているノードを片付ける], [
  `既存のROSノードを終了します...` と表示されます。
  前回の走行のノードが残っていると衝突するため、いったんすべて終了させます。
])
#fstep(2, [初期位置を読み込む], [
  地図と一緒に保存された初期位置ファイル
  #path[data/<地図名>/init_pose.txt] を読みます。
  ファイルが無い場合は
  `警告: ... が見つかりません。デフォルトの初期位置を使用します。`
  と表示され、原点から始まります（@err-init-pose 参照）。
])
#fstep(3, [モータドライバを起動する], [
  `モータドライバを起動します...` と表示され、専用の端末が開きます。
])
#fstep(4, [ナビゲーションシステムを起動する], [
  `ナビゲーションシステムを起動します... (マップ: ..., GNSS: ...)` と表示され、
  Nav2・自己位置推定・座標変換の各ノードが起動します。
])
#fstep(5, [経路をたどり始める], [
  `ウェイポイント追従を開始します: <経路名>.json` と表示され、
  `waypoint_manager` が Nav2 に目標地点を 1 つずつ送り始めます。ここでロボットが動き出します。
])

#warn[
  ⑤ で `waypoint_manager` が異常終了した場合、
  `エラー: waypoint_managerが異常終了しました。15秒後に再試行します...`
  と表示され、#tsuyo[15 秒のカウントダウンのあと自動的にやり直します]。
  これは繰り返し続くため、原因を直さない限り止まりません。
  止めたいときは @subsec-nav-stop の手順で停止してください。
]

#console(title: "自律走行開始時の端末表示（正常時の例）")[```
--- 実行パラメータ ---
mapfile: toyonaka
wayfile: toyonaka
navigation: true
use_gnss_switch: false
----------------------
既存のROSノードを終了します...
----------------------------------------------------
マップの処理を開始します: toyonaka
----------------------------------------------------
モータドライバを起動します...
モータドライバ関連ノードの起動を確認しました。
ナビゲーションシステムを起動します... (マップ: toyonaka, GNSS: false)
ウェイポイント追従を開始します: toyonaka.json
```]

続いて、Nav2 の各プログラムが順に立ち上がります。
#tsuyo[次の 2 行が出れば、走り出す準備が整っています。]

#console(title: "起動が成功したときの端末")[```
map_server の起動を待っています...
現在の状態: inactive [2]
Inactive 状態を検出しました。activate を実行します。
map_server はすでに Active です。
Nav2のライフサイクル状態とアクションサーバーの準備を監視しています...
Nav2システムおよびアクションサーバーの準備が完全に完了しました。
コストマップの安定化を待っています (3秒)...
ウェイポイント追従を開始します: toyonaka.json
[INFO] [nav2_waypoint_manager_executor]: Loaded 12 waypoints from toyonaka.json
[INFO] [nav2_waypoint_manager_executor]: TF from map to base_link is available. Nav2 should be ready.
[INFO] [nav2_waypoint_manager_executor]: Waiting for Nav2 action server...
[INFO] [nav2_waypoint_manager_executor]: Sending goal for waypoint 0...
[INFO] [nav2_waypoint_manager_executor]: Goal accepted. Starting custom arrival check...
```]

反対に、うまくいかないときは次のように#tsuyo[同じ内容が繰り返し表示され続けます]。
これは異常です。@err-nav2-timeout から順に確認してください。

#console(title: "起動に失敗して繰り返しているときの端末")[```
エラー: Nav2の起動確認がタイムアウトしました。現在の状態: unconfigured
エラー: Nav2の起動に失敗しました。再試行します...
----------------------------------------------------
マップの処理を開始します: toyonaka
----------------------------------------------------
（以下、同じ内容が繰り返される）
```]

#console(title: "waypoint_manager が異常終了して再試行しているときの端末")[```
[ERROR] [nav2_waypoint_manager_executor]: Timeout waiting for TF from map to base_link \
after 30.0 seconds. Shutting down.
エラー: waypoint_managerが異常終了しました。15秒後に再試行します...
ノードの終了を待っています...
再起動待機中: 12 秒...
```]

#warn[
  #tsuyo[繰り返しは自動では止まりません。]
  同じ表示が 2 回以上出たら、いったん #btn[ロボット停止] を押し、
  @sec-trouble で原因を調べてから再開してください。
  放置すると、地図の読み込みとノードの起動が延々と繰り返されます。
]

== マルチマップ走行の手順 <subsec-nav-multi>

複数の地図を順番に切り替えて走行するモードです。
走る順序は、あらかじめ #tsuyo[シナリオファイル]（CSV）で定義しておきます。
シナリオファイルの書き方と編集方法は @sec-config を参照してください。

+ シナリオファイルを用意します。GUI の「ファイル管理」から作成・編集できます。
  1 行目の見出しは必ず次の形にしてください。

  #terminal[```csv
map_file,waypoint_file,nav_type,interval
```]

  #warn[
    `NAVTYPE` で `multi_map` を選んだときの `CSVファイル` の一覧には、
    #tsuyo[1 行目がこの見出しと完全に一致する CSV だけ]が表示されます。
    地図作成コンフィグ（`option_name,value,default` で始まる CSV）は
    別の種類のファイルなので、ここには出てきません。
    一覧に出てこない場合は @err-nav-no-csv を参照してください。
  ]

+ メイン画面の #btn[自律走行] をクリックし、チェック欄をすべて確認してチェックします。

+ `NAVTYPE` で `multi_map` を選びます。`CSVファイル` の欄が表示されます。

+ 使うシナリオファイルを選び、#btn[自律走行開始] をクリックします。

=== マルチマップ走行の進み方 <subsubsec-nav-multi-flow>

シナリオファイルの 1 行が 1 つの地図に対応し、上から順に処理されます。

#v(3pt)
#flow("地図Aで走行", "interval 秒待つ", "ノード終了", "15秒待つ", "地図Bで走行")
#v(6pt)

+ その行の地図・経路・走行モードで、単一マップ走行と同じ手順を実行します。
+ 経路を最後までたどり終えると次に進みます
  （マルチマップでは `waypoint_manager` は `--once` 付きで実行され、周回しません）。
+ シナリオファイルの `interval` で指定した秒数だけ待機します。
  端末には `次のマップまであと N 秒...` とカウントダウンが表示されます。
+ 走行関連のノードをすべて終了し、さらに #tsuyo[約 15 秒]待ってから次の地図に移ります。
  この待ち時間はノードが完全に終了するために必要なもので、短縮できません。

#warn[
  マルチマップ走行は、#tsuyo[シナリオファイルの最後まで行くと先頭に戻り、無限に繰り返します]。
  `=== CSVファイルの最後まで処理しました。ループを再開します。 ===`
  と表示されたあと、また 1 行目から走り始めます。
  1 周で終わらせたい場合は、最後の地図を走り終えた時点で
  @subsec-nav-stop の手順で停止してください。
]

地図が切り替わる場面では、端末に次のように表示されます。
#tsuyo[カウントダウンの間はロボットが停止したままになりますが、故障ではありません。]

#console(title: "地図が切り替わるときの端末")[```
waypoint_managerが正常に完了しました。
----------------------------------------------------
マップの処理を開始します: map2
----------------------------------------------------
次のマップまであと 10 秒...
次のマップまであと 9 秒...
次のマップまであと 8 秒...
```]

#note[
  待ち時間はシナリオファイルの `interval` 列で決まります（@subsec-ref-scenario）。
  短すぎると前の地図のノードが終了しきる前に次が起動し、
  起動失敗（@err-nav2-timeout）の原因になります。
  #tsuyo[10 秒以上を目安にしてください。]
]

== 走行中の状態確認 <subsec-nav-monitor>

自律走行中は RViz2 の画面が開き、ロボットの状態が表示されます。
画面左上に重ねて表示される文字は、#tsuyo[色そのものが状態を表しています]。
専門的な数値を読まなくても、色だけで正常・異常の見当がつきます。

#figure(
  image("img/r_nav_orbit.png", width: 96%),
  caption: [自律走行中の RViz2 画面（斜め上から見た表示）],
) <im-rviz-nav>

#figure(
  image("img/r_nav_top.png", width: 96%),
  caption: [同じ場面を真上から見た表示。2D 地図と経路の関係が分かりやすい],
) <im-rviz-nav-top>

#figure(
  stable(
    columns: (auto, 1fr),
    [*画面上の要素*], [*意味*],
    [白い背景と黒い線], [2D 地図。黒い線が壁や柱],
    [紫〜赤の帯], [コストマップ。#tsuyo[障害物の周囲に取られた余裕]。
                    ここへは進入しません],
    [水色の点], [いま見えているレーザの反射点（現在の周囲の様子）],
    [青い矢印の列], [経路（ウェイポイント）。文字は各地点の属性と許容誤差],
    [赤い矢印], [いま向かっている目標地点],
    [左上の文字], [GNSS 精度と自己位置の種類（@im-overlay）],
    [左下の `Navigation 2` 欄], [Nav2 の状態、残り距離、経過時間、復帰動作の回数],
  ),
  caption: [RViz2 画面の見方],
) <tab-rviz-legend>

#tip[
  #tsuyo[`Recoveries`（復帰動作の回数）が増え続けている場合は要注意です。]
  ロボットが進めずに、その場での回転や後退を繰り返しています。
  経路が障害物に近すぎるか、2D 地図が実際と合っていません
  （@err-wp-stuck、@subsec-2dmap-tips）。
]

#figure(
  grid(
    columns: (1fr,),
    gutter: 8pt,
    [#figure(
      image("img/r_overlay_good.png", width: 92%),
      caption: [正常時。GNSS が緑、自己位置の種類が水色],
    ) <sub-overlay-good>],
    [#figure(
      image("img/r_overlay_mid.png", width: 92%),
      caption: [注意。GNSS が黄色（精度が中程度）],
    ) <sub-overlay-mid>],
    [#figure(
      image("img/r_overlay_bad.png", width: 92%),
      caption: [異常時。GNSS が赤（精度が低い）],
    ) <sub-overlay-bad>],
  ),
  caption: [画面左上に重ねて表示される状態の文字],
) <im-overlay>

#plain[
  #tsuyo[読むのは色だけで構いません。]\
  緑ならそのまま、黄色なら注意して見守る、赤なら止めて確認する、と覚えてください。
]

=== GNSS の精度表示

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*表示色*], [*表示される文字*], [*意味と対応*],
    [緑], [GNSSの精度は良好です。],
    [そのまま走行して問題ありません],

    [黄], [GNSSの精度は中程度です。],
    [`gnss` モードでは位置がふらつくことがあります。
     樹木や建物の陰を通過している間だけであれば様子を見てください],

    [赤], [GNSSの精度が低い状態です。],
    [`gnss` モードでの走行には適しません。
     この場所を走る必要がある場合は `loc` モードに切り替えてください],

    [白], [GNSSの精度: N/A],
    [GNSS のデータが届いていません。@err-no-gnss を参照してください],
  ),
  caption: [GNSS 精度の表示],
) <tab-gnss-color>

=== 自己位置の種類の表示

`Odometry Type:` に続けて、いまどの方法で自分の位置を求めているかが表示されます。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*表示色*], [*表示*], [*意味*],
    [緑], [GNSS (switch)], [GNSS の位置を使っている],
    [水色], [LIO (switch)], [GNSS が使えないため LIO の位置に切り替えている（正常な動作）],
    [黄], [LIO (raw)], [補正のかかっていない LIO の位置。走り始めの一時的な状態],
    [白], [N/A], [情報が届いていない],
  ),
  caption: [自己位置の種類の表示],
) <tab-odom-color>

=== LIO の更新頻度の表示

`Lidar Odom Rate:` には、LIO が 1 秒間に何回位置を更新しているかが表示されます。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*表示色*], [*値の目安*], [*意味と対応*],
    [緑], [9.5 Hz 以上], [正常],
    [黄], [5.0 〜 9.5 Hz], [処理が追いついていません。走行はできますが、
     他の重いアプリケーションを閉じてください],
    [赤], [5.0 Hz 未満], [位置がずれる恐れがあります。@err-lio-slow を参照してください],
    [白], [N/A], [LIO のデータが届いていません。@err-lio-slow を参照してください],
  ),
  caption: [LIO 更新頻度の表示],
) <tab-lio-color>

#tip[
  走行前にこの 3 つがすべて緑（`loc` モードでは GNSS が緑でなくても構いません）になっていることを
  確認してから走らせると、走行中のトラブルを大きく減らせます。
]

== 経路上の動作（属性） <subsec-nav-attr>

経路の各地点には属性を設定でき、ロボットはその地点で指定された動作をします。
属性の設定方法は @sec-waypoint を参照してください。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*属性*], [*`value` の意味*], [*ロボットの動作*],
    [`normal`], [（使わない）], [そのまま通過する。速度は通常速度に戻る],
    [`stop`], [停止時間 [s]], [その地点で指定秒数だけ停止し、その後再開する],
    [`slow`], [制限速度 [m/s]], [次の地点まで指定速度まで減速して走る],
  ),
  caption: [経路の属性と動作],
) <tab-wp-attr>

到着したかどうかは、地点ごとに設定した `xy_tolerance`（位置の許容誤差 [m]）と
`yaw_tolerance`（向きの許容誤差 [rad]）で判定されます。

#note[
  `waypoint_manager` は、経路上で地点を#tsuyo[通り過ぎたことを検知すると自動的に次の地点へ切り替えます]。
  そのため、多少の行き過ぎでロボットが立ち往生することはありません。
  ただし `xy_tolerance` を極端に小さくすると、
  何度も同じ地点に近づき直そうとして進まなくなることがあります（@err-wp-stuck 参照）。
]

== 停止のしかた <subsec-nav-stop>

=== 通常の停止

+ メイン画面の #btn[ロボット停止] をクリックします。
+ 「自律走行プログラムを終了します... 2秒後に自動的にメインページに戻ります。」と表示されます。
+ 走行に関係するプロセスがすべて終了し、開いていた端末が閉じます。
+ メイン画面の「現在のモード」が「停止モード」に戻ります。

#figure(
  image("img/g_msg_stop.png", width: 72%),
  caption: [#btn[ロボット停止] を押した直後の画面],
) <im-nav-stopmsg>

#note[
  #btn[ロボット停止] は、走行スクリプト本体・Nav2・自己位置推定・モータドライバ・
  `waypoint_manager` をまとめて終了させます。
  マルチマップ走行の繰り返しループもここで止まります。
]

=== GUI が使えないときの停止

ブラウザが閉じてしまった、GUI が反応しないなどの理由で #btn[ロボット停止] が押せない場合は、
「データ取得」や「自律走行」の開始時に一緒に開く
#tsuyo[「ロボットプログラム停止用ポップアップ」]（@sub15）を使ってください。
「ロボットプログラムを停止しますか？」の問いに #btn[OK] を押すと、すべてのノードが停止します。

それも使えない場合は、端末から直接次のコマンドを実行します。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
./scripts/ctrl/web_kill_all_rosnode.sh
```]

#danger[
  上記はいずれも #tsuyo[ソフトウェア的な停止]です。反映まで数秒かかることがあります。\
  ロボットが人や物に接触しそうな状況では、ソフトウェアの操作を試す前に、
  #tsuyo[必ず物理的な非常停止スイッチを押してください]。
]

#pagebreak()
