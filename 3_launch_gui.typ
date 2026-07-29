#import "utils.typ": terminal

= GUIアプリケーションの起動 <sec-gui>

本章では、GUIアプリケーションの起動方法について説明します。
GUIアプリケーションは、ロボットの状態を可視化し、経路設計や地図の編集などの操作を行うためのツールです。
GUIアプリケーションを使用する前に、ファイアーウォールの設定を行い、GUIサーバを起動する必要があります。

== ファイアーウォール設定
GUIアプリケーションは、通信するために特定のポートを使用します。
ファイアーウォールの設定を行い、@tab-used-ports のポートを開放してください。

#figure(
  table(
    columns: (auto, auto, 1fr),
    inset: 8pt,
    align: horizon,
    stroke: (x, y) => if y == 0 { (bottom: 1pt) } else if y == 1 { (bottom: 0.5pt) } else { none },
    [*ポート番号*], [*プロトコル*], [*用途*],
    [5000, 5001], [TCP], [GUI サーバー / API 通信],
    [5050],       [TCP], [GUI メタデータ管理],
    [9090],       [TCP], [rosbridge (Vizanti 通信用)],
    [10940],      [TCP], [システム内部通信],
    [7400--7800], [UDP], [ROS 2 (DDS) Discovery 通信],
  ),
  caption: [使用ポート一覧],
) <tab-used-ports>

=== Ubuntuでの設定例
Ubuntu標準のファイアーウォール管理ツール `ufw` を使用する場合、以下のコマンドを実行して設定を適用します。

#terminal[```bash
# 各種TCPポートの開放
sudo ufw allow 5000,5001,5050,8000,9000,9090,10940/tcp

# ROS 2通信用UDPポートの開放
sudo ufw allow 7400:7800/udp

# 設定の有効化と状態確認
sudo ufw enable
sudo ufw status
```]

※ ネットワーク環境（社内LANなど）によっては、ルータや上位のファイアーウォール側で同様の許可設定が必要になる場合があります。
詳細な手順については、ネットワーク管理者に問い合わせるか、オペレーティングシステムのドキュメントを参照してください。

== GUIサーバの起動

以下のコマンドでGUIサーバを起動します。
#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./start_server.sh
```]

起動が成功すると @im1 のような2つの端末が開きます。これらはすぐに最小化されます。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    figure(image("img/1.png", width: 100%), caption: [メイン画面, 3D Viewerの起動端末]),
    figure(image("img/2.png", width: 100%), caption: [Vizantiの起動端末]),
  ),
  caption: [GUIサーバ起動後の2つの端末],
) <im1>

サーバの起動後、下記リンクをブラウザで開いて、GUIアプリケーションにアクセスしてください。
- #link("http://localhost:5050")

== GUIサーバの停止

以下のコマンドでGUIサーバを停止します。
#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh
```]

== GUIの説明

GUIアプリケーション画面は、主にメイン画面、3D Viewer、Vizanti、ファイル管理の4つで構成されています。

/ メイン画面: メインの操作画面で、@sub3 に示します。ROSノードの起動、3D Viewerの表示、「自律走行経路確認Viewer」(以降 `Vizanti` と呼ぶ)、各種設定や状態の確認が可能です。
  メイン画面の操作方法に関しては、@sec-config や、@sec-get-data、@sec-mapping や@sec-2d-map 等を参照してください。

  #figure(
    image("img/3.png", width: 50%),
    caption: [メイン画面],
  ) <sub3>

  #text(size: 9pt)[
  - 現在のモード： アプリケーションの起動状態を表示します。「現在のモード」は下記3種類あります。
  - 停止モード： デフォルトの状態で、ROSノードやモータドライバは起動していません。
  - 手動操作モード： ROSノードとモータドライバが起動しており、ROSトピック(`/wizurg/cmd_vel`)を介して手動でロボットを操作できる状態です。
  - サーバ接続なし： サーバが起動していない状態で、GUIアプリケーションがサーバに接続できない場合に表示されます。サーバを再起動すると、「停止モード」に戻ります。
  ]

/ Vizanti: @sub3 に示す、「自律走行経路確認Viewer」をクリックすると、@sub4 に示す、「Vizanti」画面が表示されます。
  「Vizanti」は、ROS 1/ROS 2のトピックをウェブ上で可視化するためのツールです。2D地図/経路(以下waypointと呼ぶ)の表示、rosbagの取得などが可能です。

  #figure(
    image("img/4.png", width: 55%),
    caption: [Vizanti],
  ) <sub4>

/ 3D Viewer: @sub3 の 「Map Viewer」をクリックすると、@sub5 に示す「3D Viewer」が表示されます。
  「3D Viewer」は、地図、2D地図の表示とwaypointの編集をするためのツールです。3次元上に3D地図・2D地図・2D経路(waypoint)を重ねて表示可能です。
  表示可能なファイル形式は、pcd, pgm(yaml必須), json形式の waypoint のみです。

  #figure(
    image("img/5.png", width: 50%),
    caption: [3D Viewer],
  ) <sub5>

/ ファイル管理: 過去に作成したデータの管理を行う画面です。不要になった古い地図やwaypointを削除したり、名前を変更したりできます。詳細に関しては、@sec-config を参照してください。

#figure(
  image("img/6.png", width: 55%),
  caption: [ファイル管理],
) <sub6>

#pagebreak()