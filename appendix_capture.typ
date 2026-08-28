#import "utils.typ": *

= 画面キャプチャ一覧 <sec-appendix-capture>

本書に掲載している画面は、@tab-capture-source の 3 つの経路で用意しています。
改訂時の差し替えの目安としてご利用ください。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*経路*], [*内容*], [*差し替え*],
    [実機操作画面],
    [GUI サーバを起動し、ブラウザ上の画面をそのまま取得したもの],
    [随時可能],
    [実データ実行],
    [収録済みの rosbag と地図を用いて処理を実行し、
     端末出力・RViz2 画面・2D 地図を取得したもの],
    [随時可能],
    [現場撮影],
    [実際のロボットが動いている様子など、
     #tsuyo[現場でしか撮影できないもの]],
    [要撮影],
  ),
  caption: [掲載画面の出所],
) <tab-capture-source>

== 現場でしか撮影できないもの <subsec-capture-field>

次の内容は、実機が現場で稼働していないと撮影できません。
掲載できると本書の分かりやすさが向上します。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ID*], [*ファイル名*], [*撮影内容と条件*],

    [F-01], [`field_running.png`],
    [経路に沿って実際に自律走行しているロボットの外観。
     周囲の環境（屋外／屋内）が分かる画角で],

    [F-02], [`field_teleop.png`],
    [データ取得時に、タブレットのバーチャルジョイスティックで
     ロボットを手動操作している様子（@sec-get-data）],

    [F-03], [`field_rsf.png`],
    [ロボットに搭載された RSF-X001 の取り付け状態。
     ケーブルの取り回しが分かるもの],

    [F-04], [`field_estop.png`],
    [非常停止スイッチの位置。@subsec-safety の安全説明に使用],

    [F-05], [`nav_terminal_field.png`],
    [現場で自律走行を開始したときの端末。
     `ウェイポイント追従を開始します:` 以降が写っているもの
     （@subsubsec-nav-inside の掲載例と差し替え）],
  ),
  caption: [現場での撮影依頼一覧],
) <tab-capture-field>

== 掲載済みの画面 <subsec-capture-placed>

本書に掲載している主な画面の一覧です。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*章*], [*掲載内容*], [*出所*],
    [@sec-gui], [メイン画面（停止／手動操作／サーバ接続なし）、
                 各ボタンの選択画面、エラーの帯], [実機操作画面],
    [@sec-config], [設定ファイル管理、テキスト編集、シナリオ編集], [実機操作画面],
    [@sec-config], [マッピング開始時の設定値一覧], [実データ実行],
    [@sec-get-data], [Vizanti の全画面（アイコンバー、ウィジェット追加、
                      Global Settings、TF、Pose Tracker、Bag Recorder、
                      Joystick Teleop）], [実機操作画面],
    [@sec-get-data], [rosbag 記録中のジョイスティック操作、記録中のアイコン], [実機操作画面],
    [@sec-mapping], [マッピング実行時の端末出力（正常時・失敗時）], [実データ実行],
    [@sec-mapping], [GNSS 品質ログの内容], [実データ実行],
    [@sec-waypoint], [3D Viewer の表示と編集], [実機操作画面],
    [@sec-2d-map], [2D 地図の良い例・悪い例（同一点群から生成）], [実データ実行],
    [@sec-navigation], [自律走行の開始画面、RViz2 画面、状態表示の文字], [実データ実行],
    [@sec-files], [ファイル管理、ROS Bag ブラウザ、変換設定画面], [実機操作画面],
  ),
  caption: [掲載済み画面の一覧],
) <tab-capture-placed>

== 画面を取り直す手順 <subsec-capture-howto>

GUI の画面は、GUI サーバを起動した状態でブラウザから取得できます。

#fstep(1, [GUI サーバを起動する], [
  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./start_server.sh
```]
])
#fstep(2, [ブラウザで対象の画面を開く], [
  #link("http://localhost:5050")[`http://localhost:5050`] から
  該当のボタンをたどります。
])
#fstep(3, [撮影して差し替える], [
  撮影した画像を #path[img/] に、既存と同じファイル名で上書き保存します。
  ファイル名を変える場合は、該当する章の `image("img/...")` も書き換えてください。
])

#note[
  Vizanti の画面（@subsec-vizanti-ui）は、
  #link("http://localhost:5000")[`http://localhost:5000`] から取得します。
  #tsuyo[ロボットのノードが起動していないと、トピックの一覧が空のまま]になり、
  Bag Recorder や Joystick Teleop の設定画面を撮影できません。
  必ず #btn[データ取得] でノードを起動した状態、または rosbag を再生した状態で
  撮影してください。
]

#note[
  端末の出力は、画面を撮影するよりも
  #tsuyo[文字をそのまま本文に貼り付けるほう]が読みやすくなります。
  本書では `#console(...)` の黒い枠がその用途です。
]

#pagebreak()
