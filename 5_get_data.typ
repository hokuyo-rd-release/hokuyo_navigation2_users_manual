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

== 操作手順の説明
+ メイン画面上の「データ取得」ボタンをクリックすると、画面が遷移し、元の画面で表示が変わります。その後、@sub18 の自律走行経路確認Viewer(Vizanti) を開いてください。
  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 10pt,
      [#figure(image("img/17.png", width: 100%), caption: [データ取得ボタンの位置]) <sub17>],
      [#figure(image("img/18.png", width: 100%), caption: [Vizantiの起動ボタンの位置]) <sub18>],
    ),
    caption: [手動操作モードで扱うボタンの位置 1],
  ) <im10>
+ @sub19 のrosbag 取得ボタンをクリックして、rosbag の保存名を「Save to path：」に #path[/home/\<ユーザ名\>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/\<ROSBAG_NAME\>] を入力し#footnote[「Save to path：」には、`~` を使わず先頭が `/` で始まる絶対パスを入力してください。`<ユーザ名>` の部分は、端末で `whoami` を実行すると確認できます。]、(` <ROSBAG_NAME> ` はROS2のためディレクトリ名)「Topics：」に @tab-bag-topics の rostopic を選択し、@sub20 の「start recording」 ボタンを押して下さい。rosbag 取得ボタンが表示されていない場合は「＋」ボタンをクリックし、@sub22 の画面を表示し、「Bag Recorder」を表示させて下さい。record ボタンを押すと、recording が開始され、@sub22 のようにアイコンの表示が赤に変わります。
  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 10pt,
      [#figure(image("img/19.png", width: 100%), caption: [rosbag取得ボタン]) <sub19>],
      [#figure(image("img/20.png", width: 100%), caption: [start recording ボタンの位置]) <sub20>],
      [#figure(image("img/21.png", width: 100%), caption: [stop recording ボタンの位置]) <sub21>],
      [#figure(image("img/22.png", width: 100%), caption: [Bag Recordボタンの表示]) <sub22>],
    ),
    caption: [手動操作モードで扱うボタンの位置 2],
  ) <im11>

  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 10pt,
      [#figure(image("img/23.png", width: 100%), caption: [Teleop Joystickのアイコン]) <sub23>],
      [#figure(image("img/24.png", width: 100%), caption: [Teleop Joystick の位置]) <sub24>],
    ),
    caption: [バーチャルジョイスティックの設定方法],
  ) <im12>

  #figure(
    table(
      columns: (auto, auto),
      inset: 8pt,
      align: center + horizon,
      fill: (x, y) => if y == 0 { rgb("#00A1E9").lighten(90%) } else { none },
      stroke: (x, y) => if y == 0 { (bottom: 1.5pt + rgb("#00A1E9")) } else if y == 1 { (bottom: 0.5pt + gray) } else { (bottom: 0.1pt + luma(240)) },
      [*トピック名*#footnote[トピック名はデフォルト値を記載しています。]], [*メッセージ型*],
      [`/rsf/lio_lidar_rate_odom`], [`nav_msgs/Odometry`],
      [`/hokuyo3d/imu`], [`sensor_msgs/Imu`],
      [`/hokuyo3d/hokuyo_cloud2`], [`sensor_msgs/PointCloud2`],
      [`/fix`], [`sensor_msgs/NavSatFix`],
      [`/gga`], [`nmea_msgs/Gpgga`],
    ),
    caption: [記録対象のトピック一覧],
  ) <tab-bag-topics>

+ rostopic 選択画面外をクリックしてVizantiに戻ってください。
+ @sub22 の画面からジョイスティックの「＋」アイコンを選択し、Vizantiでバーチャルジョイスティックを表示させてください。
+ @sub23 のバーチャルジョイスティックのアイコンを選択して、ロボットの速度トピック名を選択して、Vizanti に戻ると、バーチャルジョイスティックがrostopicをパブリッシュします。速度の機構のいくつかに対応しています。ロボットの足回りに合わせて Apply preset を選択し、加速度、速度の上限・下限を調整して下さい。
+ rosbag の取得を実行している間に、バーチャルジョイスティックでロボットを操作して、rosbag の記録作業を行います。
+ データ取得が完了したら @sub21 の Vizanti の rosbag取得アイコンをクリックして stop recording をクリックして rosbag の取得を終了して下さい。
+ Vizanti のブラウザタブを閉じて下さい。
+ @sub3 「ロボット停止」を押して、RSFのROSノードとモータドライバを停止させて下さい。「データ取得」で起動したターミナルが自動で全て閉じられ、GUIサーバのターミナルに、ノードがキルされた文言が表示されます。その後、GUIは @sub3 の現在のモードが「停止モード」となります。

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
    [センサのデータがまったく届かない], [@err-no-sensor],
    [GNSS の精度が上がらない], [@err-no-gnss],
    [Vizanti の画面が真っ白で何も出ない], [@err-vizanti],
    [「ロボット停止」が押せない・GUI が反応しない], [@subsec-nav-stop],
  ),
  caption: [データ取得でよくある症状],
) <tab-getdata-trouble>

#pagebreak()