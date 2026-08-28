#import "utils.typ": *

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
    [5050],       [TCP], [GUI サーバー (ブラウザからのアクセス先)],
    [5000, 5001], [TCP], [Vizanti サーバー],
    [9090],       [TCP], [rosbridge (ブラウザと ROS 2 の中継)],
    [10940],      [TCP], [RSF センサとの通信],
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
1つ目が GUI サーバ、2つ目が Vizanti サーバの端末です。

GUI サーバ側の端末に、次の2行が表示されていれば起動に成功しています。

#console(title: "GUI サーバの端末（起動成功時）")[```
Flask Server starting at http://0.0.0.0:5050
WebSocket Proxy server started at ws://0.0.0.0:5050/ws
```]

#warn[
  これらの端末は#tsuyo[閉じないでください]。
  閉じるとサーバが停止し、GUI が「サーバ接続なし」の表示になります（@err-gui-noserver）。
  邪魔な場合は最小化してください。
]

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    figure(image("img/1.png", width: 100%), caption: [メイン画面, 3D Viewerの起動端末]),
    figure(image("img/2.png", width: 100%), caption: [Vizantiの起動端末]),
  ),
  caption: [GUIサーバ起動後の2つの端末],
) <im1>

サーバの起動後、ブラウザを開いて GUI アプリケーションにアクセスしてください。

/ ロボット搭載パソコンで操作する場合: #link("http://localhost:5050")
/ 別のパソコンやタブレットから操作する場合: `http://<ロボット側パソコンのIPアドレス>:5050`

#tip[
  ロボット側パソコンの IP アドレスは、次のコマンドで確認できます。
  表示された番号（例 `192.168.0.20`）を使って
  `http://192.168.0.20:5050` のように入力してください。

  #terminal[```bash
hostname -I
```]

  画面が開かない場合は @err-gui-noaccess を参照してください。
]

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

  画面上部の「現在のモード」には、システムの状態が表示されます。
  #tsuyo[いま何が動いているかは、必ずここで確認してください。]
  モードは @tab-gui-modes の5種類です。

  #figure(
    stable(
      columns: (auto, 1fr, auto),
      [*表示*], [*状態*], [*押せるボタン*],

      [停止モード],
      [初期状態。ROS ノードもモータドライバも起動していません。
       各種の操作を開始できます],
      [すべて],

      [手動操作モード],
      [「データ取得」で起動した状態。ROS ノードとモータドライバが動いており、
       Vizanti のジョイスティックで手動操作できます],
      [ロボット停止 \ Map Viewer],

      [マッピングモード],
      [マッピング処理を実行中の状態],
      [ロボット停止 \ Map Viewer],

      [自律走行モード],
      [自律走行を実行中の状態],
      [ロボット停止 \ Map Viewer],

      [サーバ接続なし],
      [GUI サーバに接続できていない状態。
       サーバが停止しているか、起動端末を閉じてしまった場合に表示されます],
      [—],
    ),
    caption: [「現在のモード」の表示],
  ) <tab-gui-modes>

  実際の画面を @im-gui-modes に示します。
  #tsuyo[ボタンの色と、上部の文字の両方で状態が分かります。]

  #figure(
    grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      gutter: 4pt,
      [#figure(
        image("img/g_main_stopped.png", width: 100%),
        caption: [停止モード],
      ) <sub-mode-stopped>],
      [#figure(
        image("img/g_main_ctrl.png", width: 100%),
        caption: [手動操作モード],
      ) <sub-mode-ctrl>],
      [#figure(
        image("img/g_main_mapping.png", width: 100%),
        caption: [マッピングモード],
      ) <sub-mode-mapping>],
      [#figure(
        image("img/g_main_running.png", width: 100%),
        caption: [自律走行モード],
      ) <sub-mode-running>],
      [#figure(
        image("img/g_main_noserver.png", width: 100%),
        caption: [サーバ接続なし],
      ) <sub-mode-noserver>],
    ),
    caption: [「現在のモード」ごとのメイン画面。
              停止モード以外では 4 つのボタンが灰色になる],
  ) <im-gui-modes>

  #note[
    停止モード以外では、誤操作を防ぐために
    #btn[データ取得] #btn[マッピング] #btn[自律走行] #btn[ファイル管理]
    の4つが灰色になり押せなくなります。#tsuyo[これは異常ではありません]（@err-btn-disabled）。
    別の操作をしたいときは、先に #btn[ロボット停止] を押して停止モードに戻してください。

    #tsuyo[#btn[ロボット停止] と #btn[Map Viewer] は、どのモードでも押せます。]
    走行中に地図や経路を確認したいときは #btn[Map Viewer] を使ってください。
  ]

  === ボタンを押したあとに開く画面 <subsubsec-gui-popups>

  #btn[マッピング]、#btn[自律走行]、#btn[ファイル管理] は、
  押すと @im-gui-popups の選択画面が重ねて表示されます。
  #tsuyo[この時点ではまだ何も実行されていません。]
  選択画面を閉じたい場合は #btn[閉じる] を押してください。

  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      [#figure(
        image("img/g_popup_mapping.png", width: 100%),
        caption: [#btn[マッピング] の選択画面],
      ) <sub-popup-mapping>],
      [#figure(
        image("img/g_popup_filemgmt.png", width: 100%),
        caption: [#btn[ファイル管理] の選択画面],
      ) <sub-popup-files>],
    ),
    caption: [ボタンを押したあとに表示される選択画面],
  ) <im-gui-popups>

  #figure(
    stable(
      columns: (auto, auto, 1fr),
      [*ボタン*], [*開く画面*], [*内容*],
      [#btn[データ取得]], [—],
      [選択画面はなく、#tsuyo[すぐにセンサとモータドライバが起動します]（@sec-get-data）],
      [#btn[マッピング]], [@sub-popup-mapping],
      [`p2o` / `lio_raw` / `pcd2pgm` から選びます（@sec-mapping、@sec-2d-map）],
      [#btn[自律走行]], [@sub-popup-nav],
      [安全確認のチェックと、地図・経路・走行モードを選びます（@sec-navigation）],
      [#btn[ファイル管理]], [@sub-popup-files],
      [マップ / ウェイポイント / 設定ファイルの管理へ進みます（@sec-files）],
    ),
    caption: [各ボタンを押したときの動作],
  ) <tab-gui-buttons>

  #danger[
    #btn[データ取得] だけは#tsuyo[確認画面がなく、押した瞬間にロボットが動く準備に入ります]。
    周囲の安全を確認してから押してください。
  ]

  #figure(
    image("img/g_popup_nav_unchecked.png", width: 58%),
    caption: [#btn[自律走行] の選択画面。3 つすべてにチェックを入れるまで
              #btn[自律走行開始] は灰色のまま押せない],
  ) <sub-popup-nav>

  #warn[
    「サーバ接続なし」と表示された場合は、GUI サーバが落ちています。
    ブラウザを再読み込みしても直りません。@err-gui-noserver の手順でサーバを再起動してください。
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

== 実行を開始したときの画面 <subsec-gui-started>

#btn[データ取得]、マッピング、自律走行を開始すると、
それぞれ @im-gui-started の画面が新しいタブに表示されます。
#tsuyo[この画面が出れば、処理の起動までは成功しています。]

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 6pt,
    [#figure(
      image("img/g_msg_ctrl.png", width: 100%),
      caption: [データ取得の開始],
    ) <sub-msg-ctrl>],
    [#figure(
      image("img/g_msg_mapping.png", width: 100%),
      caption: [マッピングの開始],
    ) <sub-msg-mapping>],
    [#figure(
      image("img/g_msg_nav.png", width: 100%),
      caption: [自律走行の開始],
    ) <sub-msg-nav>],
  ),
  caption: [処理を開始したときに表示される画面],
) <im-gui-started>

#warn[
  #tsuyo[この画面は「起動を指示した」ことしか意味しません。]
  処理が正しく進んでいるかは、同時に開く#tsuyo[端末の表示]で確認してください。
  端末が 1 つも開かない場合は @err-noterm を参照してください。
]

#note[
  これらのタブは、内容を確認したら閉じてかまいません。
  #tsuyo[ただし、処理を実行している端末は閉じないでください。]
  閉じると処理が途中で止まります。
]

== うまくいかないときは <subsec-gui-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [ブラウザで画面が開かない], [@err-gui-noaccess],
    [「サーバ接続なし」と表示される], [@err-gui-noserver],
    [ボタンが灰色で押せない], [@err-btn-disabled],
    [Vizanti が真っ白で何も表示されない], [@err-vizanti],
    [Vizanti のトピック一覧が空で選べない], [@err-vizanti-rosapi],
    [Map Viewer に地図や経路が出ない], [@err-viewer-noload],
    [ファイル選択画面でフォルダを開けない], [@err-path-denied],
    [ファイル名を変更できない], [@err-rename],
  ),
  caption: [GUI でよくある症状],
) <tab-gui-trouble>

=== エラーはどこに表示されるか <subsubsec-gui-flash>

GUI での操作に失敗すると、@im-gui-flash のように
#tsuyo[画面の上部に色の付いた帯]でメッセージが表示されます。
#tsuyo[エラーが出たときは、まずこの帯の文言を読んでください。]
そのままの文言で @sec-trouble から探すのが最短です。

#figure(
  image("img/g_flash_error.png", width: 88%),
  caption: [操作に失敗したときの表示（赤い帯がエラーメッセージ）],
) <im-gui-flash>

#figure(
  stable(
    columns: (auto, 1fr),
    [*色*], [*意味*],
    [赤], [エラー。#tsuyo[操作は実行されていません]],
    [黄], [警告。一部だけ実行されています。結果を必ず確認してください],
    [青], [案内。次に何をすればよいかの指示です],
    [緑], [成功。操作は完了しています],
  ),
  caption: [帯の色と意味],
) <tab-gui-flash-colors>

#warn[
  帯は#tsuyo[ページを切り替えると消えます]。
  読み逃した場合は、同じ操作をもう一度行って文言を確認してください。
  色と意味の詳細は @err-flash を参照してください。
]

#pagebreak()