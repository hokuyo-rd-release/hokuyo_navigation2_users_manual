#import "utils.typ": *

= トラブルシューティング <sec-trouble>

本章では、実際に起こりうるエラーとその対処方法をまとめています。
専門知識がなくても対処できるよう、
#tsuyo[「何が起きているか」「なぜ起きたか」「どうすれば直るか」「直ったかどうかの確認方法」]
の順で記載しています。

エラーには `E-xxx` の番号が付いています。
他の章から「@err-map-name を参照」のように案内されている場合は、その番号を探してください。

== 困ったときの進め方 <subsec-trouble-flow>

やみくもに再起動するより、次の順序で切り分けたほうが早く解決します。

#v(3pt)
#fstep(1, [画面に出ている文字をそのまま読む], [
  ブラウザの赤い帯や、端末に出ている日本語のメッセージが最大の手がかりです。
  #tsuyo[文字を書き写すか、スマートフォンで撮影しておいてください]。
  本章の一覧から同じ文言を探します。
])
#fstep(2, [どの工程で止まったかを特定する], [
  「データ取得」「マッピング」「2D 地図変換」「自律走行」のどれで起きたかによって、
  見るべき節が変わります。@tab-trouble-index から該当する節に進んでください。
])
#fstep(3, [本章の対処を上から順に試す], [
  各エラーの「対処」は#tsuyo[効果が高く、副作用が小さい順]に並べています。
  上から順に試し、1 つ試すごとに「確認」の方法で直ったか確かめてください。
])
#fstep(4, [それでも直らなければ記録して問い合わせる], [
  @subsec-trouble-report の項目をそろえて、@sec-contact の問い合わせ先へご連絡ください。
])

#figure(
  stable(
    columns: (auto, 1fr),
    [*症状が出た場面*], [*参照する節*],
    [ブラウザで GUI が開かない、ボタンが反応しない], [@subsec-err-gui],
    [ロボットが動かない、rosbag が記録できない], [@subsec-err-getdata],
    [地図が作れない、地図の形がおかしい], [@subsec-err-mapping],
    [2D 地図が真っ白・真っ黒になる], [@subsec-err-pcd2pgm],
    [自律走行が始まらない、途中で止まる、変な方向へ行く], [@subsec-err-nav],
    [ビルドやインストールが通らない], [@subsec-err-build],
    [端末に出た英語のメッセージから探したい], [@subsec-msg-index],
  ),
  caption: [症状から探す索引],
) <tab-trouble-index>

== まず試す 3 つのこと <subsec-trouble-first>

原因がはっきりしないときは、次の 3 つを順に試してください。
経験上、多くのトラブルはこれで解決します。

#v(3pt)
#fstep(1, [ロボットを止めてから、もう一度始める], [
  メイン画面の #btn[ロボット停止] を押し、「停止モード」に戻ったことを確認してから、
  改めて操作をやり直します。
  中途半端に残ったプログラムが原因のトラブルは、これで解消します。
])
#fstep(2, [GUI サーバを再起動する], [
  端末で次を実行します。停止してから起動するまで、#tsuyo[5 秒ほど間を空けてください]。

  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh
./start_server.sh
```]
])
#fstep(3, [パソコンを再起動する], [
  それでも直らない場合はパソコンごと再起動します。
  再起動後は必ず GUI サーバの起動（@sec-gui）からやり直してください。
])

#warn[
  再起動しても#tsuyo[同じエラーが同じ場所で繰り返し出る]場合は、設定かファイルに原因があります。
  再起動を繰り返さず、本章の該当する節を確認してください。
]

== GUI・サーバに関するエラー <subsec-err-gui>

#errorcard(
  [ブラウザに GUI の画面が表示されない],
  id: "E-101",
  level: "warn",
  symptom: [
    ブラウザで `http://localhost:5050` を開いても
    「接続できません」「このサイトにアクセスできません」と表示される。
  ],
  cause: [
    GUI サーバが起動していないか、ファイアウォールでポート 5050 が塞がれています。
    別のパソコンから見ている場合は、URL のアドレスが違っている可能性もあります。
  ],
  fix: [
    + GUI サーバを起動します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./start_server.sh
```]
    + 起動した端末に次の 2 行が出ているか確認します。出ていなければ起動に失敗しています。

      #console(title: "GUI サーバ起動時の正常な表示")[```
Flask Server starting at http://0.0.0.0:5050
WebSocket Proxy server started at ws://0.0.0.0:5050/ws
```]
    + ファイアウォールでポートを開けます（@tab-used-ports）。

      #terminal[```bash
sudo ufw allow 5000,5001,5050,8000,9000,9090,10940/tcp
sudo ufw allow 7400:7800/udp
sudo ufw reload
```]
    + 別のパソコンから見ている場合は、`localhost` ではなく
      #tsuyo[ロボット側パソコンの IP アドレス]を使います
      （例 `http://192.168.0.20:5050`）。IP アドレスは `hostname -I` で確認できます。
  ],
  verify: [ブラウザを再読み込みし、メイン画面（@sub3）が表示されること。],
) <err-gui-noaccess>

#errorcard(
  [「サーバ接続なし」と表示される],
  id: "E-102",
  level: "warn",
  symptom: [
    メイン画面は開くが、「現在のモード」の欄に「サーバ接続なし」と表示され、
    ボタンを押しても反応しない。
  ],
  cause: [
    ブラウザの画面は残っているが、GUI サーバのプログラムが落ちています。
    サーバを起動していた端末を誤って閉じた場合にも起こります。
  ],
  fix: [
    + サーバを起動し直します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh
./start_server.sh
```]
    + ブラウザのページを再読み込みします。
  ],
  verify: [「現在のモード」が「停止モード」に変わること。],
) <err-gui-noserver>

#errorcard(
  [`自律走行経路確認Viewer`（Vizanti）が真っ白になる／地図が出ない],
  id: "E-103",
  level: "warn",
  symptom: [
    Vizanti の画面は開くが、何も表示されない。
    または、トピックの一覧が空で選べない。
  ],
  shown: [
    サーバの端末に次のような表示が出ることがあります。
    #console(title: "GUI サーバの端末")[```
Proxy: Error: Could not connect to ROSBridge at ws://localhost:9090.
Make sure it's running.
```]
  ],
  cause: [
    ブラウザと ROS 2 をつなぐ中継役（`rosbridge`／ポート 9090）が動いていません。
    `start_server.sh` は GUI サーバと Vizanti サーバの 2 つを起動しますが、
    このうち Vizanti 側だけが失敗した場合に起こります。
  ],
  fix: [
    + サーバを停止し、5 秒ほど待ってから起動し直します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh
./start_server.sh
```]
    + 起動時に開く 2 つの端末（@im1）のうち、
      Vizanti 側の端末にエラーが出ていないか確認します。
    + ポート 9090 が開いているか確認します。

      #terminal[```bash
sudo ufw allow 9090/tcp
```]
  ],
  verify: [
    Vizanti の画面でトピックの一覧が表示され、選択できるようになること。
  ],
) <err-vizanti>

#note[
  Vizanti の端末に
  `WebSocketClosedError: Tried to write to a closed websocket`
  という警告が繰り返し出ることがありますが、これは
  #tsuyo[ブラウザのタブを閉じたときに出る正常な警告]です。
  動作に影響はないため、対処は不要です。
]

#errorcard(
  [ボタンが灰色で押せない],
  id: "E-104",
  level: "info",
  symptom: [
    #btn[データ取得] #btn[マッピング] #btn[自律走行] #btn[ファイル管理]
    が灰色になっていて押せない。
  ],
  cause: [
    #tsuyo[異常ではありません。] ロボットのノードが起動している間は、
    誤操作を防ぐためにこれらのボタンが無効化される仕様です。
    このとき有効なのは #btn[ロボット停止] と #btn[Map Viewer] だけです。
  ],
  fix: [
    #btn[ロボット停止] を押し、「現在のモード」が「停止モード」に戻ったことを確認してください。
    その後、目的のボタンが押せるようになります。
  ],
  verify: [「現在のモード」が「停止モード」になり、ボタンの色が戻ること。],
) <err-btn-disabled>

#errorcard(
  [「セキュリティ上の理由により、このディレクトリにはアクセスできません。」],
  id: "E-105",
  level: "info",
  symptom: [ファイル選択の画面で、赤い帯に上記のメッセージが表示される。],
  cause: [
    決められたフォルダ（`map/`, `waypoints/`, `config/`, `rosbag/`）の外に
    出ようとしたときに表示される安全機能です。故障ではありません。
  ],
  fix: [
    画面上部の「戻る」やフォルダ名のリンクを使って、決められたフォルダの中を選び直してください。
    別の場所にあるファイルを使いたい場合は、
    あらかじめ @subsec-dirs のフォルダへコピーしておきます。
  ],
  verify: [目的のファイルが一覧に表示され、選択できること。],
) <err-path-denied>

#errorcard(
  [ファイル名を変更できない],
  id: "E-106",
  level: "info",
  symptom: [
    ファイル管理でファイル名をダブルクリックして変更しようとすると、
    赤い帯にメッセージが出て変更できない。
  ],
  shown: [
    次のいずれかが表示されます。
    #terminal[```text
拡張子の変更はできません。ファイル名のみ変更してください。
ファイル "xxxx.pcd" は既に存在します。
不正なファイルパスです。
```]
  ],
  cause: [
    いずれも#tsuyo[安全のための制限]です。故障ではありません。
    - 拡張子（`.pcd` `.pgm` `.yaml` `.json` `.csv`）は変更できません
    - 同じ名前のファイルが既にある場合は上書きされません
    - 決められたフォルダの外を指す名前は使えません
  ],
  fix: [
    + 拡張子を除いた部分だけを書き換えてください。
      例えば `oldmap.pcd` を `newmap.pcd` にしたい場合、
      入力するのは `newmap.pcd` で、`.pcd` の部分は変えないようにします。
    + 同名のファイルが既にある場合は、別の名前にするか、
      先に既存のファイルを削除または改名してください。
    + 名前に `/` や `..` を含めないでください。
  ],
  verify: [
    一覧の表示が新しい名前に変わること。
  ],
) <err-rename>

#warn[
  地図の名前を変更するときは、#tsuyo[`.pcd` `.pgm` `.yaml` の3つと、
  `data/<地図名>/` フォルダをすべて同じ名前にそろえる]必要があります。
  片方だけ変更すると自律走行で使えなくなります（@err-map-name、@err-init-pose）。
]

#errorcard(
  [Map Viewer に地図や経路が表示されない],
  id: "E-107",
  level: "warn",
  symptom: [
    Map Viewer でファイルを選んで #btn[選択した要素をロード] を押しても、
    何も表示されない。または赤い帯・黄色い帯にメッセージが出る。
  ],
  shown: [
    次のいずれかが表示されます。
    #terminal[```text
エラー: マップファイル "xxxx.pcd" がサーバに見つかりません。
警告: YAMLファイル "xxxx.yaml" の読み込みに失敗しました。
警告: Waypointファイル "xxxx.json" の読み込みに失敗しました。
エラー: 表示するマップ名が指定されていません。
```]
  ],
  cause: [
    指定したファイルが存在しないか、中身が壊れています。\
    「警告」の場合はその要素だけが読み込まれず、
    #tsuyo[他の要素は表示されます]（例：3D 地図は出るが経路が出ない）。
  ],
  fix: [
    + 「ファイル管理」で、選んだファイルが実際に存在するか確認します。
    + 3D 地図（`.pcd`）・2D 地図（`.pgm` と `.yaml`）・経路（`.json`）は、
      それぞれ別々に選ぶ必要があります。選び忘れていないか確認してください。
    + 2D 地図を表示するには、`.pgm` と #tsuyo[同じ名前の `.yaml` が必須]です。
      `.yaml` が無い場合は @sec-2d-map の変換をやり直してください。
    + 経路ファイルが壊れていないか確認します。
      エラーが出る場合はファイルが壊れています。

      #terminal[```bash
python3 -m json.tool ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/<経路名>.json > /dev/null
```]
    + 点群が大きすぎて表示に時間がかかっている場合もあります。
      数十秒待っても表示されない場合に異常と判断してください。
    + ブラウザのページを再読み込みしてから、もう一度試します。
  ],
  verify: [
    Map Viewer に 3D 点群地図と経路が表示されること。
  ],
) <err-viewer-noload>

== データ取得に関するエラー <subsec-err-getdata>

#errorcard(
  [ロボットがジョイスティック操作で動かない],
  id: "E-201",
  level: "warn",
  symptom: [
    Vizanti のバーチャルジョイスティックを操作しても、ロボットが動かない。
  ],
  cause: [
    速度指令のトピック名が合っていない、モータドライバが起動していない、
    または非常停止が押されたままになっている、のいずれかです。
  ],
  fix: [
    + #tsuyo[非常停止スイッチが解除されているか]を確認します。もっとも多い原因です。
    + ジョイスティックのアイコンを選択し、
      速度トピック名が `wizurg/cmd_vel` になっているか確認します（@sub23）。
    + モータドライバの端末（@sub12）が開いていて、エラーが出ていないか確認します。
    + 速度指令が実際に出ているかを端末で確認します。
      ジョイスティックを操作している間、数値が流れれば GUI 側は正常です。

      #terminal[```bash
ros2 topic echo /wizurg/cmd_vel
```]
    + 数値が流れているのにロボットが動かない場合は、モータドライバ側の問題です。
      @err-motor-driver を参照してください。
  ],
  verify: [ジョイスティックの操作でロボットが動くこと。],
) <err-motor-jog>

#errorcard(
  [モータドライバが起動しない],
  id: "E-202",
  level: "warn",
  symptom: [
    モータドライバの端末が開くが、すぐに閉じる、またはエラーが表示されて止まる。
  ],
  cause: [
    モータとの通信ポート（`/dev/ttyUSB0` など）が見つからない、
    アクセス権限がない、または `yp-spur` が起動していないことが考えられます。
  ],
  fix: [
    + USB ケーブルが接続されているか、モータの電源が入っているかを確認します。
    + 通信ポートが見えているか確認します。

      #terminal[```bash
ls -l /dev/ttyUSB*
```]
    + ポートへのアクセス権限を付与し、#tsuyo[いったんログアウトして入り直します]。

      #terminal[```bash
sudo usermod -aG dialout $USER
```]
    + 本パッケージはサンプルとして `icart_mini_driver_ros2` を使う構成です。
      別のモータドライバを使用している場合は、
      #path[scripts/navigation/nav_common.sh] の `launch_motor_driver` 関数を
      ご使用のドライバの起動コマンドに書き換えたうえで、
      `hokuyo_navigation2` を再ビルドしてください（@sec-setup）。
  ],
  verify: [
    モータドライバの端末が開いたまま維持され、
    `ros2 topic list` に速度指令のトピックが表示されること。
  ],
) <err-motor-driver>

#errorcard(
  [rosbag が記録されない／ファイルが空になる],
  id: "E-203",
  level: "warn",
  symptom: [
    Vizanti で記録を開始したのに、`rosbag/` に何もできていない。
    または、できたファイルが極端に小さい。
  ],
  cause: [
    保存先のパスが間違っている、記録するトピックを選び忘れている、
    またはセンサからデータが届いていないことが考えられます。
  ],
  fix: [
    + 「Save to path：」に指定したパスを確認します。
      #path[/home/\<ユーザ名\>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/\<ROSBAG_NAME\>]
      のように、#tsuyo[先頭が `/` で始まる絶対パス]で `rosbag/` フォルダの下を指定してください。
      `~` は使えません。
    + 「Topics：」で @tab-bag-topics のトピックがすべて選択されているか確認します。
      #tsuyo[選び忘れたトピックがあると、後の地図作成が失敗します]。
    + センサのデータが届いているか確認します。
      いずれかが `no new messages` のままなら、記録しても中身は空になります。

      #terminal[```bash
ros2 topic hz /hokuyo3d/hokuyo_cloud2
ros2 topic hz /rsf/lio_lidar_rate_odom
ros2 topic hz /fix
```]
    + データが届いていない場合は @err-no-sensor を参照してください。
  ],
  verify: [
    記録アイコンが赤に変わり、記録の停止後に `rosbag/` の中に
    フォルダができていて、サイズが数十 MB 以上あること。
  ],
) <err-bag-empty>

#errorcard(
  [センサのデータがまったく届かない],
  id: "E-204",
  level: "warn",
  symptom: [
    `ros2 topic list` に `/hokuyo3d/hokuyo_cloud2` や `/fix` が表示されない。
    または表示されてもデータが流れない。
  ],
  cause: [
    RSF との通信ができていません。
    IP アドレスの設定違い、LAN ケーブルの未接続、電源未投入が主な原因です。
  ],
  fix: [
    + RSF の電源と LAN ケーブルの接続を確認します。
    + 設定ファイル #path[config/rsf_node_config.yaml] の
      `spel_ip_address` が、実際の RSF の IP アドレスと一致しているか確認します。
      初期値は `192.168.0.100`、ポートは `10940` です。
    + パソコンから RSF に届くか確認します。応答がなければネットワークの問題です。

      #terminal[```bash
ping 192.168.0.100
```]
    + パソコン側の IP アドレスが、RSF と同じネットワーク
      （例 `192.168.0.x`）になっているか確認します。
    + ファイアウォールでポート 10940 を開けます。

      #terminal[```bash
sudo ufw allow 10940/tcp
```]
  ],
  verify: [
    `ros2 topic hz /hokuyo3d/hokuyo_cloud2` で数値が表示され続けること。
  ],
) <err-no-sensor>

#errorcard(
  [GNSS のデータが届かない／精度が上がらない],
  id: "E-205",
  level: "warn",
  symptom: [
    RViz2 の画面に「GNSSの精度: N/A」と白字で表示される。
    または「GNSSの精度が低い状態です。」と赤字で表示され続ける。
  ],
  cause: [
    N/A の場合は GNSS のデータ自体が届いていません。
    赤字の場合はデータは届いているものの、測位精度が出ていません。
  ],
  fix: [
    + まず `/fix` が流れているか確認します。

      #terminal[```bash
ros2 topic echo /fix --once
```]
    + 流れていない場合は、RSF との通信の問題です。@err-no-sensor を参照してください。
    + 流れているが精度が低い場合は、#tsuyo[受信環境]の問題です。
      屋根の下、建物のすぐ脇、樹木の下、高架下では精度が出ません。
      空が広く見える場所へ移動して数分待ち、色が緑に変わるか確認してください。
    + RTK 補正情報（ネットワーク配信など）を使用している場合は、
      その配信サービスへの接続が有効かを確認してください。
    + どうしても精度が出ない場所を走る必要がある場合は、
      GNSS に頼らない `loc` モード（@tab-nav-type）での走行に切り替えてください。
  ],
  verify: [
    RViz2 の表示が「GNSSの精度は良好です。」（緑）になること。
    地図作成では、`gnss_log/` に出力される CSV の fix 率が
    `fix_rate` の設定値以上になっていること。
  ],
) <err-no-gnss>

== マッピングに関するエラー <subsec-err-mapping>

#note[
  マッピングはロボットを動かさずに実行できます。
  失敗しても機械が壊れることはないので、
  #tsuyo[パラメータを変えて何度でもやり直して構いません]。
]

=== 処理の流れと止まる場所 <subsubsec-mapping-stages>

マッピングは、いくつものプログラムが順番に呼び出される多段の処理です。
端末の表示が#tsuyo[どこまで進んで止まったか]が分かれば、原因をかなり絞り込めます。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*段階*], [*行われること*], [*参照*],

    [① 準備],
    [引数の確認、rosbag の存在確認、設定ファイルの読み込み、
     `run_p2o` の探索],
    [@err-no-runp2o \ @err-bag-notfound],

    [② GNSS 品質確認 \ #text(size: 8pt)[（GNSS 補正モードのみ）]],
    [rosbag 内の GNSS の共分散を集計し、`gnss_log/` に CSV を出力],
    [@err-gnsslog-fail],

    [③ グラフ生成],
    [rosbag から位置の情報を取り出し、`output.p2o` を作る],
    [@err-p2o-empty \ @err-p2o-stdout],

    [④ 最適化],
    [`run_p2o` が位置のつじつまを合わせ、`output.p2o_out.txt` を作る],
    [@err-p2o-optfail \ @err-runp2o-silent],

    [⑤ 点群の抽出],
    [rosbag から地図に使う点群を取り出す],
    [@err-pcd-extract],

    [⑥ 点群の結合],
    [`rearrange_pointcloud` が点群を並べ直し、地図と経路を作る],
    [@err-concat-broken],

    [⑦ 座標変換と保存],
    [絶対座標を相対座標に直し、`map/` へ移動して完了フラグを作る],
    [@err-flag-only],
  ),
  caption: [p2o マッピングの処理段階],
) <tab-mapping-stages>

=== 「エラーが出ないのに失敗している」場合 <subsubsec-mapping-silent>

#danger[
  マッピング処理には、#tsuyo[失敗しても途中で止まらず、
  最後まで進んでしまう経路がいくつかあります]。
  次のような場合は、端末に赤い文字が出ていなくても失敗しています。

  - 端末がすぐに閉じた、または何も表示されずに終わった
  - `map/` に `.pcd` ができていない
  - できた `.pcd` を 3D Viewer で開くと何も表示されない、点がごくわずかしかない
  - 地図が実際の現場とかけ離れた形・大きさになっている

  この場合は @err-p2o-nogo、@err-runp2o-silent、@err-flag-only、@err-lioraw-silent
  の4つを順に確認してください。
]

#tip[
  マッピングが終わったら、#tsuyo[必ず 3D Viewer で地図を目視確認してください]。
  「完了しました」の表示だけで次の工程へ進むと、
  自律走行の段階になってから作り直しになります。
]

#errorcard(
  [「エラー: 'run_p2o' 実行ファイルが見つかりませんでした。」],
  id: "E-301",
  level: "danger",
  symptom: [
    #btn[p2o] を実行すると、開いた端末に上記が表示されてすぐ終了する。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
hokuyo_slam (run_p2o) のバイナリを検索しています...
エラー: 'run_p2o' 実行ファイルが見つかりませんでした。
hokuyo_slam_ros2 プロジェクトが正しくビルドされているか確認してください。
```]
  ],
  cause: [
    3D SLAM の本体である `hokuyo_slam_ros2` がビルドされていません。
    このパッケージは `colcon build` では作られず、
    #tsuyo[個別に `cmake` でビルドする必要があります]（@sec-setup）。
  ],
  fix: [
    + `hokuyo_slam_ros2` をビルドします。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
mkdir -p build
cmake -Bbuild . && cmake --build build
```]
    + ビルド後、実行ファイルができているか確認します。

      #terminal[```bash
find ~/colcon_ws -name run_p2o -type f
```]
    + ビルドが途中で失敗する場合は、依存ライブラリ（PCL 1.14、PROJ）が
      入っていない可能性があります。@err-build-pcl を参照してください。
  ],
  verify: [
    #btn[p2o] の実行時に
    `hokuyo_slam のバイナリディレクトリが見つかりました: ...` と表示されること。
  ],
) <err-no-runp2o>

#errorcard(
  [「Error: Path ... does not exist (neither file nor folder).」],
  id: "E-302",
  level: "warn",
  symptom: [
    マッピングを開始すると、上記が表示されて終了する。
  ],
  cause: [
    指定した rosbag が `rosbag/` フォルダに見つかりません。
    データ取得のときに `rosbag/` 以外の場所へ保存した場合や、
    記録後にフォルダ名を変更した場合に起こります。
  ],
  fix: [
    + `rosbag/` フォルダの中身を確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/
```]
    + 使いたい rosbag が別の場所にある場合は、
      フォルダごと `rosbag/` の下へ移動してください。
    + ROS 2 の rosbag は#tsuyo[フォルダ]です。
      中に `.db3` または `.mcap` と `metadata.yaml` が入っていることを確認してください。
      ファイル 1 つだけをコピーしても読み込めません。
  ],
  verify: [
    実行時に `rosbag folder: ... exists.` と表示されること。
  ],
) <err-bag-notfound>

#errorcard(
  [「Error: data/... /output.p2o is empty.」],
  id: "E-303",
  level: "warn",
  symptom: [
    p2o の実行が途中で止まり、上記が表示される。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Error: data/mymap/output.p2o is empty. Verify that odom/IMU topics are correct.
```]
  ],
  cause: [
    地図作成コンフィグに指定したトピック名が、
    rosbag に記録されている実際のトピック名と一致していません。
    その結果、rosbag からデータを 1 件も取り出せていません。
  ],
  fix: [
    + rosbag に実際に入っているトピック名を確認します。

      #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>
```]
    + 「ファイル管理」→「設定ファイル管理」から地図作成コンフィグを開き、
      `lio_topic`、`imu_topic`、`pointcloud_topic`、`gnss_topic` の値を
      上で確認した名前に合わせます。
    + CSV を編集するときは、#tsuyo[カンマの前後に半角スペースを入れないでください]。
      空白があると値が正しく読み込まれません。
    + 該当するトピックがそもそも rosbag に入っていない場合は、
      データ取得をやり直してください（@tab-bag-topics のトピックをすべて選択します）。
  ],
  verify: [
    実行が最後まで進み、`map/` に `<地図名>.pcd` ができること。
  ],
) <err-p2o-empty>

#errorcard(
  [「Error: run_p2o optimization failed or produced empty output.」],
  id: "E-304",
  level: "warn",
  symptom: [
    グラフ最適化の段階で止まり、上記に続いてログの末尾 20 行が表示される。
  ],
  cause: [
    最適化に必要なデータが足りないか、データに矛盾があります。
    移動距離が極端に短い rosbag、途中で記録が途切れた rosbag で起こりやすい症状です。
  ],
  fix: [
    + 表示された `run_p2o.log` の末尾を読み、原因の記載がないか確認します。
    + rosbag の記録時間と移動距離を確認します。
      #tsuyo[数メートルしか動いていない rosbag では地図になりません。]
      目安として数十メートル以上走行したデータを使ってください。
    + 地図作成コンフィグの `lio_min_movement_thre` が大きすぎると
      グラフの点が作られません。既定値の `0.1` 前後に戻して再実行してください。
    + それでも失敗する場合は、GNSS を使わない `lio_raw` モードで
      地図が作れるか試してください。作れる場合は GNSS 側のデータに問題があります
      （@err-fix-rate）。
  ],
  verify: [`map/` に `<地図名>.pcd` ができること。],
) <err-p2o-optfail>

#errorcard(
  [「fix トピックの共分散のfix率が ...% です。」と表示される],
  id: "E-305",
  level: "info",
  symptom: [
    p2o の実行時に上記が表示され、続けて
    「Fix率が低いため、Z軸拘束(擬似観測)を追加してSLAMを続行します。」と表示される。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
fix トピックの共分散のfix率が 12.5% です。gnss_cov_threの値を大きくしてください。
Fix率が低いため、Z軸拘束(擬似観測)を追加してSLAMを続行します。
```]
  ],
  cause: [
    #tsuyo[処理は続行されます。エラーではありません。]\
    設定した精度のしきい値（`gnss_cov_thre`）を満たす GNSS データの割合が、
    `fix_rate` で指定した割合を下回ったため、
    GNSS による補正の代わりに「高さを 0 に固定する」補正に切り替わったことを知らせています。\
    地図は作られますが、GNSS 補正が効いていないぶん、
    長距離では水平方向の精度が落ちる場合があります。
  ],
  fix: [
    そのままで問題ない場合は、対処は不要です。
    GNSS 補正を効かせたい場合は次を試します。
    + 地図作成コンフィグの `gnss_cov_thre` を大きくします
      （例 `0.01` → `0.1`）。ゆるい精度のデータも使うようになり、fix 率が上がります。
      ただし、精度の悪いデータを取り込むため、地図が歪む可能性もあります。
    + 逆に `fix_rate` を下げて、より低い fix 率でも GNSS 補正を行うようにします。
    + 根本的には#tsuyo[受信環境の良い場所でデータを取り直す]のが最も確実です。
      詳細な fix 率は `gnss_log/<地図名>_gnss_cov_<しきい値>.csv` で確認できます。
    + 屋内など GNSS がそもそも使えない環境では、
      地図作成コンフィグの `slam_mode` を `gravity` にして
      IMU 補正モードで作成するか、`lio_raw` モードを使ってください。
  ],
  verify: [`map/` に `<地図名>.pcd` ができること。],
) <err-fix-rate>

#errorcard(
  [p2o を実行しても何も起こらずに終わる],
  id: "E-306",
  level: "warn",
  symptom: [
    端末は開くが、GNSS のログ出力のあと処理が始まらないまま終了する。
    `map/` にも何もできない。
  ],
  cause: [
    GNSS の解析結果が空だったため、後続の処理に進めていません。
    rosbag に `gnss_topic` で指定したトピック（既定は `/fix`）が
    まったく入っていない場合に起こります。
  ],
  fix: [
    + rosbag に GNSS のトピックが入っているか確認します。

      #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名> | grep fix
```]
    + 入っていない場合、その rosbag では GNSS 補正の地図は作れません。
      次のいずれかで作成してください。
      - 地図作成コンフィグの `slam_mode` を `gravity` にして IMU 補正モードで作る
      - #btn[lio_raw] モードで作る
    + 屋外で撮り直せる場合は、@tab-bag-topics のトピックをすべて選択して
      データ取得からやり直してください。
  ],
  verify: [端末に `p2o 開始` と表示され、処理が進むこと。],
) <err-p2o-nogo>

#errorcard(
  [「ERROR: pcd_tf_extractor.py がエラーコード ... で終了しました。」],
  id: "E-307",
  level: "warn",
  symptom: [
    #btn[lio_raw] の実行が途中で止まり、上記が表示される。
  ],
  cause: [
    `lio_raw` は、地図作成コンフィグの
    `pointcloud_topic`、`lio_topic`、`orig_frame`、`target_frame` を使います。
    このいずれかが rosbag の内容と一致していないと処理できません。
  ],
  fix: [
    + rosbag の中身を確認します。

      #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>
```]
    + 地図作成コンフィグの `pointcloud_topic` と `lio_topic` を、
      実際のトピック名に合わせます。
    + `orig_frame`（センサ側の座標系。既定 `yvt`）と
      `target_frame`（地図の基準座標系。既定 `lio_odom`）が
      記録時の設定と合っているか確認します。
    + 端末に表示された Python のエラー文の#tsuyo[最後の 1 行]を控えておくと、
      問い合わせ時の特定が早くなります。
  ],
  verify: [
    `LIO-RAW処理とPCDファイル抽出が完了しました。` と表示され、
    `map/` に `<地図名>.pcd` ができること。
  ],
) <err-lioraw-fail>

#errorcard(
  [「PCDファイルが見つかりません。フラグは存在しましたが、...」],
  id: "E-308",
  level: "warn",
  symptom: [
    ブラウザ上でマッピングの完了を待っていると、上記のメッセージが表示される。
  ],
  cause: [
    処理は完了扱いになったものの、出力されるはずの `.pcd` が
    `map/` フォルダに見つかりません。\
    マッピングのスクリプトは#tsuyo[途中で失敗しても完了フラグを作ってしまう]ため、
    実際の原因はもっと手前の段階にあります。
    段階ごとの切り分け方は @err-flag-only に詳しく記載しています。
  ],
  fix: [
    + マッピングを実行していた端末を確認し、
      その後半にエラーが出ていないか確認します。
    + `map/` フォルダと、作業用の `data/<地図名>/` フォルダを確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/
```]
    + ディスクの空き容量を確認します。点群地図は数百 MB になることがあります。

      #terminal[```bash
df -h ~
```]
    + 空き容量が不足していた場合は、不要な rosbag や地図を削除してから
      マッピングをやり直してください。
  ],
  verify: [
    `map/` に `<地図名>.pcd` ができ、
    #btn[3Dビューアで確認] から表示できること。
  ],
)

#errorcard(
  [マッピングがいつまでも「処理中」のまま終わらない],
  id: "E-309",
  level: "info",
  symptom: [
    ブラウザに「処理を続行中です...」と表示されたまま、何分たっても完了しない。
  ],
  cause: [
    ブラウザ側は#tsuyo[完了の目印となるファイルができるのを待っているだけ]です。
    実際の処理は別の端末で動いており、そちらが失敗して止まっていると、
    ブラウザは待ち続けます。
  ],
  fix: [
    + #tsuyo[マッピングを実行している端末を確認してください。]
      画面下のタスクバーから、最小化された端末を開きます。
    + 端末にエラーが出ていれば、本節の該当する項目で対処します。
    + 端末で処理が進んでいる場合は、そのまま待ってください。
      rosbag のサイズによっては数分以上かかります。
    + 端末が既に閉じている場合は、処理が異常終了しています。
      ブラウザのページを再読み込みし、マッピングをやり直してください。
  ],
  verify: [ブラウザに完了のメッセージが表示されること。],
) <err-mapping-stuck>

#errorcard(
  [設定を変えたのに反映されない／別の項目が変わってしまう],
  id: "E-310",
  level: "danger",
  symptom: [
    地図作成コンフィグを編集したのに結果が変わらない。
    あるいは、変えていないはずの項目まで挙動が変わってしまう。
  ],
  cause: [
    スクリプトは地図作成コンフィグを#tsuyo[項目名ではなく「上から何行目か」で読み取っています]。
    そのため、行を並べ替えたり、途中の行を削除・追加したりすると、
    まったく別の項目として解釈されます。\
    例えば `imu_topic` の行を消すと、以降の項目が 1 つずつ繰り上がり、
    `slam_mode` の値が `imu_topic` として読まれてしまいます。
  ],
  fix: [
    + 「ファイル管理」→「設定ファイル管理」から #btn[テキスト編集] で開き、
      行の並びが @tab-ref-mapping-params のとおりになっているか確認します。
    + 行が足りない、または順序が入れ替わっている場合は、正しい並びに直します。
    + 値を変えるときは、#tsuyo[2 列目だけ]を書き換えてください。
      1 列目の項目名は変更しないでください。
    + カンマの前後に半角スペースがないか確認します。
      空白があると値が正しく読み込まれません。
    + どうしても直らない場合は、
      #path[config/hokuyo_slam_topics_cfg.csv] を元の内容に戻したうえで、
      改めて値だけを変更してください。
  ],
  verify: [
    マッピング実行時に端末へ表示される
    `gnss_topic: ...` `slam_mode: ...` などの一覧が、
    意図した値になっていること。
  ],
) <err-csv-order>

#tip[
  マッピングを実行すると、端末の先頭に#tsuyo[読み込まれた設定値の一覧]が表示されます。
  設定を変更したときは、ここが意図どおりになっているかを必ず確認してください。

  #console(title: "マッピング開始時の設定値表示")[```
Loading config from: /home/hokuyo/colcon_ws/src/.../config/hokuyo_slam_topics_cfg.csv
gnss_topic: /fix
pointcloud_topic: /hokuyo3d/hokuyo_cloud2
lio_topic: /rsf/lio_lidar_rate_odom
gnss_cov_thre: 0.01
imu_topic: /hokuyo3d/imu
slam_mode: gnss
pc_save_distance: 0.3
wp_save_distance: 0.5
```]

  なお `WARNING: Config file not found at ... Using default values.` と表示された場合は、
  #tsuyo[指定した設定ファイルが読めず、既定値で動いています]。
  ファイル名の選択を確認してください。
]

=== 起動時のエラー <subsubsec-err-mapping-start>

#errorcard(
  [マッピングを実行しても端末がすぐ閉じる／何も表示されない],
  id: "E-311",
  level: "warn",
  symptom: [
    ボタンを押すと端末は開くが、一瞬で閉じる。
    または何も表示されないまま終わる。`map/` にも何もできない。
  ],
  cause: [
    スクリプトに実行権限が付いていないか、
    ROS 2 のワークスペースを読み込めていません。
    導入直後や、ワークスペースを別の場所へ移動した後に起こります。
  ],
  fix: [
    + スクリプトに実行権限を付けます。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
chmod +x scripts/*.sh scripts/*/*.sh src/*.py
```]
    + ワークスペースがビルドされているか確認します。
      `install/setup.bash` が無いとスクリプトは動きません。

      #terminal[```bash
ls ~/colcon_ws/install/setup.bash
```]
    + 無い場合はビルドします（@err-build-fail）。
    + 手動で実行して、表示されるエラーを確認します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
bash scripts/mapping/hokuyo_slam.bash <rosbag名> <地図名> "" "" "" ""
```]
  ],
  verify: [端末が開いたまま維持され、処理の進行が表示されること。],
) <err-mapping-nostart>

#errorcard(
  [「トピック同期」が実行できない],
  id: "E-312",
  level: "info",
  symptom: [
    マッピング画面から「同期（sync）」を選ぶと、
    `No such file or directory` と表示されて終了する。
  ],
  cause: [
    この機能が呼び出す `scripts/mapping/sync_topic.bash` は、
    #tsuyo[現在のバージョンには含まれていません]。
    GUI 側に選択肢だけが残っている状態です。
  ],
  fix: [
    この機能は使用しないでください。
    マッピングは #btn[p2o] または #btn[lio_raw] から実行します。
  ],
  verify: [—],
) <err-sync-missing>

#errorcard(
  [Python のパッケージが足りないというエラーが出る],
  id: "E-313",
  level: "warn",
  symptom: [
    端末に `ModuleNotFoundError` や `ImportError` が表示されて処理が止まる。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
ModuleNotFoundError: No module named 'pyproj'
ModuleNotFoundError: No module named 'open3d'
Error: 'open3d' and 'scipy' are required. Please install them:
```]
  ],
  cause: [
    マッピングに必要な Python パッケージが導入されていません。
  ],
  fix: [
    + まとめて導入します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip3 install -r requirements.txt
```]
    + それでも足りない場合は、表示されたモジュール名を指定して導入します。

      #terminal[```bash
pip3 install pyproj open3d scipy numpy tqdm
```]
  ],
  verify: [処理が最後まで進むこと。],
) <err-py-module>

#warn[
  Python の実行が失敗すると、GNSS 補正モードでは続けて
  `rosbag play でfixメッセージがあるかの確認と、gnss_logで共分散の値を確認してください。`
  と表示されます。\
  #tsuyo[このメッセージは、原因が GNSS でない場合にも表示されます。]
  GNSS を疑う前に、その上に出ている Python のエラー文を確認してください。
]

=== GNSS 補正モードのエラー <subsubsec-err-mapping-gnss>

#errorcard(
  [GNSS の品質チェックで止まり、p2o が始まらない],
  id: "E-314",
  level: "warn",
  symptom: [
    端末に GNSS 関連のエラーが表示されたあと、
    `p2o 開始` が表示されずに処理が終わる。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Error (ROS 2): Topic '/fix' not found in '.../rosbag2_xxx.mcap'.
Error (ROS 2): Unsupported message type 'std_msgs/msg/String'.
No valid messages with position covariance found in topic '/fix'
Error (ROS 2) opening bag file '...': ...
Error: No .mcap or .db3 files found in '...'.
```]
  ],
  cause: [
    GNSS の品質を集計する処理が失敗し、`gnss_log/` に CSV が作られていません。
    その結果、後続の判定に使う値が空になり、
    #tsuyo[p2o 本体が一度も実行されないまま終了します]。
  ],
  fix: [
    + rosbag に実際に入っているトピック名と型を確認します。

      #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>
```]
    + 地図作成コンフィグの `gnss_topic` を、実際の名前に合わせます（既定は `/fix`）。
    + 型が `sensor_msgs/msg/NavSatFix` であることを確認します。
      別の型のトピックを指定していると処理できません。
    + rosbag に GNSS が入っていない場合、GNSS 補正モードは使えません。
      `slam_mode` を `gravity` にするか、#btn[lio_raw] を使ってください。
  ],
  verify: [
    `gnss_log/<地図名>_gnss_cov_<しきい値>.csv` が作られ、
    端末に `p2o 開始` と表示されること。
  ],
) <err-gnsslog-fail>

#errorcard(
  [有効な GNSS が 1 点も採用されない],
  id: "E-315",
  level: "danger",
  symptom: [
    `p2o 開始` までは進むが、そのあと
    `can't open file: .../center_utm.txt` と表示される、
    または地図ができない。
  ],
  cause: [
    GNSS のデータが#tsuyo[3 つの条件すべて]を満たさないと採用されません。
    1 点も採用されないと基準点のファイルが作られず、最適化に進めません。

    #stable(
      columns: (auto, 1fr),
      [*条件*], [*内容*],
      [測位状態], [`status` が 0（FIX）または 2（GBAS FIX）であること。
       #tsuyo[1（SBAS）は採用されません]],
      [精度], [共分散が `gnss_cov_thre` より小さいこと],
      [移動量], [前に採用した点から `gnss_min_movement_thre`（既定 4.0 m）
       以上離れていること],
    )
  ],
  fix: [
    + #tsuyo[走行距離が短い場合]（数十 m 未満）は、
      `gnss_min_movement_thre` を小さくします（例 `4.0` → `1.0`）。
      移動量の条件で全点が落ちている可能性が高いためです。
    + `gnss_cov_thre` を大きくします（例 `0.01` → `0.1`）。
      精度の条件がきびしすぎる場合に効きます。
    + 受信機が SBAS 測位（`status` が 1）しか行っていない場合、
      このモードでは地図を作れません。
      RTK 補正が有効になっているか確認するか、
      `slam_mode` を `gravity` にして IMU 補正モードで作成してください。
    + 測位状態は次のコマンドで確認できます。`status:` の値を見てください。

      #terminal[```bash
ros2 topic echo /fix --once
```]
  ],
  verify: [
    `data/<地図名>/center_utm.txt` が作られ、中身が空でないこと。
  ],
) <err-no-valid-gnss>

#errorcard(
  [地図の座標が現場とかけ離れた値になる],
  id: "E-316",
  level: "warn",
  symptom: [
    地図はできるが、3D Viewer で見ると点が極端に遠くにある、
    または形がまったく崩れている。
  ],
  cause: [
    測位できていない GNSS データ（緯度・経度が 0 付近）が含まれていると、
    #tsuyo[地図の基準となる座標系（UTM ゾーン）が誤って選ばれます]。
    その結果、座標が数百 km 単位でずれます。
  ],
  fix: [
    + rosbag の GNSS が正しい値かを確認します。
      緯度・経度が現場の値になっているか見てください。

      #terminal[```bash
ros2 topic echo /fix --once
```]
    + 0 付近の値しか入っていない場合、その rosbag では GNSS 補正の地図は作れません。
      `slam_mode` を `gravity` にするか、#btn[lio_raw] を使ってください。
    + 屋外で取り直せる場合は、#tsuyo[測位が安定してから記録を開始]してください
      （@err-no-gnss）。
  ],
  verify: [
    3D Viewer で地図が現場の形になっていること。
    `data/<地図名>/init_lat_lon_alt.txt` の値が現場の緯度経度と一致していること。
  ],
) <err-utm-zone>

#errorcard(
  [`output.p2o` にエラー文が書き込まれてしまう],
  id: "E-317",
  level: "danger",
  symptom: [
    端末には短いエラーが出ただけで処理が続き、
    最終的に地図ができない、または形が崩れる。
  ],
  shown: [
    `data/<地図名>/output.p2o` を開くと、
    位置の数値ではなく次のような文が入っています。
    #terminal[```text
Topic '/rsf/lio_lidar_rate_odom' not found in bag file.
Error: Could not retrieve LIO or GNSS messages.
Error: Could not import message type 'nmea_msgs/msg/Gpgga': ...
```]
  ],
  cause: [
    グラフ生成の処理は、結果を `output.p2o` に書き出す作りになっています。
    トピックが見つからないなどの理由で失敗すると、
    #tsuyo[エラーの文章そのものが `output.p2o` に書き込まれます]。
    さらにこのとき#tsuyo[異常終了として扱われない]ため、
    処理はそのまま次の段階へ進んでしまいます。
  ],
  fix: [
    + `output.p2o` の中身を確認します。
      先頭が `VERTEX_SE3:QUAT` で始まっていれば正常です。

      #terminal[```bash
head -3 ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/output.p2o
```]
    + エラー文が入っていた場合、その文言が原因です。
      多くはトピック名の不一致なので、
      `ros2 bag info` で実際の名前を確認し、
      地図作成コンフィグの `lio_topic`・`gnss_topic` を合わせてください。
    + `Could not import message type` の場合は、
      そのメッセージ型のパッケージが導入されていません。
      `nmea_msgs` などが未導入の可能性があります（@err-build-fail）。
    + 修正後は、#tsuyo[同じ地図名でもう一度マッピングを実行]してください。
      古い `data/<地図名>/` は自動で作り直されます。
  ],
  verify: [
    `output.p2o` の先頭が `VERTEX_SE3:QUAT 0 0 0 0 0 0 0 1` であること。
  ],
) <err-p2o-stdout>

#errorcard(
  [最適化に失敗しても処理が進んでしまう],
  id: "E-318",
  level: "danger",
  symptom: [
    端末に `can't open file:` と表示されるが処理は続き、
    そのあと大量の警告が出る。最終的に地図ができない。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
can't open file: data/mymap/center_utm.txt
can't open file: data/mymap/output.p2o
Warning: Skipping malformed log line: ./PCDs/cloud_00001.pcd
Warning: Skipping malformed log line: ./PCDs/cloud_00002.pcd
```]
  ],
  cause: [
    最適化を行う `run_p2o` は、#tsuyo[失敗しても異常終了として扱われません]。
    GNSS 補正モードにはこの段階の成否チェックが無いため、
    空の結果のまま次の段階へ進み、後段で大量の警告が出ます。
  ],
  fix: [
    + `can't open file:` に続くファイル名を確認します。
      - `center_utm.txt` → @err-no-valid-gnss
      - `output.p2o` → @err-p2o-stdout
    + 最適化の結果ファイルが空でないか確認します。
      空（0 バイト）なら失敗しています。

      #terminal[```bash
ls -l ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/output.p2o_out.txt
```]
    + 上流の原因を直してから、もう一度マッピングを実行してください。
  ],
  verify: [
    `output.p2o_out.txt` が空でなく、`Warning: Skipping malformed log line` が出ないこと。
  ],
) <err-runp2o-silent>

#errorcard(
  [点群の抽出に失敗する],
  id: "E-319",
  level: "warn",
  symptom: [
    `ERROR: Couldn't read file cloud_00001.pcd` などが大量に表示される。
  ],
  cause: [
    地図に使う点群が rosbag から取り出せていません。
    点群トピック名の不一致か、
    上流の最適化が失敗していて抽出対象の時刻が決まっていない場合に起こります。
  ],
  fix: [
    + 先に @err-runp2o-silent を確認してください。
      上流が失敗している場合は、そちらが根本原因です。
    + 点群トピック名を確認し、地図作成コンフィグの
      `pointcloud_topic` を実際の名前に合わせます。
    + 抽出された点群ファイルの数を確認します。0 個なら抽出に失敗しています。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/PCDs/ | wc -l
```]
  ],
  verify: [`PCDs/` に点群ファイルが多数できていること。],
) <err-pcd-extract>

#errorcard(
  [「Warning: Skipping malformed log line」が大量に出る],
  id: "E-320",
  level: "warn",
  symptom: [
    点群の結合段階で、上記の警告が延々と表示される。地図はできない。
  ],
  cause: [
    点群のファイル名と位置の情報を組み合わせた一覧
    （`concat.txt`）が正しく作られていません。
    ほとんどの場合、上流の最適化が失敗しています。
  ],
  fix: [
    + @err-runp2o-silent の手順で、最適化が成功しているか確認します。
    + `concat.txt` の中身を確認します。
      1 行が「ファイル名 と 11 個の数値」になっていれば正常です。

      #terminal[```bash
head -2 ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/concat.txt
```]
    + ファイル名だけで数値が続いていない場合は、最適化が失敗しています。
      上流を直してからやり直してください。
  ],
  verify: [警告が出ず、`PCDファイルを保存しました:` と表示されること。],
) <err-concat-broken>

#errorcard(
  [完了フラグだけができて、地図が作られていない],
  id: "E-321",
  level: "danger",
  symptom: [
    ブラウザに「PCDファイルが見つかりません。フラグは存在しましたが、
    ... が見つかりません。」と表示される。
  ],
  cause: [
    マッピングのスクリプトは、#tsuyo[途中で失敗しても最後まで実行を続け、
    完了フラグを作ってしまいます]。
    そのため GUI は「完了した」と判断しますが、実際には地図ができていません。\
    本当の原因は、その手前のどこかの段階にあります。
  ],
  fix: [
    + #tsuyo[マッピングを実行した端末を開き、上へスクロールしてください。]
      最初に出たエラーが本当の原因です。
    + よくある根本原因は次のとおりです。上から順に確認してください。
      - トピック名の不一致 → @err-p2o-stdout
      - 有効な GNSS が無い → @err-no-valid-gnss
      - 最適化の失敗 → @err-runp2o-silent
      - 点群の抽出失敗 → @err-pcd-extract
      - ディスク容量不足 → @err-disk-full
    + 作業用フォルダに何ができているかで、どこまで進んだか分かります。

      #terminal[```bash
ls -l ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/
```]
      #stable(
        columns: (auto, 1fr),
        [*できているファイル*], [*進んだ段階*],
        [`output.p2o` のみ], [③ グラフ生成まで],
        [`output.p2o_out.txt`（空でない）], [④ 最適化まで],
        [`PCDs/` に多数のファイル], [⑤ 点群の抽出まで],
        [`<地図名>_Acord.pcd`], [⑥ 点群の結合まで],
      )
  ],
  verify: [`map/<地図名>.pcd` ができ、3D Viewer で表示できること。],
) <err-flag-only>

=== IMU 補正モードのエラー <subsubsec-err-mapping-gravity>

#danger[
  #tsuyo[IMU 補正モード（`slam_mode` が `gravity`）は、
  `.mcap` 形式の rosbag では動作しません。]\
  このモードの内部処理は `.db3` 形式のみに対応しているためです。
  `.mcap` の rosbag を指定すると @err-gravity-mcap のエラーになります。\
  お使いの rosbag の形式は、フォルダの中身を見れば分かります。
]

#errorcard(
  [IMU 補正モードで「Topic not found or not PointCloud2」と出る],
  id: "E-322",
  level: "danger",
  symptom: [
    `slam_mode` を `gravity` にして実行すると、
    点群の取り出しでエラーになる。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
RuntimeError: Topic not found or not PointCloud2: /hokuyo3d/hokuyo_cloud2
Error: dump_lidar_pointcloud.py failed. Please check if the topic exists in the bag.
```]
  ],
  cause: [
    次の 2 つのどちらかです。
    + #tsuyo[rosbag が `.mcap` 形式である。]
      IMU 補正モードは `.db3` 形式にのみ対応しています。
      形式が違うと、トピックが 1 つも見つからないためこのエラーになります。
    + 点群トピック名が実際と違う。
  ],
  fix: [
    + rosbag の形式を確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>/
```]
    + `.mcap` が入っていた場合、#tsuyo[IMU 補正モードは使えません]。
      次のいずれかで対応してください。
      - #btn[lio_raw] モードで地図を作る（`.mcap` に対応しています）
      - GNSS が使える環境なら、`slam_mode` を `gnss` にする
      - rosbag を `.db3` 形式で取り直す
    + `.db3` が入っていた場合は、トピック名の問題です。
      `ros2 bag info` で確認し、`pointcloud_topic` を合わせてください。
  ],
  verify: [
    `Extracting PCD files from bag...` のあと、
    点群ファイルの保存が進むこと。
  ],
) <err-gravity-mcap>

#errorcard(
  [IMU 補正モードで「Odom topic」「IMU topic」が見つからない],
  id: "E-323",
  level: "warn",
  symptom: [
    利用可能なトピックの一覧とともに、
    指定したトピックが見つからないと表示される。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
RuntimeError: IMU topic '/imu/data' not found.
Available:
  /fix
  /hokuyo3d/hokuyo_cloud2
  /hokuyo3d/imu
  /rsf/lio_lidar_rate_odom
Error: dump_p2o_with_imufilter_hokuyo_lio.py failed.
```]
  ],
  cause: [
    地図作成コンフィグの `imu_topic` または `lio_topic` が、
    rosbag の内容と一致していません。\
    #tsuyo[`imu_topic` の初期値 `/imu/data` は、
    RSF が実際に配信する `/hokuyo3d/imu` と異なります。]
    設定ファイルを既定値のまま使っていると、このエラーになります。
  ],
  fix: [
    + 表示された `Available:` の一覧から、正しいトピック名を探します。
    + 「ファイル管理」→「設定ファイル管理」で地図作成コンフィグを開き、
      `imu_topic` を `/hokuyo3d/imu` に、
      `lio_topic` を `/rsf/lio_lidar_rate_odom` に合わせます。
    + 行の順序は変えないでください（@err-csv-order）。
  ],
  verify: [
    `Generating p2o graph with gravity edges...` のあと処理が進むこと。
  ],
) <err-gravity-topic>

#errorcard(
  [「--stride must be >= 1」と表示される],
  id: "E-324",
  level: "info",
  symptom: [IMU 補正モードの実行時に上記が表示されて止まる。],
  cause: [
    地図作成コンフィグの `gravity_stride` に 0 以下の値が入っています。
    行の順序がずれて別の値が読まれている場合もあります（@err-csv-order）。
  ],
  fix: [
    + `gravity_stride` を 1 以上の整数に直します。通常は `1` で構いません。
    + 行の並びが @tab-ref-mapping-params のとおりか確認します。
  ],
  verify: [処理が最後まで進むこと。],
) <err-stride>

=== lio_raw モードのエラー <subsubsec-err-mapping-lioraw>

#errorcard(
  [「pc_save_distance must be a number.」と表示される],
  id: "E-325",
  level: "warn",
  symptom: [
    #btn[lio_raw] の実行直後に上記、
    または `wp_save_distance must be a number.` と表示されて止まる。
  ],
  cause: [
    数値であるべき設定値に、文字列が入っています。
    #tsuyo[ほとんどの場合、地図作成コンフィグの行がずれています]。
    行を削除・並べ替えると、トピック名などの文字列がここに読み込まれます。
  ],
  fix: [
    + 地図作成コンフィグの行の並びを @tab-ref-mapping-params と照合します。
    + `pc_save_distance` と `wp_save_distance` が数値になっているか確認します。
    + 詳細は @err-csv-order を参照してください。
  ],
  verify: [
    端末に `Config: Filters: PCD=...m, WP=...m` と正しい数値が表示されること。
  ],
) <err-lioraw-arg>

#errorcard(
  [lio_raw が成功したように見えるのに地図が空],
  id: "E-326",
  level: "danger",
  symptom: [
    エラーは出ず「完了しました」と表示されるが、
    3D Viewer で開くと何も表示されない。または経路ファイルが空になる。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
No point clouds were saved due to filtering or empty data.
Warning: All waypoints were filtered out or removed during stabilization.
```]
  ],
  cause: [
    次のいずれかです。いずれも#tsuyo[異常終了として扱われないため、
    完了フラグが作られます]。
    - `pc_save_distance` が大きすぎて、点群が一度も保存されなかった
    - ロボットがほとんど移動していない rosbag を使った
    - 経路点が 4 個以下だった。
      仕様上、経路の#tsuyo[最初の 2 点と最後の 2 点は自動で削除される]ため、
      少ないと全部消えます
  ],
  fix: [
    + 地図作成コンフィグの `pc_save_distance` を小さくします（例 `1.0` → `0.3`）。
    + `wp_save_distance` を小さくします（例 `4.0` → `0.5`）。
      経路点の数が増え、前後 2 点ずつ削除されても残ります。
    + 走行距離が短すぎる rosbag では地図になりません。
      目安として数十 m 以上走行したデータを使ってください。
    + `map/` にできた `.pcd` のファイルサイズを確認します。
      極端に小さい場合は中身がありません。

      #terminal[```bash
ls -lh ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
```]
  ],
  verify: [
    3D Viewer で点群が表示され、経路点が並んでいること。
  ],
) <err-lioraw-silent>

#errorcard(
  [「Critical Error: Failed to write PCD file」と表示される],
  id: "E-327",
  level: "warn",
  symptom: [
    処理の最後で上記が表示され、地図が保存されない。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Critical Error: Open3D reported failure writing map to .../map/mymap.pcd. File is likely corrupt or access denied.
Critical Error: Failed to write PCD file to ... due to: ...
   Please check file permissions and disk space for directory: ...
```]
  ],
  cause: [
    保存先に書き込めていません。
    ディスクの空き容量不足か、フォルダの権限の問題です。
  ],
  fix: [
    + ディスクの空き容量を確認します（@err-disk-full）。
    + `map/` フォルダに書き込めるか確認します。

      #terminal[```bash
ls -ld ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
touch ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/test.tmp
rm ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/test.tmp
```]
    + `Permission denied` になる場合は、
      フォルダの所有者が別のユーザになっています。管理者にご相談ください。
  ],
  verify: [`map/` に `.pcd` ができること。],
) <err-pcd-write>

=== 環境に起因するエラー <subsubsec-err-mapping-env>

#errorcard(
  [ディスクの空き容量が足りない],
  id: "E-328",
  level: "warn",
  symptom: [
    `No space left on device` と表示される、
    または処理の途中で不明なエラーが出て止まる。
  ],
  cause: [
    マッピングは大量の中間ファイルを作ります。
    点群ファイルは 1 回のマッピングで数 GB になることがあります。
  ],
  fix: [
    + 空き容量を確認します。使用率が 90% を超えていたら不足です。

      #terminal[```bash
df -h ~
```]
    + 不要な作業用フォルダを削除します。
      #tsuyo[`data/` の中は中間ファイルなので、
      地図が完成していれば削除して構いません。]

      #terminal[```bash
du -sh ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/*
```]
    + 使い終わった rosbag を外部ストレージへ移動します。
      rosbag は 1 回の記録で数 GB になります。
    + #tsuyo[`map/` と `waypoints/` は完成品なので削除しないでください。]
  ],
  verify: [十分な空き容量を確保したうえで、マッピングが完了すること。],
) <err-disk-full>

#errorcard(
  [処理の途中で端末が突然閉じる],
  id: "E-329",
  level: "warn",
  symptom: [
    エラーを表示せずに端末が消える。
    地図はできていない。長い rosbag のときに起こりやすい。
  ],
  cause: [
    パソコンのメモリが不足し、処理が強制終了させられています。
    マッピングは点群をメモリ上に展開するため、
    長時間の rosbag では大量のメモリを使います。
  ],
  fix: [
    + 他のアプリケーションをすべて閉じてから、もう一度実行します。
      特にブラウザのタブを減らすと効果があります。
    + rosbag を分割して、区間ごとに地図を作ります。
      複数の地図はマルチマップ走行（@subsec-nav-multi）でつなげられます。
    + 地図作成コンフィグの `pc_save_distance` を大きくします（例 `0.3` → `1.0`）。
      使用する点群が減り、必要なメモリが下がります。
    + メモリの使用状況は次のコマンドで確認できます。

      #terminal[```bash
free -h
```]
  ],
  verify: [端末が閉じずに、処理が最後まで進むこと。],
) <err-oom>

#errorcard(
  [以前に作った地図が消えてしまった],
  id: "E-330",
  level: "danger",
  symptom: [
    マッピングを実行したら、同じ名前の古い地図が無くなっていた。
  ],
  cause: [
    マッピングは、実行時に#tsuyo[同じ地図名の作業用フォルダを無条件で削除します]。
    また、完成した `.pcd` も同名なら上書きされます。
    確認の問い合わせは表示されません。
  ],
  fix: [
    + 消えてしまった地図は元に戻せません。
      元の rosbag が残っていれば、同じ手順で作り直してください。
    + 今後の対策として、#tsuyo[地図名には日付や場所を入れて]
      重複しないようにしてください（例 `toyonaka_20260401`）。
    + 現場で使っている地図は、定期的に別の場所へコピーして保管してください。
      コピーの対象は @tab-ref-files を参照してください。
  ],
  verify: [—],
) <err-map-overwrite>

== 2D 地図変換に関するエラー <subsec-err-pcd2pgm>

#errorcard(
  [「ERROR: 入力PCDファイルが見つかりません: ...」],
  id: "E-401",
  level: "warn",
  symptom: [#btn[pcd2pgm] の実行時に上記が表示されて終了する。],
  cause: [
    指定した `.pcd` が `map/` フォルダに存在しません。
    マッピングが完了していないか、ファイル名を変更した可能性があります。
  ],
  fix: [
    + `map/` フォルダの中身を確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
```]
    + `.pcd` が無い場合は、@sec-mapping のマッピングから実行してください。
    + ある場合は、選択画面で正しいファイルを選び直してください。
  ],
  verify: [変換が進み、`map/` に `.pgm` と `.yaml` ができること。],
) <err-pcd-notfound>

#errorcard(
  [「WARNING: ウェイポイントファイルが見つかりません。ウェイポイントなしで続行します」],
  id: "E-402",
  level: "info",
  symptom: [
    2D 地図はできるが、経路に沿った通行可能領域（緑）が作られない。
  ],
  cause: [
    指定した経路ファイルが `waypoints/` に見つからなかったため、
    #tsuyo[経路なしで変換が実行されました]。処理自体は成功しています。
  ],
  fix: [
    + `waypoints/` フォルダに経路ファイルがあるか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/
```]
    + 経路に沿った通行可能領域が必要な場合は、
      正しい経路ファイルを指定して #btn[pcd2pgm] をやり直してください。
    + 経路ファイルが無い場合は、@sec-mapping のマッピングを実行すると
      経路の下書きが同時に作られます。
  ],
  verify: [
    3D Viewer で 2D 地図を表示したとき、
    経路に沿って緑色の通行可能領域が表示されること。
  ],
) <err-wp-notfound>

#errorcard(
  [2D 地図が真っ黒（全面が障害物）になる],
  id: "E-403",
  level: "warn",
  symptom: [
    変換はできたが、3D Viewer で見ると地図のほぼ全面が赤（障害物）になっている。
  ],
  cause: [
    高さの切り出し範囲が広すぎて、#tsuyo[地面や天井まで障害物として投影]されています。
  ],
  fix: [
    + 地図作成コンフィグの `thre_z_min` を上げます。
      地面が写り込んでいる場合、`-1.0` → `-0.2` のように 0 に近づけます。
    + `thre_z_max` を下げます。天井が写り込んでいる場合、
      `20.0` → `2.0` のようにロボットの高さ程度まで下げます。
    + 値を変更したら #btn[pcd2pgm] をやり直します。
      #tsuyo[3D 地図を作り直す必要はありません。]
    + 目安として、`thre_z_min` は地面の少し上、
      `thre_z_max` はロボットが通過できる高さの上限に設定します。
  ],
  verify: [
    3D Viewer で 2D 地図を表示し、壁や柱の位置だけが赤くなっていること。
  ],
) <err-pgm-dark>

#errorcard(
  [2D 地図が真っ白（障害物が写らない）になる],
  id: "E-404",
  level: "warn",
  symptom: [
    変換はできたが、壁や柱が地図に写っていない。
  ],
  cause: [
    高さの切り出し範囲が狭すぎるか、ノイズ除去が強すぎて
    本来の障害物まで消えています。
  ],
  fix: [
    + 地図作成コンフィグの `thre_z_min` と `thre_z_max` の幅を広げます。
    + `thres_point_count` を小さくします（例 `1`）。
      この値が大きいと、点の少ない細い柱やポールが消えます。
    + `thre_radius` を小さくします（例 `0.1`）。
      この値が大きいと、まばらな本物の障害物まで削られます。
    + `flag_pass_through` の設定を確認します。
      特定の高さの点だけを抽出する設定になっていると、対象が絞られすぎることがあります。
    + 変更後、#btn[pcd2pgm] をやり直します。
  ],
  verify: [3D Viewer で壁や柱が赤く表示されること。],
) <err-pgm-light>

#errorcard(
  [変換後に地図が一覧へ反映されない],
  id: "E-405",
  level: "info",
  symptom: [
    2D 地図変換は成功したのに、自律走行の `MAPFILE` の一覧に出てこない。
  ],
  cause: [
    ブラウザが古い一覧を表示しているだけの場合がほとんどです。
    2D 地図変換の最後には `colcon build` が自動実行されますが、
    これが失敗していた場合も反映されません。
  ],
  fix: [
    + ブラウザのページを再読み込みしてから、もう一度確認します。
    + それでも出ない場合、変換を実行した端末に
      `ERROR: colcon build がエラーコード ... で失敗しました。` が
      出ていないか確認します。
    + 出ていた場合は、手動でビルドし直します。

      #terminal[```bash
cd ~/colcon_ws
colcon build --symlink-install --packages-select hokuyo_navigation2
source install/setup.bash
```]
    + `map/` に `.yaml` ができているか確認します（@err-nav-no-map）。
  ],
  verify: [`MAPFILE` の一覧に地図名が表示されること。],
) <err-map-notlisted>

#errorcard(
  [「Error: 'open3d' and 'scipy' are required.」と表示される],
  id: "E-406",
  level: "warn",
  symptom: [変換の開始直後に上記が表示されて終了する。],
  cause: [2D 地図変換に必要な Python パッケージが導入されていません。],
  fix: [
    #terminal[```bash
pip3 install open3d numpy scipy pyyaml Pillow
```]
    詳細は @err-py-module を参照してください。
  ],
  verify: [`Initial point cloud size: ...` と表示され、処理が進むこと。],
) <err-pgm-module>

#errorcard(
  [「Error: Loaded point cloud is empty」と表示される],
  id: "E-407",
  level: "warn",
  symptom: [
    PCD ファイルは存在するのに、読み込むと空だと言われる。
  ],
  cause: [
    元になった 3D 点群地図に点が入っていません。
    マッピングが見かけ上成功して、中身が空だった場合に起こります。
  ],
  fix: [
    + `.pcd` のファイルサイズを確認します。極端に小さい場合は中身がありません。

      #terminal[```bash
ls -lh ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
```]
    + 3D Viewer で `.pcd` を開き、点が表示されるか確認します。
    + 空だった場合は、マッピングからやり直してください。
      原因は @err-lioraw-silent または @err-flag-only を参照してください。
  ],
  verify: [
    `Initial point cloud size:` に十分な点数（数万以上）が表示されること。
  ],
) <err-pgm-empty-pcd>

#errorcard(
  [経路ファイルの読み込みに失敗する],
  id: "E-408",
  level: "warn",
  symptom: [
    経路を選んだのに、通行可能領域（緑）が作られない。
  ],
  shown: [
    #console(title: "変換の端末")[```
Warning: Waypoint file is empty or invalid format. Skipping waypoint processing.
Error loading waypoint file ...: Expecting value: line 1 column 1 (char 0)
Warning: Invalid waypoint format found: [...]. Skipping.
```]
  ],
  cause: [
    経路ファイルが空、壊れている、または想定した構造になっていません。
    #tsuyo[いずれの場合も処理は続行され、経路なしの 2D 地図ができます]。
  ],
  fix: [
    + 経路ファイルの中身を確認します。エラーが出れば壊れています。

      #terminal[```bash
python3 -m json.tool ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/<経路名>.json | head
```]
    + 中身が `[]` だけなら経路点が 0 個です。
      マッピングの段階で経路が作られていません（@err-lioraw-silent）。
    + Map Viewer で経路を開き直して #btn[ウェイポイントを保存] を押すと、
      正しい形式で保存し直せます。
    + 修正後、#btn[pcd2pgm] をやり直してください。
  ],
  verify: [
    端末に `Loaded N waypoints.` と表示され、
    3D Viewer で緑の通行可能領域が見えること。
  ],
) <err-pgm-wp-broken>

#errorcard(
  [「Filtered point cloud is empty, cannot create map.」と表示される],
  id: "E-409",
  level: "warn",
  symptom: [
    高さフィルタの適用後に上記が表示され、2D 地図が作られない。
  ],
  shown: [
    #console(title: "変換の端末")[```
Applying PassThrough filter (Z: 1.5 to 2.0)
After PassThrough filtering: 0 points
Warning: Point cloud is empty, skipping RadiusOutlier filtering.
Error: Filtered point cloud is empty, cannot create map.
```]
  ],
  cause: [
    高さの切り出し範囲（`thre_z_min` 〜 `thre_z_max`）に点が 1 つも入っていません。
    範囲が狭すぎるか、地図の高さの基準とずれています。
  ],
  fix: [
    + 端末の `After PassThrough filtering: N points` の数を確認します。
      0 なら範囲が外れています。
    + まず範囲を大きく広げて、点が残るか試します。
      `thre_z_min` を `-5.0`、`thre_z_max` を `20.0` にして実行してください。
    + 点が残ったら、`thre_z_max` を少しずつ下げて天井を除き、
      `thre_z_min` を少しずつ上げて地面を除きます。
    + `flag_pass_through` が `False` になっていると
      高さの範囲が使われないことがあります。`True` にして試してください。
  ],
  verify: [
    `After PassThrough filtering:` に十分な点数が残り、
    `Generated PGM map: ...` と表示されること。
  ],
) <err-pgm-filter-empty>

#errorcard(
  [「An unexpected error occurred」と表示される],
  id: "E-410",
  level: "warn",
  symptom: [変換の途中で想定外のエラーが表示されて終了する。],
  cause: [
    上記以外の理由で処理が失敗しています。
    メモリ不足、ディスク容量不足、PCD ファイルの破損が考えられます。
  ],
  fix: [
    + 表示されたエラー文の#tsuyo[最後の 1 行]を控えてください。
    + `Killed` や `MemoryError` を含む場合はメモリ不足です（@err-oom）。
      `map_resolution` を大きくする（例 `0.05` → `0.1`）と負荷が下がります。
    + `No space left` を含む場合はディスク容量不足です（@err-disk-full）。
    + それ以外の場合は、@subsec-trouble-report の情報を添えてお問い合わせください。
  ],
  verify: [`Successfully converted and saved map files.` と表示されること。],
) <err-pgm-unexpected>

== 自律走行に関するエラー <subsec-err-nav>

#errorcard(
  [`MAPFILE` の一覧に地図が出てこない],
  id: "E-501",
  level: "warn",
  symptom: [
    自律走行の開始画面で `MAPFILE` のプルダウンを開いても、
    使いたい地図が一覧にない。
  ],
  cause: [
    `MAPFILE` の一覧には、`map/` フォルダにある
    #tsuyo[`.yaml` ファイル]の名前だけが表示されます。
    3D 地図（`.pcd`）を作っただけでは `.yaml` はできないため、一覧に出てきません。
  ],
  fix: [
    + @sec-2d-map の手順で、その地図に対して #btn[pcd2pgm] による
      2D 地図変換を実行してください。
    + 変換後、`map/` フォルダに `<地図名>.pgm` と `<地図名>.yaml` の
      2 つができていることを確認します。
    + ブラウザのページを再読み込みしてから、もう一度プルダウンを開きます。
  ],
  verify: [`MAPFILE` の一覧に地図名が表示されること。],
) <err-nav-no-map>

#errorcard(
  [`CSVファイル` の一覧にシナリオファイルが出てこない],
  id: "E-502",
  level: "warn",
  symptom: [
    `NAVTYPE` で `multi_map` を選んだが、`CSVファイル` のプルダウンが空、
    または作ったはずのファイルが出てこない。
  ],
  cause: [
    シナリオファイルとして認識されるのは、`config/` フォルダにある CSV のうち
    #tsuyo[1 行目が次の文字列と完全に一致するもの]だけです。
    #terminal[```csv
map_file,waypoint_file,nav_type,interval
```]
    見出しの綴り違い、カンマの前後の空白、余分な空白行があると認識されません。
    地図作成コンフィグ（`option_name,value,default` で始まる CSV）は
    別の種類のファイルなので、ここには表示されません。
  ],
  fix: [
    + 「ファイル管理」→「設定ファイル管理」から該当の CSV を開き、
      #btn[テキスト編集] で 1 行目を確認します。
    + 1 行目を上記の文字列に正確に直します。
      #tsuyo[カンマの前後に半角スペースを入れないでください。]
    + 保存後、ブラウザのページを再読み込みします。
  ],
  verify: [`CSVファイル` の一覧にファイル名が表示されること。],
) <err-nav-no-csv>

#errorcard(
  [地図と経路の名前が食い違っていて走行できない],
  id: "E-503",
  level: "warn",
  symptom: [
    走行を開始しても地図が表示されない、
    または Nav2 の端末に地図の読み込み失敗が表示される。
  ],
  cause: [
    3D 地図（`.pcd`）、2D 地図（`.pgm`, `.yaml`）は、
    #tsuyo[拡張子を除いた名前が一致している必要があります]。
    2D 地図変換のときに 3D 地図と違う出力名を指定すると食い違いが起こります。
  ],
  fix: [
    + 「ファイル管理」→「マップ管理」で `map/` フォルダの中身を確認します。
    + 同じ地図に対して `<地図名>.pcd` `<地図名>.pgm` `<地図名>.yaml` の
      3 つがそろい、名前が一致しているか確認します。
    + 食い違っている場合は、ファイル名をダブルクリックして名前を統一します。
      #tsuyo[拡張子は変更できません]（変更しようとすると
      「拡張子の変更はできません。ファイル名のみ変更してください。」と表示されます）。
    + `.yaml` の中には `.pgm` のファイル名が書かれています。
      `.pgm` の名前を変えた場合は、
      #btn[テキスト編集] で `.yaml` の中の `image:` の行も同じ名前に直してください。
  ],
  verify: [
    走行開始後に RViz2 へ 2D 地図が表示され、その上に経路が並ぶこと。
  ],
) <err-map-name>

#errorcard(
  [「警告: ... init_pose.txt が見つかりません。」と表示される],
  id: "E-504",
  level: "warn",
  symptom: [
    走行開始時の端末に次のように表示され、
    ロボットが地図上のまったく違う場所にいることになってしまう。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
警告: /home/hokuyo/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/toyonaka/init_pose.txt が見つかりません。デフォルトの初期位置を使用します。
警告: ... /init_lat_lon_alt.txt が見つかりません。デフォルトの緯度経度を使用します。
```]
  ],
  cause: [
    地図ごとの初期位置ファイルは、マッピング実行時に
    #path[data/<地図名>/] へ自動で作られます。
    このファイルが無いと、原点（0, 0, 0）と緯度 35 度・経度 135 度が
    仮の初期位置として使われるため、自己位置推定が正しく始まりません。\
    地図ファイルだけを別のパソコンからコピーしてきた場合によく起こります。
  ],
  fix: [
    + #path[data/] フォルダに、その地図名のフォルダがあるか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/
```]
    + 別のパソコンで作った地図であれば、
      そのパソコンの #path[data/<地図名>/] フォルダごとコピーしてください。
      #tsuyo[地図ファイルを移すときは `data/` の中身も一緒に移すのが原則です。]
    + 元データ（rosbag）が手元にある場合は、@sec-mapping のマッピングを
      同じ地図名でやり直せば、初期位置ファイルも作り直されます。
  ],
  verify: [
    走行開始時に上記の警告が出ないこと。
    RViz2 でロボットの位置が地図上の正しい場所に表示されること。
  ],
) <err-init-pose>

#errorcard(
  [走り出さない／自己位置が地図と合わない],
  id: "E-505",
  level: "danger",
  symptom: [
    走行を開始してもロボットが動かない。
    または、RViz2 上でロボットが地図からずれた場所・壁の中などに表示される。
  ],
  cause: [
    自己位置推定が成立していません。
    座標系（TF）のつながりが切れていることが多く、
    @im-frames-ng のように `map` が他とつながっていない状態になっています。
  ],
  fix: [
    + 座標系のつながりを図で確認します。

      #terminal[```bash
ros2 run rqt_tf_tree rqt_tf_tree
```]
    + `loc` モードでは `map` → `odom` → `base_link`、
      `gnss` モードでは `map` → `base_link` がつながっている必要があります
      （@im-frames）。
    + `map` が切り離されている場合、自己位置推定ノードが地図を読めていません。
      指定した地図の `.pcd` が `map/` フォルダにあるか確認してください（@err-map-name）。
    + 初期位置がずれている場合は @err-init-pose を確認します。
    + ロボットを#tsuyo[地図を作り始めた場所とほぼ同じ位置・向き]に置き直してから、
      もう一度開始してください。自己位置推定は初期位置の近くから探索を始めます。
    + 周囲の環境が地図作成時から大きく変わっている（棚の移動、車両の駐車など）と
      照合に失敗します。その場合は地図を作り直してください。
  ],
  verify: [
    `rqt_tf_tree` で木が 1 つにつながっていること。
    RViz2 上でロボットの位置が実際の位置と一致していること。
  ],
) <err-tf-broken>

#errorcard(
  [`Lidar Odom Rate` が赤い／N/A になる],
  id: "E-506",
  level: "warn",
  symptom: [
    RViz2 の `Lidar Odom Rate:` の表示が赤（5 Hz 未満）または `N/A` になっている。
    走行中に位置が飛ぶ、経路から外れる。
  ],
  cause: [
    `N/A` の場合は LIO のデータが届いていません。
    赤の場合はパソコンの処理が追いついておらず、位置の更新が遅れています。
  ],
  fix: [
    + `N/A` の場合は、LIO のトピックが流れているか確認します。

      #terminal[```bash
ros2 topic hz /rsf/lio_lidar_rate_odom
```]
      流れていなければ、RSF との通信の問題です。@err-no-sensor を参照してください。
    + 赤（処理落ち）の場合は、#tsuyo[他のアプリケーションをすべて閉じます]。
      特に、ブラウザで Vizanti と Map Viewer のタブを開いたままにしていると
      負荷が高くなります。走行中は不要なタブを閉じてください。
    + RViz2 の表示項目を減らします。点群の表示は負荷が大きいため、
      不要なら左のリストでチェックを外します。
    + パソコンの電源設定が省電力になっていないか確認します。
      バッテリ駆動時に性能が抑えられている場合があります。
  ],
  verify: [`Lidar Odom Rate:` が緑（9.5 Hz 以上）で安定すること。],
) <err-lio-slow>

#errorcard(
  [同じ地点の手前で行ったり来たりして進まない],
  id: "E-507",
  level: "warn",
  symptom: [
    ある経路点の近くでロボットが前後に細かく動き、次の地点へ進まない。
  ],
  cause: [
    その経路点の到着判定が厳しすぎて、到着したと判定できていません。
    `xy_tolerance`（位置の許容誤差）や `yaw_tolerance`（向きの許容誤差）が
    小さすぎる場合に起こります。
  ],
  fix: [
    + Map Viewer で該当の経路点を選び、「選択中のウェイポイント」ウィジェットで
      `xy_tolerance` を確認します。
    + 値を大きくします。目安として `xy_tolerance` は 0.25〜1.0 [m]、
      `yaw_tolerance` は 0.25〜3.14 [rad] 程度です。
      #tsuyo[通過するだけの地点であれば、向きの許容誤差は大きめ（3.14）で構いません。]
    + 経路点が壁や障害物に近すぎる場合は、通行可能な位置へ動かします。
    + #btn[ウェイポイントを保存] を押してから、走行をやり直します。
  ],
  verify: [その地点を通過し、次の地点へ進むこと。],
) <err-wp-stuck>

#errorcard(
  [「エラー: waypoint_managerが異常終了しました。15秒後に再試行します...」],
  id: "E-508",
  level: "danger",
  symptom: [
    走行が始まらず、端末で 15 秒のカウントダウンと起動を延々と繰り返す。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
エラー: waypoint_managerが異常終了しました。15秒後に再試行します...
ノードの終了を待っています...
再起動待機中: 15 秒...
```]
  ],
  cause: [
    経路をたどるノードが起動できずに落ちています。
    経路ファイルが見つからない、中身が壊れている、
    または Nav2 が立ち上がっていないことが原因です。\
    このスクリプトは#tsuyo[成功するまで自動でやり直す]作りのため、
    原因を直さない限り繰り返し続けます。
  ],
  fix: [
    + まず #btn[ロボット停止] を押して、繰り返しを止めます。
    + 指定した経路ファイルが `waypoints/` にあるか確認します。
      GUI で選んだ名前に `.json` を付けたものが実際のファイル名です。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/
```]
    + 経路ファイルの中身が壊れていないか確認します。
      次のコマンドでエラーが出れば、ファイルが壊れています。

      #terminal[```bash
python3 -m json.tool ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/<経路名>.json > /dev/null
```]
      壊れている場合は、Map Viewer で経路を開き直して保存し直すか、
      マッピングからやり直して経路を作り直してください。
    + 経路ファイルが空（`[]` だけ）になっていないか確認します。
      経路点が 1 つもないと走行できません。
    + Nav2 側が起動しているか確認します。

      #terminal[```bash
ros2 node list | grep -i nav
```]
  ],
  verify: [
    `ウェイポイント追従を開始します: <経路名>.json` と表示され、
    カウントダウンが再び始まらないこと。
  ],
) <err-wp-manager>

#errorcard(
  [マルチマップ走行が終わらない],
  id: "E-509",
  level: "info",
  symptom: [
    シナリオファイルの最後まで走ったのに、また 1 行目から走り始める。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
=== CSVファイルの最後まで処理しました。ループを再開します。 ===
```]
  ],
  cause: [
    #tsuyo[異常ではありません。] マルチマップ走行は、
    シナリオファイルを最後まで処理すると先頭に戻って繰り返す仕様です。
  ],
  fix: [
    1 周で終わらせたい場合は、最後の地図を走り終えた時点で
    メイン画面の #btn[ロボット停止] を押してください。
  ],
  verify: [「現在のモード」が「停止モード」に戻ること。],
)

== ビルド・セットアップに関するエラー <subsec-err-build>

#errorcard(
  [`colcon build` が失敗する],
  id: "E-601",
  level: "warn",
  symptom: [
    ビルド時に `Failed   <<< hokuyo_navigation2` のような表示が出て終了する。
  ],
  cause: [
    依存パッケージが不足しているか、環境の読み込みが済んでいません。
  ],
  fix: [
    + ROS 2 の環境を読み込んでいるか確認します。

      #terminal[```bash
source /opt/ros/humble/setup.bash
```]
    + 依存パッケージを自動で導入します。

      #terminal[```bash
cd ~/colcon_ws
rosdep update
rosdep install -i --from-path src/hokuyo_navigation2 --ignore-src -r -y
```]
    + URDF 関連のパッケージを個別に導入します。

      #terminal[```bash
sudo apt-get install ros-humble-tf-transformations \
  ros-humble-joint-state-publisher ros-humble-robot-state-publisher
```]
    + 必要なフォルダが無いとビルドに失敗することがあります。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
mkdir -p map waypoints rosbag
```]
    + 古いビルド結果が残っている場合は、削除してからビルドし直します。

      #terminal[```bash
cd ~/colcon_ws
rm -rf build install log
colcon build --symlink-install
```]
  ],
  verify: [
    `colcon build` が `Summary: ... 0 packages failed` で終わること。
  ],
) <err-build-fail>

#errorcard(
  [`hokuyo_slam_ros2` のビルドが通らない],
  id: "E-602",
  level: "warn",
  symptom: [
    `cmake` の実行時に PCL または PROJ が見つからないというエラーが出る。
  ],
  cause: [
    `hokuyo_slam_ros2` は #tsuyo[PCL 1.14 と PROJ 9.4] に依存しており、
    Ubuntu 標準のパッケージでは版数が合いません。
    手順どおりに個別にビルドして導入する必要があります。
  ],
  fix: [
    + 先に必要な開発用パッケージを導入します。

      #terminal[```bash
sudo apt-get install libsqlite3-dev sqlite3 libeigen3-dev \
  qtbase5-dev clang qtcreator libqt5x11extras5-dev
```]
    + PROJ と PCL を @sec-setup の手順どおりに導入します。
      #tsuyo[PCL のビルドは 30 分以上かかることがあります。]
      途中で中断しないでください。
    + PCL の場所を環境変数で指定してから `hokuyo_slam_ros2` をビルドします。

      #terminal[```bash
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/opt/pcl
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_slam_ros2
cmake -Bbuild . && cmake --build build
```]
    + この環境変数は端末を閉じると消えます。毎回設定するのが面倒な場合は、
      `~/.bashrc` の末尾に上記の `export` の行を追記してください。
  ],
  verify: [
    `find ~/colcon_ws -name run_p2o -type f` で実行ファイルが見つかること。
  ],
) <err-build-pcl>

#errorcard(
  [サブモジュールのフォルダが空になっている],
  id: "E-603",
  level: "warn",
  symptom: [
    `vizanti` や `hokuyo_slam_ros2` などのフォルダはあるが、中身が空。
  ],
  cause: [
    クローン時に `--recursive` を付け忘れたか、
    途中で通信が切れてサブモジュールの取得に失敗しています。
  ],
  fix: [
    + サブモジュールを取得し直します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
git submodule update --init --recursive
```]
    + 取得後、各フォルダに中身が入っているか確認します。

      #terminal[```bash
ls hokuyo_navigation2 hokuyo_navigation2_gui vizanti hokuyo_slam_ros2
```]
    + 取得できたら、改めてビルドをやり直してください。
  ],
  verify: [すべてのサブモジュールのフォルダに中身があること。],
) <err-submodule>

#errorcard(
  [GUI サーバの起動時に Python のエラーが出る],
  id: "E-604",
  level: "warn",
  symptom: [
    `start_server.sh` を実行すると、端末に `ModuleNotFoundError` や
    `ImportError` が表示されてサーバが起動しない。
  ],
  shown: [
    #console(title: "GUI サーバの端末")[```
Error: Core logic file (rosbag2_filter_core.py) or ROS 2 libraries not found/sourced: ...
```]
  ],
  cause: [
    GUI サーバに必要な Python パッケージが入っていないか、
    ROS 2 の環境が読み込まれていません。
  ],
  fix: [
    + 必要な Python パッケージを導入します。

      #terminal[```bash
pip3 install flask flask-sockets gevent gevent-websocket websockets pyyaml
```]
    + パッケージ一覧からまとめて導入することもできます。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip3 install -r requirements.txt
```]
    + ROS 2 の環境を読み込んでから起動し直します。

      #terminal[```bash
source /opt/ros/humble/setup.bash
source ~/colcon_ws/install/setup.bash
```]
    + 表示されたモジュール名が上記に無い場合は、
      そのモジュール名を `pip3 install` に指定して導入してください。
  ],
  verify: [
    `Flask Server starting at http://0.0.0.0:5050` と表示されること。
  ],
)

== 端末メッセージ逆引き表 <subsec-msg-index>

マッピングおよび 2D 地図変換の実行中に端末へ表示されるメッセージから、
該当するエラー番号を引くための一覧です。
#tsuyo[表示された文言の一部で探してください]（可変部分は `...` としています）。

#note[
  この表は上から#tsuyo[処理の順番]に並んでいます。
  複数のメッセージが出ている場合は、#tsuyo[いちばん上（最初）に出たもの]が
  本当の原因であることがほとんどです。
]

=== 準備の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`--> [X] 無効なマッピングオプションです: ...`], [@err-mapping-nostart],
    [`No such file or directory`（sync 選択時）], [@err-sync-missing],
    [`Error: 引数が不足しています ...`], [@err-mapping-nostart],
    [`エラー: 'run_p2o' 実行ファイルが見つかりませんでした。`], [@err-no-runp2o],
    [`Error: Path ... does not exist (neither file nor folder).`], [@err-bag-notfound],
    [`WARNING: Config file not found at ... Using default values.`], [@err-csv-order],
    [（何も表示されずに端末が閉じる）], [@err-mapping-nostart],
    [`ModuleNotFoundError` / `ImportError`], [@err-py-module],
  ),
  caption: [準備の段階のメッセージ],
) <tab-msg-prep>

=== GNSS 品質確認の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`Error (ROS 2): Topic '...' not found in '...'`], [@err-gnsslog-fail],
    [`Error (ROS 2): Unsupported message type '...'`], [@err-gnsslog-fail],
    [`Error (ROS 1): Message type not found for topic '...'`], [@err-gnsslog-fail],
    [`Error (ROS 1): Topic ID not found for topic '...'`], [@err-gnsslog-fail],
    [`No valid messages with position covariance found ...`], [@err-gnsslog-fail],
    [`Error (ROS 2) opening bag file '...'`], [@err-bag-notfound],
    [`Error: No .mcap or .db3 files found in '...'`], [@err-bag-notfound],
    [`Warning: ... does not have 'position_covariance'. Skipping.`], [@err-gnsslog-fail],
    [`fix トピックの共分散のfix率が ...% です。`], [@err-fix-rate],
    [（`p2o 開始` が表示されずに終了する）], [@err-p2o-nogo],
  ),
  caption: [GNSS 品質確認の段階のメッセージ],
) <tab-msg-gnsslog>

=== グラフ生成の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示、または `output.p2o` の中身*], [*参照*],
    [`Topic '...' not found in bag file.`], [@err-p2o-stdout],
    [`Error: Could not retrieve LIO or GNSS messages.`], [@err-p2o-stdout],
    [`Error: Could not import message type '...'`], [@err-p2o-stdout],
    [`Error: Could not find message class in module for '...'`], [@err-p2o-stdout],
    [`Error: Invalid message type name '...'`], [@err-p2o-stdout],
    [`Error reading message: ...`], [@err-p2o-stdout],
    [`Error: data/... /output.p2o is empty.`], [@err-p2o-empty],
    [`rosbag play でfixメッセージがあるかの確認と、...`], [@err-py-module],
    [（`center_utm.txt` が作られない）], [@err-no-valid-gnss],
    [（地図の座標が現場とかけ離れる）], [@err-utm-zone],
  ),
  caption: [グラフ生成の段階のメッセージ],
) <tab-msg-graph>

=== 最適化・点群処理の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`can't open file: .../center_utm.txt`], [@err-no-valid-gnss],
    [`can't open file: .../output.p2o`], [@err-p2o-stdout],
    [`Error: run_p2o optimization failed or produced empty output.`], [@err-p2o-optfail],
    [`Usage: sample_run_p2o [-m max_iter] ...`], [@err-runp2o-silent],
    [`ERROR: Couldn't read file cloud_...pcd`], [@err-pcd-extract],
    [`Warning: No valid points found in message at timestamp ...`], [@err-pcd-extract],
    [`Error: concat.txt is empty.`], [@err-concat-broken],
    [`Warning: Skipping malformed log line: ...`], [@err-concat-broken],
    [`エラー: ログファイル ... を開けません。`], [@err-concat-broken],
    [`使用法: ... <ログファイル名> <PCD出力ファイル名のベース> ...`], [@err-concat-broken],
  ),
  caption: [最適化・点群処理の段階のメッセージ],
) <tab-msg-opt>

=== 保存の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`エラー：p2o ファイルの行数が不足しています。`], [@err-runp2o-silent],
    [`エラー：p2o ファイルのデータ形式が不正です。`], [@err-runp2o-silent],
    [`p2o ファイルが見つかりません。`], [@err-runp2o-silent],
    [`入力ファイルの数値形式が不正です。`], [@err-concat-broken],
    [`入力ファイルが見つかりません。`], [@err-concat-broken],
    [`エラー：入力ファイルの形式が不正です。原点の行が見つかりません。`], [@err-concat-broken],
    [`mv: cannot stat '..._Rcord.pcd': No such file or directory`], [@err-flag-only],
    [`情報: Waypointリストの最初2つと最後2つの要素を削除しました。`],
    [（正常）],
    [`警告: Waypointの数が少ないため、...削除をスキップしました。`], [@err-lioraw-silent],
    [`エラー: Waypointファイルを保存できませんでした: ...`], [@err-pcd-write],
    [（ブラウザに「PCDファイルが見つかりません。フラグは存在しましたが...」）], [@err-flag-only],
  ),
  caption: [保存の段階のメッセージ],
) <tab-msg-save>

=== IMU 補正モード（`slam_mode` が `gravity`）

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`RuntimeError: Topic not found or not PointCloud2: ...`], [@err-gravity-mcap],
    [`Error: dump_lidar_pointcloud.py failed. ...`], [@err-gravity-mcap],
    [`RuntimeError: Odom topic '...' not found.`], [@err-gravity-topic],
    [`RuntimeError: IMU topic '...' not found.`], [@err-gravity-topic],
    [`RuntimeError: No odom poses found for topic '...'`], [@err-gravity-topic],
    [`Error: dump_p2o_with_imufilter_hokuyo_lio.py failed.`], [@err-gravity-topic],
    [`FileNotFoundError: index file not found: ...`], [@err-gravity-mcap],
    [`RuntimeError: index file has no valid entries: ...`], [@err-gravity-mcap],
    [`ValueError: --stride must be >= 1`], [@err-stride],
  ),
  caption: [IMU 補正モードのメッセージ],
) <tab-msg-gravity>

=== lio_raw モード

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`Error: pc_save_distance must be a number.`], [@err-lioraw-arg],
    [`Error: wp_save_distance must be a number.`], [@err-lioraw-arg],
    [`Usage: python pcd_tf_extractor.py ...`], [@err-lioraw-arg],
    [`Error: None of the target topics found in bag file.`], [@err-lioraw-fail],
    [`Error: None of the target topics found in DB file.`], [@err-lioraw-fail],
    [`No point clouds were saved due to filtering or empty data.`], [@err-lioraw-silent],
    [`Warning: All waypoints were filtered out or removed ...`], [@err-lioraw-silent],
    [`Critical Error: Open3D reported failure writing map to ...`], [@err-pcd-write],
    [`Critical Error: Failed to write PCD file to ... due to: ...`], [@err-pcd-write],
    [`ERROR: pcd_tf_extractor.py がエラーコード ... で終了しました。`], [@err-lioraw-fail],
  ),
  caption: [lio_raw モードのメッセージ],
) <tab-msg-lioraw>

=== 2D 地図変換（pcd2pgm）

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`ERROR: 入力PCDファイルが見つかりません: ...`], [@err-pcd-notfound],
    [`ERROR: 変換スクリプトが見つかりません: ...`], [@err-pcd-notfound],
    [`Error: 'open3d' and 'scipy' are required.`], [@err-pgm-module],
    [`Error: PCD file not found: ...`], [@err-pcd-notfound],
    [`Error: Loaded point cloud is empty: ...`], [@err-pgm-empty-pcd],
    [`WARNING: ウェイポイントファイルが見つかりません。...`], [@err-wp-notfound],
    [`Warning: Waypoint file not found: ...`], [@err-wp-notfound],
    [`Warning: Waypoint file is empty or invalid format.`], [@err-pgm-wp-broken],
    [`Error loading waypoint file ...`], [@err-pgm-wp-broken],
    [`Warning: Invalid waypoint format found: ...`], [@err-pgm-wp-broken],
    [`After PassThrough filtering: 0 points`], [@err-pgm-filter-empty],
    [`Warning: Point cloud is empty, skipping RadiusOutlier filtering.`], [@err-pgm-filter-empty],
    [`Error: Filtered point cloud is empty, cannot create map.`], [@err-pgm-filter-empty],
    [`Error: Map data not generated. Cannot save files.`], [@err-pgm-filter-empty],
    [`An unexpected error occurred: ...`], [@err-pgm-unexpected],
    [`ERROR: pcd2pgm_converter.py がエラーコード ... で終了しました。`], [@err-pgm-filter-empty],
  ),
  caption: [2D 地図変換のメッセージ],
) <tab-msg-pgm>

=== 全モード共通

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示・症状*], [*参照*],
    [`No space left on device`], [@err-disk-full],
    [`Permission denied`], [@err-pcd-write],
    [`Killed` / `MemoryError` / 端末が突然閉じる], [@err-oom],
    [`ERROR: colcon build がエラーコード ... で失敗しました。`], [@err-build-fail],
    [ブラウザが「処理中」のまま終わらない], [@err-mapping-stuck],
    [以前の地図が消えた], [@err-map-overwrite],
  ),
  caption: [全モード共通のメッセージ],
) <tab-msg-common>

== 問い合わせるときに用意するもの <subsec-trouble-report>

本章の対処で解決しない場合は、次の情報をそろえてご連絡いただくと、
原因の特定が早くなります。

#figure(
  stable(
    columns: (auto, 1fr),
    [*項目*], [*内容*],
    [発生した工程], [データ取得／マッピング／2D 地図変換／自律走行のどれか],
    [画面の写真], [ブラウザの赤い帯、および端末に出ているメッセージの写真],
    [操作の手順], [どのボタンを、どの順序で押したか],
    [使ったファイル名], [地図名、経路名、シナリオファイル名],
    [設定ファイル], [使用した地図作成コンフィグ（CSV）の内容],
    [再現性], [毎回起きるのか、たまに起きるのか],
    [ソフトウェア版数], [本書が対象とする版数（表紙に記載）],
  ),
  caption: [問い合わせ時に用意する情報],
) <tab-report-items>

#tip[
  自律走行の端末に流れた文字は、上へスクロールすれば残っています。
  #tsuyo[エラーが出た行だけでなく、その 20 行ほど手前から]写真に撮っていただくと、
  どの段階で止まったかが分かり、解決が早くなります。
]

#pagebreak()
