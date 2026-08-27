#import "utils.typ": *

= 経路設計 <sec-waypoint>
@sec-mapping の実施後を想定し、@im16 の画面の続きから説明します。
本章では、マッピングで生成された waypoint の形式の説明と、waypointの編集を3D Viewer から行う操作手順を説明します。
waypoint とは、ロボットの目的地点のことであり、本システムでは、目標位置、目標姿勢、属性、到着判定の許容誤差, 角度許容誤差から構成されます。
3D Viewer 上では、@im17 の緑色の球体と黄色の矢印からなり、球体部分を選択すると、青色の半円「ギズモ」が表示されます。すると、画面左に「選択中のウェイポイント」というウィジェットが表示され、waypointに関する編集が可能となります。

#figure(
  image("img/32.png", width: 90%),
  caption: [3D Viewer で waypointを選択した場合の画面],
) <im17>

== 経路の形式 <subsec-way-format>
waypointファイルはjson形式で、下記の通りです。

#terminal[```json
[
  [position_x, position_y, position_z],
  [orientation_x, orientation_y, orientation_z, orientation_w],
  {
    "type": "normal",      // 属性タイプ ("normal", "stop", "slow")
    "value": 0,            // 属性の値 (停止時間[s] や 制限速度[m/s])
    "xy_tolerance": 0.25,  // 到着判定の距離許容誤差 [m]
    "yaw_tolerance": 0.25  // 到着判定の角度許容誤差 [rad]
  }
]
```]

/ `position`: 2D地図上の2次元の位置です。z座標は0.0です。`x, y, z` は、3D Viewer 上の `origin` を原点とした相対座標です。原点と緯度経度高度の対応付けがされています。\
/ `orientation`: 2D地図上の2次元の姿勢です。`orientation_x` と `orientation_y` は0.0です。\
/ `type`: waypoint 到着時の制御パターン(属性)です。属性は、以下3種類あります。
  - `normal`: 通過
  - `stop`: 指定秒数停止
  - `slow`: 次のwaypointまで指定速度まで減速します。\
/ `value`: 属性の値、停止時間 [s] や 制限速度 [m/s] です。\
/ `xy_tolerance`: 到着判定の距離許容誤差 [m] です。\
/ `yaw_tolerance`: 到着判定の角度許容誤差 [rad] です。

== 3D Viewer での編集方法
- 「メイン画面」から「Map Viewer」をクリックし、@sub30 の画面を開きます。

+ @sub30 の状態から 「ウェイポイントファイル」「PCDファイル」のプルダウンからそれぞれファイルを選び、編集したいwaypointファイルと、周囲の環境を確認するための3D点群地図を選択します。
+ @im16 のように3D点群地図とwaypointが表示されたら、waypoint を選択し、@im17 に示す、「選択中のウェイポイント」ウィジェットと、ギズモが表示されているか確認して下さい。

== 3D Viewer の基本操作
=== ファイルの読み込み
@im18 の「Grid & Map Settings」から行います。

#figure(
  image("img/35.png", width: 65%),
  caption: [基本編集画面],
) <im18>

/ ロード: PCD、PGM、waypoint形式のjsonファイルを読み込みます。これら3種類のファイルを同時に読み込み重ねて編集できます。各種類に対して一つのファイルが編集可能です。\
/ アンロード: @im18 に示す、「アンロード」ボタンをクリックすると読み込んだファイルを閉じることができます。
  「アンロード」ボタンをクリックした後に、@im22 の画面で、チェックリストを外して、「選択した要素をアンロード」をクリックすると、チェックを外したファイルを閉じます。

#figure(
  image("img/38.png", width: 65%),
  caption: [アンロード],
) <im22>

=== 選択・回転・移動
waypointの球体部分を選択したまま画面をドラッグするとwaypointの位置を移動することができます。
ギズモはwaypointの2D姿勢調整用の回転ハンドルとして使用します。ギズモの線を選択したまま画面をドラッグすると、waypoint の姿勢を変更することができます。

=== 属性設定
@sub32 の「選択中のウェイポイント」ウィジェットからは、位置と向きの編集と、属性の編集が可能です。位置と向きは、waypointの基本操作を行うとそちらが上書きされます。位置と向きの編集は、テキストボックスとなっているため、必要な数値を入力してください。
位置は、`origin` を基準座標とした相対座標で入力してください。デフォルトの設定では、waypoint 同士の間隔が表示されるため、こちらもご参考下さい。`yaw` に関しては、-180 ～ 180 の範囲で入力してください。

=== 追加・削除・保存
waypointの追加・削除は、@im18 に示す基本編集画面から行います。

/ 追加: @im18 Waypoint Editing から編集します。
  - 末尾に追加： 連番の最後のwaypointを追加します。
  - 先頭に追加： 連番の最初のwaypointを追加します。
  - 選択中の後に追加： waypointを選択すると有効化されます。選択したwaypointの次の連番に追加されます。
  
  同様の操作のため、例として「選択中の後に追加」を説明します。
  + 「選択中の後に追加」ボタンをクリックします。
  + @im20 ボタンがオレンジ色に変わり、地図中の平面上をクリックすると waypoint が設置されます。キーボードのescを押すか、オレンジ色のボタンのどれかを再度クリックするとwaypointを追加する操作をキャンセルできます。
  + waypoint 設置後は、ボタンが元の色に戻り、再度追加可能になります。

#figure(
  image("img/36.png", width: 100%),
  caption: [waypointの追加押下後の画面],
) <im20>

/ 削除: waypoint を削除します。
  + waypoint を選択します。
  + 「選択中のウェイポイントを削除」ボタンをクリックします。
  + @im21 に示すように、ブラウザにポップアップが表示されるため、OKを押すとwaypointが削除されます。

#figure(
  image("img/37.png", width: 100%),
  caption: [waypointの削除押下後の画面],
) <im21>

/ 保存: 編集中のwaypoint を保存します。\
/ ビューワ終了: 3D Viewer を終了します。waypoint は編集時に自動で保存されますが、万が一の場合に備えて、このボタンを押す前に必ず「ウェイポイントを保存」ボタンをクリックしてwaypointを保存してください。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/34.png", width: 100%), caption: [選択時のギズモ(回転状態)]) <sub31>],
    [#figure(image("img/33.png", width: 100%), caption: [「選択中のウェイポイント」ウィジェット]) <sub32>],
  ),
  caption: [waypointの属性],
) <im19>

=== 便利機能
「Waypoint Editing」のその他の機能について説明します。\
/ 次のWPを指す: @sub33 の状態でリストにチェックを入れると、@sub34 のように、すべてのwaypointが次の連番のwaypointの座標に向くように一括で姿勢を調整します。
  リストにチェックを入れたままwaypointを位置を調整しても、次の連番のwaypointへの方向を保ったまま、姿勢が自動で調整されます。\
/ 距離ラベル表示: リストにチェックを入れるとすべてのwaypointが次の連番のwaypointとの距離ラベルを表示します。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/40.png", width: 100%), caption: [「次のWPを指す前」有効化前]) <sub33>],
    [#figure(image("img/41.png", width: 100%), caption: [「次のWPを指す」有効化後]) <sub34>],
  ),
  caption: [waypointの一括向き修正],
) <im23>

== 経路を設計するときの注意 <subsec-waypoint-tips>

#danger[
  ここで作る経路は、#tsuyo[ロボットが実際にたどる道筋]です。
  次の点を必ず確認してください。
  - 経路が壁・柱・段差・落下の危険がある場所に近すぎないこと
  - ロボットの車体幅と、旋回に必要な余裕が確保されていること
  - 人の通り道を横切る箇所では、`stop` または `slow` 属性を設定すること
]

#tip[
  - 到着判定の許容誤差 `xy_tolerance` は、#tsuyo[小さくしすぎない]でください。
    小さすぎると、その地点の手前で前後に細かく動き続けて進まなくなります（@err-wp-stuck）。
    通過するだけの地点なら 0.25〜1.0 [m] 程度が目安です。
  - 向きの許容誤差 `yaw_tolerance` は、通過するだけの地点であれば
    大きめ（3.14 [rad]）にしておくと、余計な旋回をせずに済みます。
  - 経路点の間隔が細かすぎる場合は、マッピング時の `wp_save_distance` を
    大きくして作り直すほうが早い場合があります（@tab-ref-mapping-params）。
  - 「次のWPを指す」を使うと、すべての経路点の向きを一括で整えられます。
    手作業で1つずつ回すより確実です。
]

#warn[
  編集した経路は、#btn[ビューワ終了] を押す前に必ず
  #btn[ウェイポイントを保存] をクリックして保存してください。\
  また、経路を変更したあとに 2D 地図の通行可能領域を反映させたい場合は、
  #tsuyo[@sec-2d-map の 2D 地図変換をやり直す]必要があります。
  経路だけを変更しても、2D 地図は自動では更新されません。
]

== うまくいかないときは <subsec-waypoint-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [走行時、ある地点の手前で行ったり来たりして進まない], [@err-wp-stuck],
    [「waypoint_managerが異常終了しました」と繰り返される], [@err-wp-manager],
    [3D Viewer に経路が表示されない], [@err-viewer-noload],
    [経路ファイルの名前を変更できない], [@err-rename],
  ),
  caption: [経路設計でよくある症状],
) <tab-waypoint-trouble>

#pagebreak()