#import "utils.typ": *

= データの取得 <sec-get-data>

@sub3 のメイン画面の「データ取得」ボタンをクリックすることで、ROS ノード、モータドライバの起動・停止を行い、Vizanti 画面で地図・経路作成に必要な rosbag を取得します。この手順を実施する前に、RSFのノードのパラメータ(IPアドレスや、rostopic名、tfフレーム名等)を #path[~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/rsf_node_config.yaml] で確認して下さい。主な項目は @tab-ref-rsf にまとめています。

== 動作の説明
「データ取得」ボタンをクリックすると、画面が遷移し、「センサデータの記録が開始されました」と表示されます。すると、@im8 に示すターミナルと「ロボットプログラム停止用ポップアップ」#footnote[万が一ROSノードやモータドライバが起動した状態のままウェブGUIが無効化された場合は、@sub15 のポップアップを使用することで、ROSノードとモータドライバを停止させてください。]が起動し、RSFのROSノードとモータドライバが起動します。ターミナルはすぐに最小化されます。
GUIはメイン画面に戻り、「現在のモード」が「手動操作モード」に変わります。この際 @sub10 のように、メイン画面のボタンの内、誤動作防止のため「データ取得」、「マッピング」、「自律走行」、「ファイル管理」ボタンが無効化され、「ロボット停止」ボタンと「Map Viewer」のみが有効化されます。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/10.png", width: 90%), caption: [手動操作モード起動後のメイン画面]) <sub10>],
    [#figure(image("img/11.png", width: 95%), caption: [メイン画面の起動ターミナル(モータドライバの起動)]) <sub11>],
    [#figure(image("img/12.png", width: 95%), caption: [モータドライバの起動ターミナル]) <sub12>],
    [#figure(image("img/13.png", width: 80%), caption: [その他ターミナル]) <sub13>],
    [#figure(image("img/14.png", width: 95%), caption: [hokuyo_rsfノードの起動ターミナル]) <sub14>],
  ),
  caption: [手動操作モード],
) <im8>

その後、Vizanti 画面を開き、rosbag の記録と バーチャルジョイスティックを介して、ROSトピックでロボットの操縦を行います。rosbag の記録を停止して、ロボットを停止させると「データ取得」の一連の流れを終了します。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/16.png", width: 100%), caption: [メイン画面の起動ターミナル(ロボット停止後)]) <sub16>],
    [#figure(image("img/15.png", width: 100%), caption: [ロボットプログラム停止用ポップアップ]) <sub15>],
  ),
  caption: [手動操作モードの終了時の画面],
) <im9>

== Vizanti 画面の説明 <subsec-vizanti-ui>

Vizanti（ビザンティ）は、#tsuyo[ブラウザから ROS 2 のロボットを見る・動かす]ための画面です。
本システムでは、@sub3 の #btn[自律走行経路確認Viewer] から開き、
主に次の 2 つの目的で使います。

#flow("ロボットを操縦する（ジョイスティック）", "rosbag を記録する（Bag Recorder）")

#plain[
  Vizanti は、RViz のような専門ソフトをインストールしなくても、
  #tsuyo[ブラウザさえあれば同じことができる]ようにしたものです。
  ロボットに載っている PC の中で動いているので、
  現場ではタブレットやノート PC から同じ画面を開けます。
]

=== 画面の構成 <subsubsec-vizanti-layout>

Vizanti の画面は、上部の#tsuyo[アイコンバー]と、その下の#tsuyo[表示エリア]だけでできています。
設定画面はすべて、アイコンをクリックして開きます。

#figure(
  overlay(
    image("img/viz_overview.png", width: 100%),
    (1, 0.55, 0.040),
    (2, 0.392, 0.040),
    (3, 0.17, 0.28),
    (4, 0.50, 0.825),
    (5, 0.825, 0.947),
  ),
  caption: [Vizanti の画面（rosbag 記録中に、ジョイスティックで前進させている状態）],
) <fig-viz-overview>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*番号*], [*名前*], [*説明*],
    [#num(1)], [アイコンバー],
    [追加した機能（ウィジェット）が並びます。クリックすると設定画面が開きます],
    [#num(2)], [＋ボタン],
    [新しいウィジェットを追加します（@subsubsec-vizanti-add）],
    [#num(3)], [表示エリア],
    [ロボットの位置や軌跡が描かれます。#tsuyo[ドラッグで移動、マウスホイールで拡大・縮小]できます],
    [#num(4)], [バーチャルジョイスティック],
    [ドラッグするとロボットが動きます（@subsubsec-vizanti-teleop）],
    [#num(5)], [縮尺],
    [表示されている 1 目盛りが実際に何 m かを示します],
  ),
  caption: [Vizanti の画面各部],
) <tab-vizanti-layout>

@fig-viz-overview では、オレンジ色の矢印がロボットの通ってきた軌跡です。
#tsuyo[ロボットを動かしたときにこの矢印が伸びていれば、LIO（自己位置推定）が正しく動いています。]

=== アイコンバーの読み方 <subsubsec-vizanti-icons>

#figure(
  image("img/viz_iconbar.png", width: 78%),
  caption: [アイコンバー（左から順に、設定・接続状態・グリッド・TF・軌跡・rosbag 記録・ジョイスティック・追加）],
) <fig-viz-iconbar>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*アイコン*], [*名前*], [*何をするものか*],
    [歯車], [Global Settings],
    [表示の基準にするフレームや背景色を決めます（@subsubsec-vizanti-fixedframe）],
    [四角の枝分かれ], [Rosbridge Client],
    [ブラウザと ROS 2 の接続状態。#tsuyo[緑なら接続済み]、赤なら切断されています],
    [格子], [Grid],
    [表示エリアの方眼。距離の目安になります],
    [赤緑青の軸], [TF],
    [座標系（フレーム）を軸で表示します（@subsubsec-vizanti-tf）],
    [オレンジの矢印], [Pose Tracker],
    [ロボットの軌跡を描きます。データ取得中の確認に使います],
    [フロッピー], [Bag Recorder],
    [rosbag を記録します。#tsuyo[記録中は赤]になります（@subsubsec-vizanti-bag）],
    [白い丸], [Joystick Teleop],
    [バーチャルジョイスティックを出します（@subsubsec-vizanti-teleop）],
    [＋], [Add Widgets],
    [ウィジェットを追加します],
  ),
  caption: [出荷時に用意されているウィジェット],
) <tab-vizanti-widgets>

#note[
  アイコンバーに目的のアイコンが見当たらない場合は、
  #tsuyo[右にスクロール]するか（アイコンバーの上でマウスホイールを回します）、
  バーの下端をドラッグして#tsuyo[高さを広げて]ください。
  それでも無い場合は ＋ ボタンから追加します。
]

=== ウィジェットを追加する <subsubsec-vizanti-add>

＋ ボタンを押すと「Add Widgets」画面が開きます。
#tsuyo[By Type] と #tsuyo[By Topic] の 2 つのタブがあります。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 8pt,
    [#figure(image("img/viz_add_type_top.png", width: 100%),
      caption: [By Type：機能の種類から選ぶ（一覧の前半）]) <fig-viz-add-type>],
    [#figure(image("img/viz_add_topic.png", width: 100%),
      caption: [By Topic：いま流れているトピックから選ぶ]) <fig-viz-add-topic>],
  ),
  caption: [ウィジェットの追加画面],
) <fig-viz-add>

#tip[
  #tsuyo[慣れないうちは By Topic タブが確実です。]
  こちらには#tsuyo[実際にいま流れているトピックだけ]が並び、
  それぞれに合ったウィジェットが自動で選ばれます。
  クリックするだけで、トピック名の指定まで済んだ状態で追加されます。

  逆に言うと、#tsuyo[By Topic に出てこないトピックは流れていません]。
  センサが繋がっているかの確認にも使えます（@err-no-sensor）。
]

=== 表示の基準（Fixed Frame）を決める <subsubsec-vizanti-fixedframe>

歯車アイコンから開く「Global Settings」で、#tsuyo[Fixed Frame]（基準にする座標系）を選びます。
ここが正しくないと、点や軌跡がまったく表示されません。

#figure(
  image("img/viz_settings.png", width: 80%),
  caption: [Global Settings。Fixed Frame に `lio_odom` を選んだ状態],
) <fig-viz-settings>

#figure(
  stable(
    columns: (auto, 1fr),
    [*項目*], [*説明*],
    [Fixed Frame],
    [表示の基準にする座標系。データ取得中は #tsuyo[`lio_odom`] を選びます],
    [Background Color], [表示エリアの背景色],
    [Export / Import],
    [いまの画面構成（どのウィジェットをどう設定したか）をファイルに保存・復元します],
    [Reset Camera View],
    [表示位置を初期位置（基準フレームの原点）に戻します。#tsuyo[見失ったときはこれ]],
    [Reset Layout to default],
    [ウィジェットの構成を出荷時に戻します。#tsuyo[設定はすべて消えます]],
  ),
  caption: [Global Settings の項目],
) <tab-vizanti-settings>

#warn[
  歯車アイコンが#tsuyo[黄色]になっているときは、
  「No frame selected, defaulting to odom」（基準フレームが選ばれていない）という警告です。
  Fixed Frame のリストから `lio_odom` を選び直してください。
]

#note[
  Fixed Frame の一覧は、#tsuyo[クリックしたときに作り直されます]。
  ロボットのノードを起動した直後で目的の名前が出てこない場合は、
  一度リストを閉じてから、もう一度クリックしてください。
]

=== フレーム名を画面から確認する（TF） <subsubsec-vizanti-tf>

TF アイコン（赤緑青の軸）をクリックすると、
いま流れている座標系の#tsuyo[名前と親子関係]が一覧で表示されます。

#figure(
  image("img/viz_tf_modal.png", width: 80%),
  caption: [TF Frame Renderer。`yvt ← lio_odom` の関係と、現在の位置（m）が読める],
) <fig-viz-tf>

#tip[
  この画面は、地図作成コンフィグの `orig_frame` / `target_frame` を
  確認するのに便利です（@subsubsec-config-checkframe）。\
  @fig-viz-tf の `yvt ← lio_odom` という表示は、
  #tsuyo[`lio_odom` を親、`yvt` を子とする]という意味です。
  そのまま `target_frame` に `lio_odom`、`orig_frame` に `yvt` と書けば合います。
]

=== 走行の軌跡を見る（Pose Tracker） <subsubsec-vizanti-odom>

オレンジ色の矢印のアイコンをクリックすると、軌跡表示の設定画面が開きます。
#tsuyo[データ取得中に「ちゃんと動いているか」を確かめる、いちばん手軽な方法]です。

#figure(
  image("img/viz_odom_modal.png", width: 80%),
  caption: [Pose Tracker。`Target` に LIO の自己位置トピックを選ぶ],
) <fig-viz-odom>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*項目*], [*設定の目安*], [*説明*],
    [Target], [`/rsf/lio_lidar_` \ `rate_odom`],
    [軌跡を描く対象。LIO の自己位置トピックであれば
     `lio_lidar_rate_odom`（@fig-viz-odom の例）でも
     `lio_imu_rate_odom` でも構いません],
    [Colour], [任意], [矢印の色],
    [History (N)], [`200`], [表示しておく矢印の本数。多いほど長い軌跡が残ります],
    [Sample delay (ms)], [`500`], [矢印を置く間隔［ms］。小さくすると細かく残ります],
    [Draw path / Draw arrows], [両方オン], [線と矢印のどちらを描くか],
    [Clear history], [—], [それまでの軌跡を消します],
  ),
  caption: [Pose Tracker の項目],
) <tab-vizanti-odom>

#tip[
  #tsuyo[ロボットを 1 m ほど前に動かして、矢印が伸びれば正常です。]
  動かしても矢印が伸びない場合は、LIO が自己位置を出せていません。
  そのまま記録しても地図は作れないため、記録を始める前に確認してください
  （@err-no-sensor）。
]

=== rosbag を記録する（Bag Recorder） <subsubsec-vizanti-bag>

フロッピーのアイコンをクリックすると、rosbag の記録画面が開きます。

#figure(
  image("img/viz_bag_modal_top.png", width: 88%),
  caption: [Bag Recorder の操作部。保存先を入れ、トピックを選んでから記録を開始する],
) <fig-viz-bag>

#figure(
  stable(
    columns: (auto, 1fr),
    [*項目*], [*説明*],
    [Save to path],
    [保存先。#tsuyo[`/` で始まる絶対パス]を入力します（後述）],
    [Select All], [表示されているトピックを#tsuyo[すべて]選択します],
    [Select None], [選択をすべて外します],
    [Start recording], [記録を開始します。開始後は赤い #btn[Stop recording] に変わります],
    [Topics], [記録するトピックの選択。#tsuyo[メッセージの型ごとにまとめられて]います],
  ),
  caption: [Bag Recorder の項目],
) <tab-vizanti-bag>

トピックは型の見出し（`sensor_msgs/msg/PointCloud2` など）をクリックすると開きます。
@tab-bag-topics の 5 つを、@fig-viz-bag-topics のように#tsuyo[青（オン）]にしてください。

#figure(
  image("img/viz_bag_topics.png", width: 52%),
  caption: [記録するトピックを選んだ状態（青がオン）。型ごとにまとめられている],
) <fig-viz-bag-topics>

#danger[
  #tsuyo[保存先のパスは、ブラウザを開いている PC ではなく、ロボット側の PC で解釈されます。]
  現場でタブレットから操作している場合も、入力するのは#tsuyo[ロボット側 PC のパス]です。

  また、`~` は使わず、必ず `/home/` から始まる絶対パスを入力してください。
  `<ユーザ名>` の部分は、ロボット側の端末で `whoami` を実行すると確認できます。
]

==== 記録を開始・停止する

+ #btn[Start recording] を押すと、
  「Are you sure you want to start recording a bag?」という確認が出ます。#btn[OK] を押します。
+ 「Recording started.」と表示されれば記録中です。
  ボタンが赤い #btn[Stop recording] に変わり、
  アイコンバーのフロッピーのアイコンも#tsuyo[赤]に変わります。

  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      [#figure(image("img/viz_iconbar.png", width: 100%),
        caption: [停止中（白）]) <fig-viz-bar-idle>],
      [#figure(image("img/viz_iconbar_recording.png", width: 100%),
        caption: [記録中（赤）]) <fig-viz-bar-rec>],
    ),
    caption: [記録中はアイコンの色で分かる],
  ) <fig-viz-recstate>

+ 走行が終わったら #btn[Stop recording] を押します。
  確認のあと「Recording stopped.」と表示されれば完了です。

#figure(
  image("img/viz_bag_rec_top.png", width: 88%),
  caption: [記録中の Bag Recorder。ボタンが赤い #btn[Stop recording] に変わっている],
) <fig-viz-bag-rec>

#warn[
  保存されるフォルダ名には、#tsuyo[記録を開始した日時が自動で先頭に付きます。]
  たとえば `Save to path` に

  #terminal[```text
/home/hokuyo/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/kato-support
```]

  と入力して、2026 年 8 月 7 日 14 時 27 分に記録を始めた場合、
  実際にできるフォルダは次の名前になります。

  #terminal[```text
.../rosbag/2026-08-07-14-27-kato-support
```]

  マッピングのときに rosbag を選ぶ画面では、#tsuyo[この日時付きの名前]が並びます。
  同じ名前で何度記録しても上書きされないのはこのためです。
]

#danger[
  #tsuyo[トピックを 1 つも選ばずに記録を開始しないでください。]
  この場合でも「Recording started.」と表示されアイコンは赤くなりますが、
  #tsuyo[フォルダは 1 つも作られません]。
  停止して初めて「何も記録されていなかった」と分かります（@err-bag-notopic）。
]

=== ロボットを操縦する（Joystick Teleop） <subsubsec-vizanti-teleop>

白い丸のアイコンをクリックすると、ジョイスティックの設定画面が開きます。

#figure(
  image("img/viz_teleop_top.png", width: 62%),
  caption: [Joystick Teleop。Topic に `/wizurg/cmd_vel`、Apply preset に `Diffdrive` を選んだ状態],
) <fig-viz-teleop>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*項目*], [*設定の目安*], [*説明*],
    [Topic], [`/wizurg/cmd_vel`],
    [速度指令を送るトピック。#tsuyo[ここが空だとロボットは動きません]],
    [Apply preset], [`Diffdrive`],
    [ロボットの足回りに合わせた組み合わせを一括設定します。
     はじめは `Select...` のままなので、#tsuyo[必ず選び直してください]],
    [Axis（縦）], [`Forward/Back` \ `(linear.x)`], [ジョイスティックを上下に倒したときの動き],
    [Axis（横）], [`Yaw (angular.z)`], [ジョイスティックを左右に倒したときの動き],
    [Max Velocity（縦）], [`1`],
    [前後の最大速度［m/s］。#tsuyo[データ取得では 0.5 前後まで下げる]と、きれいな地図になります],
    [Acceleration（縦）], [`2`], [前後の加速の強さ［m/s#super[2]］。小さくすると滑らかに動き出します],
    [Max Velocity（横）], [`2`], [旋回の最大角速度［rad/s］],
    [Acceleration（横）], [`4`], [旋回の加速の強さ［rad/s#super[2]］],
    [Invert axis], [オフ], [倒す向きと動く向きが逆のときにオンにします],
  ),
  caption: [Joystick Teleop の主な項目],
) <tab-vizanti-teleop>

#note[
  #tsuyo[`Diffdrive` を選ぶと、縦・横の軸と速度・加速度がまとめて設定されます。]
  @fig-viz-teleop の値（縦 1 / 2、横 2 / 4）は、その結果として入る値です。
  ロボットに合わせて、あとから個別に変更できます。
]

画面をさらに下へスクロールすると、@fig-viz-teleop-special の
「Special Cases」と「Style」があります。

#figure(
  image("img/viz_teleop_special.png", width: 72%),
  caption: [Joystick Teleop の下半分（Special Cases と Style）],
) <fig-viz-teleop-special>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*項目*], [*出荷時*], [*説明*],
    [Ackermann emulation \ for diffdrive], [オン],
    [後退中だけ左右を反転させ、#tsuyo[自動車のバックと同じ感覚]で操作できるようにします],
    [Instant stop], [オフ],
    [オンにすると、指を離した瞬間に速度 0 を送ります（減速しません）。
     #tsuyo[急停止するため、データ取得では通常オフのまま]にします],
    [Keyboard input], [オフ],
    [キーボード（W / A / S / D）でも操作できるようにします],
    [Colour / Opacity], [白 / `0.6`], [画面上のジョイスティックの見た目],
  ),
  caption: [Joystick Teleop の Special Cases と Style],
) <tab-vizanti-teleop-special>

設定を終えて画面外をクリックすると Vizanti に戻り、
画面下部の丸いジョイスティックをドラッグするとロボットが動きます。

#note[
  ジョイスティックを操作すると、実際に速度指令が送られていることを端末で確認できます。
  ロボットに繋がずに動作だけ試したい場合は、次のコマンドで中身を見られます。

  #terminal[```bash
ros2 topic echo /wizurg/cmd_vel
```]

  下は、ジョイスティックを前方やや右に倒し、その後に離したときの実測値です。
  #tsuyo[離すと自動的に減速して 0 になります]（Instant stop がオフのとき）。

  #console(title: "ジョイスティック操作中の速度指令（実測）")[```
linear.x=0.00 angular.z=0.00       ← 触れる前
linear.x=0.09 angular.z=-0.11      ← 倒し始め
linear.x=0.28 angular.z=-0.32
linear.x=0.56 angular.z=-0.64
linear.x=0.75 angular.z=-0.85      ← 倒しきった状態
linear.x=0.45 angular.z=-0.25      ← 指を離した
linear.x=0.25 angular.z=0.00
linear.x=0.05 angular.z=0.00
linear.x=0.00 angular.z=0.00       ← 停止
```]
]

#danger[
  ジョイスティックは#tsuyo[ブラウザから直接モータを回します]。
  操作する前に、必ずロボットの周囲に人や物がないことを確認してください。
  また、#tsuyo[ブラウザのタブを閉じてもロボットは止まりません]。
  止めるときは、必ずジョイスティックから指を離して速度 0 を送ってから閉じてください。
]

=== 表示に関する注意 <subsubsec-vizanti-limits>

#warn[
  Add Widgets の一覧にある #tsuyo[Point Cloud ウィジェットは、
  RSF の点群を正しく表示できません。]
  追加してもエラーは出ませんが、すべての点が原点の 1 か所に重なってしまいます。
  Vizanti 自身の設定画面にも
  「Currently experimental and might not decode all cloud formats correctly.」
  （実験的な機能であり、すべての点群形式を正しく読めるとは限りません）
  と書かれています。

  #tsuyo[点群を目で確認したいときは、GUI の #btn[Map Viewer]（@sub5）
  または RViz2 を使ってください。]
  データ取得中に「センサが生きているか」を確かめるだけであれば、
  Pose Tracker の軌跡（@fig-viz-overview のオレンジの矢印）が伸びているかで判断できます。
]

#note[
  Vizanti の表示は#tsuyo[真上から見た 2D]です。高さ方向は表示されません。
  3D で確認したい場合は @sub5 の 3D Viewer を使ってください。
]

== 操作手順の説明

以下は、実際に現場で行う一連の操作です。
Vizanti 側の画面の詳細は @subsec-vizanti-ui を参照してください。

+ メイン画面上の #btn[データ取得] ボタンをクリックすると、画面が遷移し、元の画面で表示が変わります。
  その後、@sub18 の #btn[自律走行経路確認Viewer]（Vizanti）を開いてください。
  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 10pt,
      [#figure(image("img/17.png", width: 100%), caption: [データ取得ボタンの位置]) <sub17>],
      [#figure(image("img/18.png", width: 100%), caption: [Vizantiの起動ボタンの位置]) <sub18>],
    ),
    caption: [手動操作モードで扱うボタンの位置],
  ) <im10>

+ Vizanti が開いたら、まず歯車アイコンから #tsuyo[Fixed Frame] に `lio_odom` を選びます
  （@subsubsec-vizanti-fixedframe）。

+ #tsuyo[rosbag の保存先を決めます。]
  フロッピーのアイコン（Bag Recorder）をクリックし、「Save to path：」に

  #terminal[```text
/home/<ユーザ名>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<ROSBAG_NAME>
```]

  を入力します#footnote[「Save to path：」には、`~` を使わず先頭が `/` で始まる絶対パスを入力してください。`<ユーザ名>` の部分は、ロボット側の端末で `whoami` を実行すると確認できます。]。
  `<ROSBAG_NAME>` は自分で決める名前です（ROS 2 ではフォルダ名になります）。
  #tsuyo[実際に作られるフォルダ名の先頭には、記録開始時の日時が自動で付きます]
  （@subsubsec-vizanti-bag）。

  アイコンバーにフロッピーのアイコンが無い場合は、＋ ボタンから
  「Bag Recorder」を追加してください（@subsubsec-vizanti-add）。

+ #tsuyo[記録するトピックを選びます。]
  「Topics：」の中から @tab-bag-topics の 5 つを選び、
  @fig-viz-bag-topics のように青（オン）にします。
  #tsuyo[1 つも選ばないまま記録を始めると、rosbag は作られません]（@err-bag-notopic）。

  #figure(
    stable(
      columns: (auto, auto),
      [*トピック名*#footnote[トピック名はデフォルト値を記載しています。ご使用の設定に合わせて読み替えてください。]], [*メッセージ型*],
      [`/rsf/lio_lidar_rate_odom`], [`nav_msgs/Odometry`],
      [`/hokuyo3d/imu`], [`sensor_msgs/Imu`],
      [`/hokuyo3d/hokuyo_cloud2`], [`sensor_msgs/PointCloud2`],
      [`/fix`], [`sensor_msgs/NavSatFix`],
      [`/gga`], [`nmea_msgs/Gpgga`],
    ),
    caption: [記録対象のトピック一覧],
  ) <tab-bag-topics>

+ #tsuyo[ジョイスティックを準備します。]
  白い丸のアイコン（Joystick Teleop）をクリックし、
  「Topic：」にロボットの速度トピック（出荷時は `/wizurg/cmd_vel`）を選びます。
  続いて「Apply preset：」でロボットの足回りに合った項目を選び、
  速度・加速度の上限を調整します（@tab-vizanti-teleop）。
  アイコンが無い場合は ＋ ボタンから「Teleop Joystick」を追加してください。

  #tip[
    データ取得では、#tsuyo[Max Velocity を 0.5 前後まで下げておく]ことをおすすめします。
    速く走ると点群が粗くなり、地図の精度が落ちます（@subsec-getdata-tips）。
  ]

+ 設定画面の外をクリックして Vizanti の表示画面に戻ります。

+ #tsuyo[記録を開始します。]
  Bag Recorder の #btn[Start recording] を押し、確認に #btn[OK] で答えます。
  「Recording started.」と表示され、アイコンが#tsuyo[赤]になれば記録中です
  （@fig-viz-recstate）。

+ #tsuyo[ロボットを走らせます。]
  画面下部のジョイスティックをドラッグして操縦します。
  オレンジ色の軌跡が伸びていれば、データが正常に取れています（@fig-viz-overview）。

+ #tsuyo[記録を停止します。]
  Bag Recorder のアイコンをクリックし、赤い #btn[Stop recording] を押します。
  「Recording stopped.」と表示されれば完了です。

+ Vizanti のブラウザタブを閉じてください。

+ @sub3 の #btn[ロボット停止] を押して、RSF の ROS ノードとモータドライバを停止させてください。
  「データ取得」で起動したターミナルが自動ですべて閉じられ、
  GUI サーバのターミナルに、ノードがキルされた文言が表示されます。
  その後、GUI は @sub3 の「現在のモード」が「停止モード」となります。

+ 最後に、記録された rosbag のフォルダができているかを確認します。
  「ファイル管理」画面のファイル選択、または次のコマンドで確認できます。

  #terminal[```bash
ls -lt ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/ | head
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<日時付きの名前>
```]

  #console(title: "記録できているときの表示例")[```
Files:             2026-08-27-15-19-kato-support_0.mcap
Bag size:          23.7 MiB
Storage id:        mcap
Duration:          30.398083002s
Messages:          15662
Topic information: Topic: /fix | Type: sensor_msgs/msg/NavSatFix | Count: 16 | ...
                   Topic: /gga | Type: nmea_msgs/msg/Gpgga | Count: 16 | ...
                   Topic: /hokuyo3d/hokuyo_cloud2 | Type: sensor_msgs/msg/PointCloud2 | Count: 293 | ...
                   Topic: /hokuyo3d/imu | Type: sensor_msgs/msg/Imu | Count: 15045 | ...
                   Topic: /rsf/lio_lidar_rate_odom | Type: nav_msgs/msg/Odometry | Count: 292 | ...
```]

  #warn[
    #tsuyo[`Count:` が `0` のトピックがある場合、そのセンサのデータは入っていません。]
    このまま地図を作っても失敗します。センサの接続を確認してから記録し直してください
    （@err-no-sensor）。
  ]

== 良いデータを取るためのこつ <subsec-getdata-tips>

ここで記録したデータの品質が、あとの工程すべてに影響します。
やり直すには現場での再走行が必要になるため、次の点に注意してください。

#tip[
  - #tsuyo[記録を始める前にトピックが流れているか確認する。]
    センサが繋がっていないまま走ると、空の rosbag ができるだけです（@err-no-sensor）。
  - #tsuyo[ゆっくり走る。] 速く走ると点群が粗くなり、地図の精度が落ちます。
  - #tsuyo[急旋回を避ける。] その場での高速な回転は LIO の誤差の原因になります。
  - #tsuyo[出発点に戻ってくる。] 経路が輪になるように走ると、
    地図作成時に前後のつじつまを合わせやすくなり、ゆがみが減ります。
  - #tsuyo[GNSS を使う場合は、空の開けた場所から走り始める。]
    最初に精度の良い位置が得られると、地図全体の精度が上がります。
  - #tsuyo[走行距離が短すぎないようにする。] 数メートルでは地図になりません（E-304）。
]

記録を始める前に、次のコマンドで主要なトピックが流れていることを確認してください。
数値が表示され続ければ正常です。

#terminal[```bash
ros2 topic hz /hokuyo3d/hokuyo_cloud2
ros2 topic hz /rsf/lio_lidar_rate_odom
ros2 topic hz /fix
```]

== うまくいかないときは <subsec-getdata-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [ジョイスティックを操作してもロボットが動かない], [@err-motor-jog],
    [モータドライバの端末がすぐ閉じる], [@err-motor-driver],
    [rosbag が記録されない、ファイルが空になる], [@err-bag-empty],
    [「Recording started.」と出るのに rosbag ができない], [@err-bag-notopic],
    [センサのデータがまったく届かない], [@err-no-sensor],
    [GNSS の精度が上がらない], [@err-no-gnss],
    [Vizanti の画面が真っ白で何も出ない], [@err-vizanti],
    [Vizanti のトピック一覧がどこも空で選べない], [@err-vizanti-rosapi],
    [Vizanti に点群が表示されない], [@err-viz-pointcloud],
    [「ロボット停止」が押せない・GUI が反応しない], [@subsec-nav-stop],
  ),
  caption: [データ取得でよくある症状],
) <tab-getdata-trouble>

#pagebreak()