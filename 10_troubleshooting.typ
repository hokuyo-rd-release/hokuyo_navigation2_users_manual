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
    [ファイルの整理・受け渡しがうまくいかない], [@subsec-err-gui],
    [ビルドやインストールが通らない], [@subsec-err-build],
    [端末やブラウザに出たメッセージから探したい], [@subsec-msg-index],
  ),
  caption: [症状から探す索引],
) <tab-trouble-index>

#tip[
  #tsuyo[表示された文言そのもので探すのがいちばん確実です。]
  @subsec-msg-index に、端末とブラウザに出るメッセージの
  #tsuyo[逆引き表]をまとめています。
  文言の一部（可変部分を除いた部分）で探してください。
]

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
    Vizanti の画面は開くが、#tsuyo[グリッドも座標軸も含めて何も表示されない]。\
    （画面そのものは表示されていて、トピックの一覧だけが空という場合は
    @err-vizanti-rosapi です。）
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
    Vizanti の画面にグリッドと座標軸が表示されること。
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
  [Vizanti の画面は出るが、トピックの一覧がどこも空になる],
  id: "E-104",
  level: "danger",
  symptom: [
    Vizanti は開き、グリッドや座標軸は表示される。
    しかし、次のようにトピックを選ぶ欄が#tsuyo[すべて空]で、何も選べない。
    - Bag Recorder の「Topics：」に何も出てこない
    - Joystick Teleop の「Topic：」が空で、速度トピックを選べない
    - Add Widgets の #tsuyo[By Topic] タブに何も並ばない
  ],
  shown: [
    Vizanti を起動した端末に、次のような表示が出ています。
    #console(title: "Vizanti を起動した端末")[```
[rosapi_node-2] Traceback (most recent call last):
[rosapi_node-2]   File ".../rosapi/lib/rosapi/rosapi_node", line 44, in <module>
[rosapi_node-2]     from rosapi import glob_helper, objectutils, params, proxy
[rosapi_node-2]   File ".../rosapi/params.py", line 43, in <module>
[rosapi_node-2]     from ros2param.api import call_get_parameters, call_set_parameters, get_parameter_value
[rosapi_node-2] ImportError: cannot import name 'get_parameter_value' from 'ros2param.api'
[ERROR] [rosapi_node-2]: process has died [pid ..., exit code 1, ...]
```]
  ],
  cause: [
    Vizanti にトピックの一覧を教える `rosapi` というノードが、
    起動直後に停止しています。\
    原因は、`rosbridge_suite` が
    #tsuyo[使用中の ROS ディストリビューションと違うブランチ]に
    なっていることです。
    #dist-humble 用の古いブランチのまま #dist-jazzy で動かすと、
    Jazzy で置き場所が変わった関数（`get_parameter_value`）を
    読み込めずに停止します。\
    トピックの一覧が取れないだけで、Vizanti の表示自体は動くため、
    #tsuyo[「画面は出ているのに選べない」という分かりにくい症状]になります。
  ],
  fix: [
    + 次のコマンドで、`rosapi` が動いているかを確認します。
      応答が返らない（数十秒待っても止まったまま）なら、この症状です。

      #terminal[```bash
ros2 service call /rosapi/topics_for_type \
  rosapi_msgs/srv/TopicsForType "{type: 'sensor_msgs/msg/PointCloud2'}"
```]
    + `rosbridge_suite` が#tsuyo[どのブランチになっているか]を確認します。
      `*` が付いている行が現在のブランチです。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/rosbridge_suite
git branch
```]

      #console(title: "誤ったブランチになっている例")[```
* humble
  jazzy
```]
    + @tab-pkg-submodules の#tsuyo[正しいブランチに切り替えます]。
      Jazzy であれば `jazzy` です。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
git submodule update --init --remote rosbridge_suite
```]

      うまく切り替わらない場合は、直接指定します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/rosbridge_suite
git fetch origin
git checkout jazzy
```]
    + ビルドし直し、サーバを起動し直します。

      #terminal[```bash
cd ~/colcon_ws
colcon build --packages-select rosapi rosbridge_library rosbridge_server
source install/setup.bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh && ./start_server.sh
```]
  ],
  verify: [
    上のコマンドが、次のようにトピック名を返すこと。

    #console(title: "直ったときの表示")[```
response:
rosapi_msgs.srv.TopicsForType_Response(topics=['/hokuyo3d/hokuyo_cloud2'])
```]

    Vizanti を開き直し、Bag Recorder の「Topics：」に
    トピックが並ぶようになれば復旧しています。
  ],
) <err-vizanti-rosapi>

#danger[
  #tsuyo[この症状を、`rosbridge_suite` のソースを書き換えて直さないでください。]
  一時的に動くようになっても、次に `git submodule update` を実行したときに
  変更が失われ、同じ症状が再発します。
  #tsuyo[ブランチを切り替えるのが正しい直し方]です。
]

#errorcard(
  [ボタンが灰色で押せない],
  id: "E-105",
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
  id: "E-106",
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
  id: "E-107",
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
  id: "E-108",
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

#errorcard(
  [「ディレクトリが見つかりません: ...」],
  id: "E-109",
  level: "warn",
  symptom: [
    ファイル管理や rosbag の選択画面を開いたとき、
    ブラウザ上部に赤い帯でこのメッセージが表示され、一覧が空になる。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
ディレクトリが見つかりません: /home/<ユーザ名>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag
```]
  ],
  cause: [
    表示しようとしたフォルダ自体がありません。
    セットアップ時に #path[map/]、#path[rosbag/]、#path[waypoints/] を
    作り忘れた場合に起こります。
  ],
  fix: [
    + 不足しているフォルダを作ります。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
mkdir -p map rosbag waypoints data gnss_log config
```]
    + ブラウザのページを再読み込みします。
  ],
  verify: [ファイル一覧の画面が正常に開くこと。],
) <err-dir-notfound>

#errorcard(
  [「ファイルまたはディレクトリが選択されていません。」],
  id: "E-110",
  level: "info",
  symptom: [
    #btn[選択] や #btn[削除] を押したときに、赤い帯でこのメッセージが出て先に進まない。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
ファイルまたはディレクトリが選択されていません。
削除するアイテムが選択されていません。
PCDファイルが選択されていません。
```]
  ],
  cause: [
    #tsuyo[行の左端にあるチェックボックスにチェックが入っていません。]
    ファイル名の文字をクリックしただけでは選択したことになりません。
  ],
  fix: [
    + 一覧に戻り、対象の行の#tsuyo[左端の四角（チェックボックス）]をクリックします。
    + チェックが入ったことを確認してから、もう一度ボタンを押します。
  ],
  verify: [次の画面に進むこと。],
) <err-noselect>

#errorcard(
  [「ファイル "..." は既に存在します。」],
  id: "E-111",
  level: "info",
  symptom: [
    ファイル名の変更、または新規ファイルの作成が拒否される。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
ファイル "maps_and_waypoints.csv" は既に存在します。
```]
  ],
  cause: [
    同じ名前のファイルがすでにあります。
    #tsuyo[上書きを防ぐための安全機能]であり、故障ではありません。
  ],
  fix: [
    + 別の名前を付けます。日付を入れると重複しにくくなります
      （例: `route_20260401`）。
    + 古いほうが不要であれば、先に削除してから作成し直します。
      #tsuyo[削除は元に戻せません。] 必要なものは先に控えを取ってください。
  ],
  verify: [新しい名前で作成・変更できること。],
) <err-file-exists>

#errorcard(
  [「拡張子の変更はできません。ファイル名のみ変更してください。」],
  id: "E-112",
  level: "info",
  symptom: [
    ファイル名をダブルクリックして書き換えると、この文言が出て元に戻る。
  ],
  cause: [
    `.pcd` を `.pgm` に変えるなど、#tsuyo[ピリオドより後ろ]を書き換えています。
    拡張子はファイルの種類を表すため、変更できないようになっています。
  ],
  fix: [
    + #tsuyo[ピリオドより前]だけを書き換えてください。\
      例: `old_map.pcd` → `new_map.pcd`（`.pcd` はそのまま）
    + 地図の名前を変えるときは、
      `.pcd` `.pgm` `.yaml` と経路の `.json` を
      #tsuyo[すべて同じ名前]に揃える必要があります（@err-map-name）。
  ],
  verify: [新しい名前が一覧に反映されること。],
) <err-ext-change>

#errorcard(
  [「不正なファイルパスです。」「許可されていないパスへのアクセスが試行されました。」],
  id: "E-113",
  level: "warn",
  symptom: [
    ファイルを開こう・保存しようとすると、赤い帯でこのメッセージが出る。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
不正なファイルパスです。
許可されていないパスへのアクセスが試行されました。
セキュリティ上の理由により、このディレクトリにはアクセスできません。
```]
  ],
  cause: [
    決められたフォルダ（#path[map/]、#path[rosbag/]、#path[waypoints/]、#path[config/]）の
    #tsuyo[外]を指すパスが指定されました。
    ブラウザの URL を直接書き換えたときや、ファイル名に `../` が含まれるときに起こります。
  ],
  fix: [
    + ブラウザで #link("http://localhost:5050")[`http://localhost:5050`] を開き直し、
      #tsuyo[画面のボタンから]たどり直してください。
    + ファイル名に `/` や `..` を使わないでください。
    + 別の場所にあるファイルを使いたい場合は、
      端末で対象のフォルダへコピーしてから操作します。

      #terminal[```bash
cp <元のファイル> ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
```]
  ],
  verify: [ファイルが開けること。],
) <err-path-invalid>

#errorcard(
  [「無効なディレクトリタイプです。」],
  id: "E-114",
  level: "info",
  symptom: [
    ファイル管理の画面を開こうとするとメイン画面に戻され、この文言が出る。
  ],
  cause: [
    ブラウザの URL の末尾（`map` / `wp` / `config` のいずれか）が
    書き換わっています。ブックマークが古い場合にも起こります。
  ],
  fix: [
    + メインページから #btn[ファイル管理] を押して開き直します。
    + 古いブックマークは削除してください。
  ],
  verify: [ファイル管理の画面が開くこと。],
) <err-dirtype>

#errorcard(
  [「警告: YAMLファイル "..." の読み込みに失敗しました。」],
  id: "E-115",
  level: "warn",
  symptom: [
    Map Viewer を開くと 3D 点群は出るが、2D 地図（灰色の面）が出ず、
    黄色い帯でこの警告が出る。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
警告: YAMLファイル "my_map.yaml" の読み込みに失敗しました。
```]
  ],
  cause: [
    2D 地図の設定ファイル（`.yaml`）が無いか、中身が壊れています。
    #tsuyo[2D 地図への変換（@sec-2d-map）をまだ行っていない]場合にもこの警告が出ます。
  ],
  fix: [
    + `.yaml` が存在するか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/ | grep -e .yaml -e .pgm
```]
    + 無ければ @sec-2d-map の手順で 2D 地図を作成します。
    + あるのに読めない場合は中身を確認します。
      `image:`、`resolution:`、`origin:` の 3 行が必要です。

      #terminal[```bash
cat ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/<地図名>.yaml
```]

      #console(title: "正常な .yaml の例")[```
{free_thresh: 0.196, image: akashi_kosen.pgm, negate: 0,
 occupied_thresh: 0.65, origin: [-4.35, -12.40, 0.0], resolution: 0.05}
```]
    + 壊れている場合は 2D 地図への変換をやり直してください。
  ],
  verify: [Map Viewer に 2D 地図が表示されること。],
) <err-yaml-load>

#errorcard(
  [「警告: Waypointファイル "..." の読み込みに失敗しました。」],
  id: "E-116",
  level: "warn",
  symptom: [
    Map Viewer に地図は出るが、経路（色付きの矢印）が表示されない。
  ],
  cause: [
    経路ファイル（`.json`）が無いか、テキスト編集で壊れています。
  ],
  fix: [
    + ファイルの有無を確認します。
      #tsuyo[地図と同じ名前]である必要があります。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/
```]
    + 形式が壊れていないか確認します。
      何も表示されなければ正常、エラーが出れば壊れています。

      #terminal[```bash
python3 -m json.tool \
  ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints/<経路名>.json > /dev/null
```]
    + 壊れている場合は、マッピングをやり直して経路を作り直すか、
      控えのファイルに戻してください。
  ],
  verify: [Map Viewer に経路が表示されること。],
) <err-wp-load>

#errorcard(
  [「ダウンロード用のファイルが見つかりません。」],
  id: "E-117",
  level: "info",
  symptom: [
    ファイル管理から地図や rosbag をダウンロードしようとすると失敗する。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
ダウンロード用のファイルが見つかりません。
ダウンロード用のマップファイルが見つかりません。
ファイルのZIP化中にエラーが発生しました: ...
```]
  ],
  cause: [
    対象のファイルが削除・改名されているか、
    ZIP を作る一時領域の空き容量が不足しています。
  ],
  fix: [
    + 一覧を再読み込みし、ファイルが実在するか確認します。
    + ディスクの空き容量を確認します。
      `Use%` が 95% を超えていたら不足です（@err-disk-full）。

      #terminal[```bash
df -h /
```]
    + 巨大な rosbag は、ダウンロードではなく
      USB メモリへ直接コピーすることをおすすめします。

      #terminal[```bash
cp -r ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<名前> /media/<ユーザ名>/<USB名>/
```]
  ],
  verify: [ファイルがダウンロードできること。],
) <err-download>

#errorcard(
  [PCD から PGM への変換画面で「Internal Server Error」が出る],
  id: "E-118",
  level: "warn",
  symptom: [
    2D 地図への変換画面を開いたときに、
    白い画面に英語で `Internal Server Error` とだけ表示される。
  ],
  shown: [
    #figure(
      image("img/g_pcd2pgm_500.png", width: 82%),
      caption: [変換元 PCD を選ばずに変換画面を開いたときの表示],
    ) <im-pcd2pgm-500>
  ],
  cause: [
    #tsuyo[変換元の PCD ファイルを選ばずに]変換画面を開いています。
    本来は「エラー: 変換元のPCDファイルが指定されていません。」と表示して
    メインページへ戻る動作ですが、
    現在のバージョンでは戻り先の指定に誤りがあるため、
    代わりにこの英語のエラー画面になります。
  ],
  fix: [
    + ブラウザの #btn[戻る] でメインページに戻ります。
      戻れない場合は #link("http://localhost:5050")[`http://localhost:5050`] を開き直します。
    + #btn[マッピング] → #btn[pcd2pgm] の順に押し、
      #tsuyo[一覧から PCD ファイルを選んでから] #btn[PCDとして選択] を押します。
    + 変換画面に「変換元PCDファイル: ○○.pcd」と表示されていることを確認してから
      #btn[変換開始] を押します。
  ],
  verify: [
    変換画面の上部に、選んだ PCD ファイル名が表示されること。
  ],
) <err-pcd2pgm-500>

#errorcard(
  [ブラウザ上部に赤い帯でエラーが表示される（共通）],
  id: "E-119",
  level: "info",
  symptom: [
    操作のあと、画面の上に色の付いた帯でメッセージが出る。
  ],
  cause: [
    GUI は、操作の結果を#tsuyo[画面上部の帯]で知らせます。
    色によって意味が異なります。
  ],
  fix: [
    #figure(
      stable(
        columns: (auto, 1fr),
        [*色*], [*意味と対応*],
        [赤], [エラー。操作は実行されていません。文言を本章から探してください],
        [黄], [警告。一部だけ実行されています。結果を必ず確認してください],
        [青], [案内。次に何をすればよいかの指示です],
        [緑], [成功。操作は完了しています],
      ),
      caption: [画面上部に出る帯の色と意味],
    ) <tab-flash-colors>

    帯は数秒で消えることがあります。
    #tsuyo[読み逃した場合は、同じ操作をもう一度行ってください。]
  ],
  verify: [—],
) <err-flash>

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
      速度トピック名が `/wizurg/cmd_vel` になっているか確認します（@fig-viz-teleop）。
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
  [「Recording started.」と出るのに rosbag が作られない],
  id: "E-204",
  level: "danger",
  symptom: [
    Bag Recorder で #btn[Start recording] を押し、
    「Recording started.」と表示されてアイコンも赤に変わる。
    しかし記録を停止したあと、`rosbag/` の中に#tsuyo[フォルダが 1 つもできていない]。
  ],
  shown: [
    #console(title: "Vizanti の画面に出るメッセージ")[```
Are you sure you want to start recording a bag?   → OK
Recording started.
```]
    その後、停止したときも正常時と同じ表示になります。
    #console(title: "停止したとき")[```
Are you sure you want to stop recording?   → OK
Recording stopped.
```]
  ],
  cause: [
    「Topics：」で#tsuyo[トピックを 1 つも選ばずに]記録を開始しています。\
    Vizanti は「記録の指示を出した」ところまでしか確認しないため、
    実際の記録コマンドが引数不足で失敗しても、
    画面には「Recording started.」と表示されてしまいます。
  ],
  fix: [
    + Bag Recorder の画面を開き、「Topics：」の下に
      #tsuyo[青（オン）になっている項目があるか]を確認します（@fig-viz-bag-topics）。
      すべて灰色（オフ）なら、これが原因です。
    + 型の見出し（`sensor_msgs/msg/PointCloud2` など）をクリックして開き、
      @tab-bag-topics の 5 つをオンにします。
    + 迷う場合は #btn[Select All] を押して全トピックを選んでも構いません。
      ファイルは大きくなりますが、記録漏れは防げます。
    + もう一度 #btn[Start recording] から記録し直します。
  ],
  verify: [
    記録の停止後に、`rosbag/` の中に#tsuyo[日時付きのフォルダ]ができていること。

    #terminal[```bash
ls -lt ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/ | head -3
```]
  ],
) <err-bag-notopic>

#errorcard(
  [Vizanti に点群（Point Cloud）が表示されない],
  id: "E-205",
  level: "info",
  symptom: [
    Vizanti に Point Cloud ウィジェットを追加しても、
    点群が表示されない。または、原点に小さな点が 1 つ出るだけになる。
    ウィジェットの表示は `Status: Ok` のままで、エラーは出ない。
  ],
  cause: [
    #tsuyo[異常ではありません。]
    Vizanti の Point Cloud ウィジェットは実験的な機能で、
    RSF が出力する形式の点群を正しく読めません。
    そのため、すべての点が座標 (0,0,0) として扱われ、1 か所に重なってしまいます。\
    ウィジェットの設定画面にも、次の断り書きが表示されています。
  ],
  shown: [
    #console(title: "Point Cloud ウィジェットの設定画面")[```
Currently experimental and might not decode all cloud formats correctly.
XYZ coordinate data is required, the rest is ignored for now.
```]
  ],
  fix: [
    + #tsuyo[点群を目で確認したい場合は、Vizanti ではなく次のいずれかを使ってください。]
      - GUI の #btn[Map Viewer]（3D Viewer）── 作成済みの地図を見る場合（@sub5）
      - RViz2 ── 記録中のセンサ出力をその場で見る場合
    + データ取得中に「センサが生きているか」を確かめるだけであれば、
      #tsuyo[Pose Tracker の軌跡]（@fig-viz-overview のオレンジの矢印）が
      伸びているかで判断できます。
    + 数値で確かめる場合は、端末で流量を見ます。

      #terminal[```bash
ros2 topic hz /hokuyo3d/hokuyo_cloud2
```]
  ],
  verify: [
    Map Viewer または RViz2 で点群が表示されること。
    Vizanti 側は表示されないままで問題ありません。
  ],
) <err-viz-pointcloud>

#errorcard(
  [センサのデータがまったく届かない],
  id: "E-206",
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
  id: "E-207",
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

#errorcard(
  [「ROS Bagフィルタのコア機能がインポートされていません。ROS環境を確認してください。」],
  id: "E-208",
  level: "warn",
  symptom: [
    rosbag のフィルタ機能を使おうとすると、赤い帯でこのメッセージが出て実行できない。
  ],
  shown: [
    #console(title: "GUI サーバの端末")[```
Error: Core logic file (rosbag2_filter_core.py) or ROS 2 libraries not found/sourced: \
No module named 'rosbag2_py'
```]
  ],
  cause: [
    GUI サーバを#tsuyo[ROS 2 の環境を読み込まずに]起動しています。
    `rosbag2_py` は ROS 2 に付属するため、`source` を忘れると読み込めません。
  ],
  fix: [
    + いったんサーバを停止します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh
```]
    + #tsuyo[必ず `start_server.sh` から]起動し直します。
      このスクリプトの中で ROS 2 の環境が読み込まれます。

      #terminal[```bash
./start_server.sh
```]
    + それでも直らない場合は、端末で直接読み込んでから確認します。

      #terminal[```bash
source /opt/ros/$ROS_DISTRO/setup.bash
source ~/colcon_ws/install/setup.bash
python3 -c "import rosbag2_py; print('OK')"
```]
  ],
  verify: [
    rosbag を選ぶとトピック一覧が表示されること。
  ],
) <err-bagfilter-import>

#errorcard(
  [「選択されたファイル形式はROS Bagとしてサポートされていません。」],
  id: "E-209",
  level: "info",
  symptom: [
    rosbag を選んだのに、この文言が出て先に進まない。
  ],
  cause: [
    ROS 2 の rosbag は#tsuyo[フォルダ]です。
    その中にある `.mcap` や `.db3` の#tsuyo[ファイル 1 つ]を選ぶと、
    形式が違うと判断されることがあります。
    また `.bag`（ROS 1 形式）は扱えません。
  ],
  fix: [
    + 一覧では、#tsuyo[日付から始まるフォルダ名]
      （例: `2026-08-07-14-27-kato-support`）を選んでください。
      その中の `..._0.mcap` は選びません。
    + フォルダの中身が正しいか確認します。
      `metadata.yaml` と `..._0.mcap`（または `.db3`）が必要です。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<rosbag名>/
```]
  ],
  verify: [トピック一覧の画面に進めること。],
) <err-bag-format>

#errorcard(
  [「トピックを一つ以上選択してください。」「出力ファイル名を入力してください。」],
  id: "E-210",
  level: "info",
  symptom: [
    フィルタや変換の実行ボタンを押しても進まず、この文言が出る。
  ],
  shown: [
    #console(title: "ブラウザ上部の表示")[```
トピックフィルタリングにはトピックを一つ以上選択してください。
出力ファイル名を入力してください。
出力マップ名を入力してください。
```]
  ],
  cause: [
    必須の入力が空のままです。
  ],
  fix: [
    + 残したいトピックにチェックを入れます。
      地図作成に必要なトピックは @tab-bag-topics のとおりです。
    + 出力名を入力します。#tsuyo[元の rosbag と同じ名前は使えません。]
      末尾に `_filtered` を付けるなど、区別できる名前にしてください。
    + 出力名に空白や日本語を使わないでください。
      半角英数字、`_`、`-` のみを使います。
  ],
  verify: [処理が始まること。],
) <err-bag-input>

#errorcard(
  [「入力ファイルが見つかりません。パスを確認してください。」],
  id: "E-211",
  level: "warn",
  symptom: [
    トピック一覧までは表示されたのに、実行すると入力ファイルが無いと言われる。
  ],
  cause: [
    画面を開いたあとに、対象の rosbag が削除・改名されました。
    複数のブラウザタブで別々の操作をしている場合に起こりやすい症状です。
  ],
  fix: [
    + 開いているタブをすべて閉じます。
    + #link("http://localhost:5050")[`http://localhost:5050`] を開き直し、
      #tsuyo[1 つのタブだけ]で操作をやり直します。
    + rosbag が実在するか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/
```]
  ],
  verify: [処理が最後まで進むこと。],
) <err-bag-inputmissing>

#errorcard(
  [「リクエストJSONのパースエラー: ...」「処理中にエラーが発生しました: ...」],
  id: "E-212",
  level: "warn",
  symptom: [
    実行ボタンを押した直後に、この文言が出て何も起こらない。
  ],
  cause: [
    ブラウザとサーバの間の通信が途中で壊れたか、
    サーバ側で想定外の例外が発生しています。
    ネットワークが不安定なとき、サーバを再起動した直後などに起こります。
  ],
  fix: [
    + ブラウザのページを再読み込み（#kbd[F5]）してからやり直します。
    + それでも直らない場合は、#tsuyo[GUI サーバの端末]を確認してください。
      `Traceback` で始まる詳しいエラーが出ています。
      その最後の 1 行を控えて、問い合わせ時に添えてください（@subsec-trouble-report）。
    + サーバを再起動します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh && sleep 3 && ./start_server.sh
```]
  ],
  verify: [処理が始まること。],
) <err-json-parse>

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
    [@err-gnsslog-fail \ @err-topic-gnss],

    [③ グラフ生成],
    [rosbag から位置の情報を取り出し、`output.p2o` を作る],
    [@err-p2o-empty \ @err-p2o-stdout \ @err-topic-lio],

    [④ 最適化],
    [`run_p2o` が位置のつじつまを合わせ、`output.p2o_out.txt` を作る],
    [@err-p2o-optfail \ @err-runp2o-silent \ @err-runp2o-segv \ @err-centerutm-broken],

    [⑤ 点群の抽出],
    [rosbag から地図に使う点群を取り出す],
    [@err-pcd-extract \ @err-topic-pc],

    [⑥ 点群の結合],
    [`rearrange_pointcloud` が点群を並べ直し、地図と経路を作る],
    [@err-concat-broken \ @err-savedist-nan],

    [⑦ 座標変換と保存],
    [絶対座標を相対座標に直し、`map/` へ移動して完了フラグを作る],
    [@err-flag-only],
  ),
  caption: [p2o マッピングの処理段階],
) <tab-mapping-stages>

#tip[
  #tsuyo[④ と ⑥ では、設定値の誤りによって「コアダンプ」と表示されて
  強制終了することがあります。]
  条件の一覧は @tab-mapping-coredump にまとめています。
]

#note[
  `lio_raw` モードは③〜⑦を 1 つのプログラムでまとめて行います。
  段階の切り分けができないため、
  #tsuyo[端末の `Config:` の行と、最後の `Total points saved:` の行]で判断します
  （@err-frame-mismatch）。
]

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
      [測位状態], [`status` が 0（FIX）、1（SBAS FIX）、2（GBAS FIX）の
       いずれかであること。#tsuyo[−1（測位できていない）だけが除外されます]],
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
    + `status` が `-1` ばかりの場合は、受信機が測位できていません。
      空が開けた場所で数分待ってから記録し直してください（@err-no-gnss）。
    + それでも採用されない場合は、
      `slam_mode` を `gravity` にして IMU 補正モードで作成するか、
      `lio_raw` モードで GNSS を使わずに作成してください（@subsec-mapping-choose）。
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
    - #tsuyo[`orig_frame` / `target_frame` が LIO トピックと一致していない]
      （最も多い原因。@err-frame-mismatch）
    - #tsuyo[`pointcloud_topic` が rosbag に存在しない]（@err-frame-mismatch）
    - `pc_save_distance` が大きすぎて、点群が一度も保存されなかった
    - ロボットがほとんど移動していない rosbag を使った
    - 経路点が 4 個以下だった。
      仕様上、経路の#tsuyo[最初の 2 点と最後の 2 点は自動で削除される]ため、
      少ないと全部消えます

    #tip[
      端末の `Config:` の行を読むと切り分けられます。
      `Reading topics:` に点群のトピックが載っていなければトピック名の誤り、
      載っているのに 0 点ならフレーム名の誤りです。
    ]
  ],
  fix: [
    + まず `Config: Frames=... -> ...` の行が
      センサ設定と一致しているか確認します（@subsubsec-config-checkframe）。
      #tsuyo[ここが違っていると、他を直しても解決しません。]
    + 地図作成コンフィグで `pc_save_distance` を小さくします
      （例 `1.0` → `0.3`）。`0` にすると間引かずにすべて使います
      （@tab-pcsave-density）。
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

=== 設定ミスによる異常終了と無言の失敗 <subsubsec-err-mapping-config>

コンフィグの値を間違えたときに何が起きるかを @tab-mapping-misconfig にまとめます。
#tsuyo[多くの場合「完了しました」と表示されるため、
端末の途中に出るメッセージを見ないと失敗に気付けません。]

#figure(
  stable(
    columns: (auto, 1fr, auto, auto),
    [*間違えた項目*], [*端末に最初に出る手がかり*], [*完了表示*], [*参照*],
    [`pc_save_distance` / \ `wp_save_distance` \ が数字でない],
    [`エラー: ... に数値として読めない値が指定されました`],
    [出る], [@err-savedist-nan],

    [`pointcloud_topic`（p2o）],
    [`Topic '...' not found in bag file.`],
    [出る], [@err-topic-pc],

    [`lio_topic`（p2o）],
    [`can't open file: data/<地図名>/center_utm.txt`],
    [出る], [@err-topic-lio],

    [`gnss_topic`（p2o）],
    [`Error (ROS 2): Topic '...' not found in '...'`],
    [#tsuyo[出ない]], [@err-topic-gnss],

    [`pointcloud_topic`（lio_raw）],
    [`No point clouds were saved due to filtering or empty data.`],
    [出る], [@err-frame-mismatch],

    [`orig_frame` / `target_frame`（lio_raw）],
    [同上（#tsuyo[それ以外に手がかりが無い]）],
    [出る], [@err-frame-mismatch],
  ),
  caption: [設定を間違えたときに起きること],
) <tab-mapping-misconfig>

#tip[
  #tsuyo[失敗したかどうかは、地図ファイルができているかで判断するのが確実です。]

  #terminal[```bash
ls -lh ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/<地図名>.pcd
```]

  `No such file or directory` と表示されるか、
  サイズが数百 KB 未満であれば失敗しています。
]

#errorcard(
  [「エラー: … に数値として読めない値が指定されました」],
  id: "E-328",
  level: "warn",
  symptom: [
    p2o マッピングの終盤で日本語のエラーが出る。
    #tsuyo[そのあと「完了しました」と表示されるが、地図はできていない。]
  ],
  shown: [
    #console(title: "マッピングの端末（実行例）")[```
Saved 112 point cloud files (mcap).
エラー: 点群結合間隔 (pc_save_distance) に数値として読めない値が指定されました: 'abc'
[Errno 2] No such file or directory: '.../data/<地図名>/<地図名>_Acord.pcd'
入力ファイルが見つかりません。
mv: cannot stat 'data/<地図名>/<地図名>_Rcord.pcd': No such file or directory
P2O SLAM completion flag created: .../map/<地図名>.P2O_DONE
```]

    `wp_save_distance` が原因の場合は、1 行目が次のようになります。

    #console(title: "Waypoint 設置間隔が誤っている場合")[```
エラー: Waypoint設置間隔 (wp_save_distance) には 0 以上の数値を指定してください: '-1'
```]
  ],
  cause: [
    `pc_save_distance` または `wp_save_distance` に、
    #tsuyo[数値として読めない値]が入っています。

    値が空欄になっている、全角数字（`１.０`）になっている、
    単位を付けてしまっている（`1.0m`）、
    末尾に余分な文字や空白がある、負の値になっている、
    といった場合に起こります。
  ],
  fix: [
    + 設定ファイルの該当行を確認します。

      #terminal[```bash
grep -e pc_save_distance -e wp_save_distance \
  ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/<設定ファイル名>.csv
```]
    + 次の形になるよう直します。#tsuyo[すべて半角の数字]で、
      単位（`m`）は付けないでください。

      #terminal[```csv
pc_save_distance,1.0
wp_save_distance,4.0
```]
    + カンマの前後に空白を入れないでください。
    + 保存して、マッピングをやり直します。
      値の意味と目安は @tab-pcsave-density を参照してください。
  ],
  verify: [
    端末に `PointCloud Distance Filter: ... m` と
    `結合した点群: N 枚 / M 枚中` が表示され、N が 0 でないこと。
  ],
) <err-savedist-nan>

#errorcard(
  [`pointcloud_topic` を間違えた（p2o）],
  id: "E-329",
  level: "danger",
  symptom: [
    p2o マッピングが「完了しました」で終わるのに、地図ができていない。
    端末に `Warning: Skipping malformed log line:` が大量に流れる。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
run_p2o
data/<地図名>/output.p2o: 0.416556s
Found MCAP files: ['.../2026-08-07-14-27-kato-support_0.mcap']
Topic '/wrong/cloud' not found in bag file.
Warning: Skipping malformed log line: 	2.8702101437 -1.5885832626 2.1697989125 ...
Warning: Skipping malformed log line: 	2.8715476592 -1.5822422395 2.1695191701 ...
（同じ警告が数百行続く）
[pcl::PCDWriter::writeASCII] Input point cloud has no data!
PCDファイルを保存しました: <地図名>_Acord.pcd
エラー：入力ファイルの形式が不正です。原点の行が見つかりません。
```]
  ],
  cause: [
    `pointcloud_topic` に書いた名前が rosbag に存在しないため、
    点群が 1 つも取り出せていません。

    `Topic '...' not found in bag file.` が#tsuyo[本当の原因を示す 1 行]です。
    その後の大量の警告は、点群が無いことによる二次的な症状です。
  ],
  fix: [
    + rosbag に実在するトピック名を確認します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ros2 bag info rosbag/<rosbag名>
```]
    + `sensor_msgs/msg/PointCloud2` 型で `Count:` が 0 でないものを探します。
      多くの場合 `/hokuyo3d/hokuyo_cloud2` です。
    + 設定ファイルの `pointcloud_topic` を、その名前に直します。
      #tsuyo[先頭の `/` を含めて一字一句同じ]にしてください。
    + 保存して、マッピングをやり直します。
  ],
  verify: [
    端末に `Saved N point cloud files (mcap).` が表示され、
    N が 0 でないこと。
  ],
) <err-topic-pc>

#errorcard(
  [`lio_topic` を間違えた（p2o）],
  id: "E-330",
  level: "danger",
  symptom: [
    p2o マッピングが「完了しました」で終わるのに、地図ができていない。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
p2o_from_rosbag
error status: 0
run_p2o
can't open file: data/<地図名>/center_utm.txt
Found MCAP files: ['.../2026-08-07-14-27-kato-support_0.mcap']
Traceback (most recent call last):
  File ".../src/extract_pcd_ros2.py", line 163, in extract_and_save_pointcloud_mcap
    with open(lio_edge_timestamps_path, "r") as f:
FileNotFoundError: [Errno 2] No such file or directory: \
'.../data/<地図名>/lio_edge_timestamps.txt'
[pcl::PCDWriter::writeASCII] Input point cloud has no data!
エラー：p2o ファイルの行数が不足しています。
```]
  ],
  cause: [
    `lio_topic` に書いた名前が rosbag に存在しないため、
    位置の情報が 1 つも取り出せていません。

    #tsuyo[`error status: 0` と表示されていても失敗しています。]
    本当の手がかりは、その次の
    `can't open file: data/<地図名>/center_utm.txt` の行です。
  ],
  fix: [
    + rosbag に実在するトピック名を確認します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ros2 bag info rosbag/<rosbag名>
```]
    + `nav_msgs/msg/Odometry` 型で `Count:` が 0 でないものを探します。
      `/rsf/lio_imu_rate_odom` または `/rsf/lio_lidar_rate_odom` のどちらかです
      （@tab-lio-topics）。
    + 設定ファイルの `lio_topic` を、その名前に直します。
    + 保存して、マッピングをやり直します。
  ],
  verify: [
    #path[data/\<地図名\>/] に `center_utm.txt` ができていること。

    #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/
```]
  ],
) <err-topic-lio>

#errorcard(
  [`gnss_topic` を間違えた（p2o）],
  id: "E-331",
  level: "danger",
  symptom: [
    p2o マッピングを開始しても、端末がすぐ止まって何も進まない。
    ブラウザは「処理中」のまま終わらない。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Found ROS 2 bag file (prioritized): .../2026-08-07-14-27-kato-support_0.mcap
Error (ROS 2): Topic '/wrong/fix' not found in '.../2026-08-07-14-27-kato-support_0.mcap'.
cat: gnss_log/<地図名>_gnss_cov_0.01.csv: No such file or directory
```]
  ],
  cause: [
    `gnss_topic` に書いた名前が rosbag に存在しません。

    p2o は最初に GNSS の品質を調べますが、その結果ファイルが作られないため、
    #tsuyo[それ以降の処理そのものが実行されません]。
    完了フラグも作られないため、ブラウザは終了を検知できません。
  ],
  fix: [
    + ブラウザの「処理中」のタブを閉じます。
    + rosbag に実在する GNSS のトピック名を確認します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ros2 bag info rosbag/<rosbag名>
```]
    + `sensor_msgs/msg/NavSatFix` 型で `Count:` が 0 でないものを探します。
      多くの場合 `/fix` です。
    + 設定ファイルの `gnss_topic` を、その名前に直します。
    + GNSS を使わずに地図を作りたい場合は、
      `slam_mode` を `lio_raw` にするか、
      #btn[lio_raw] モードでマッピングしてください（@subsec-mapping-choose）。
  ],
  verify: [
    端末に `ROS 2 data from '...' written to .../gnss_log/<地図名>_gnss_cov_....csv`
    と表示され、`p2o 開始` へ進むこと。
  ],
) <err-topic-gnss>

#errorcard(
  [フレーム名の指定ミスで、何のエラーも出ずに空の地図ができる（lio_raw）],
  id: "E-332",
  level: "danger",
  symptom: [
    lio_raw マッピングが正常に終わったように見えるのに、
    #path[map/] に `.pcd` がまったく作られていない。
    経路（`.json`）だけはできている。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Config: PCD=/hokuyo3d/hokuyo_cloud2, ODOM=/rsf/lio_imu_rate_odom, TF=/dummy_tf
Config: Frames=wrong_frame -> lio_odom

Starting data processing...
  PointCloud Distance Filter: 1.0 m
  Waypoint Distance Filter: 4.0 m

--- Processing Finished ---
No point clouds were saved due to filtering or empty data.

✅ Waypoints saved successfully to .../waypoints/<地図名>.json
   Total waypoints: 3
LIO-RAW処理とPCDファイル抽出が完了しました。
```]
  ],
  cause: [
    `orig_frame` または `target_frame` が、
    LIO トピックの中身と一致していません。

    lio_raw は、位置情報の座標系名がこの 2 つと一致する場合にだけ点群を保存します。
    一致しない場合、#tsuyo[警告もエラーも出さずに]すべての点群を捨てます。
    残るのは
    `No point clouds were saved due to filtering or empty data.`
    という 1 行だけです。

    `pointcloud_topic` を間違えた場合も、同じ 1 行だけが出ます。
  ],
  fix: [
    + まず `Config:` の行を読み、指定内容を確認します。
      `Reading topics:` に点群のトピックが含まれていなければ、
      原因は `pointcloud_topic` です（@err-topic-pc と同じ直し方）。
    + フレーム名を、センサ設定ファイルの値に合わせます
      （@tab-config-frame-map）。

      #terminal[```bash
grep -e odom_frame -e lidr_frame \
  ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/rsf_node_config.yaml
```]

      #console(title: "確認の表示例")[```
    odom_frame: "lio_odom"     ← target_frame に書く値
    lidr_frame: "yvt"          ← orig_frame に書く値
```]
    + 設定ファイルを次のように直します。

      #terminal[```csv
orig_frame,yvt,yvt
target_frame,lio_odom,lio_odom
```]
    + 保存して、マッピングをやり直します。
    + rosbag から直接確かめる方法は @subsubsec-config-checkframe を参照してください。
  ],
  verify: [
    端末に `Total points saved: N points.` が表示され、N が 0 でないこと。
    #path[map/] に `.pcd` ができていること。
  ],
) <err-frame-mismatch>

#errorcard(
  [`center_utm.txt` が壊れていて run_p2o が異常終了する],
  id: "E-333",
  level: "warn",
  symptom: [
    p2o マッピングの `run_p2o` の直後に異常終了する。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
run_p2o
terminate called after throwing an instance of 'std::invalid_argument'
  what():  stoi
Aborted (core dumped)
```]
  ],
  cause: [
    #path[data/\<地図名\>/center_utm.txt] の中身が数値として読めません。
    前回の処理が途中で止まったまま残っている場合に起こります。
  ],
  fix: [
    + 中身を確認します。`ゾーン番号,X,Y,Z` の 4 つの数値が必要です。

      #terminal[```bash
cat ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/center_utm.txt
```]
    + 壊れている場合は、作業用フォルダごと削除してやり直します。
      #tsuyo[このフォルダは処理の途中経過であり、削除しても地図や rosbag は消えません。]

      #terminal[```bash
rm -rf ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>
```]
    + 改めてマッピングを実行します。
  ],
  verify: [
    `run_p2o` のあとに `data/<地図名>/output.p2o: ...s` と表示され、処理が続くこと。
  ],
) <err-centerutm-broken>

#errorcard(
  [「Segmentation fault (core dumped)」で run_p2o が異常終了する],
  id: "E-334",
  level: "danger",
  symptom: [
    p2o マッピングで `run_p2o` と表示された直後に異常終了する。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
p2o 開始
p2o_from_rosbag
error status: 0
run_p2o
.../hokuyo_slam.bash: line 311: 274733 Segmentation fault      (core dumped) \
bash -c ".../run_p2o data/<地図名>/center_utm.txt data/<地図名>/output.p2o"
```]
  ],
  cause: [
    最適化に渡す中間ファイル
    #path[data/\<地図名\>/output.p2o] の中身が空、あるいは壊れています。
    次のいずれかで起こります。

    - `lio_topic` や `gnss_topic` の指定が誤っていて、位置情報が 1 つも取れなかった
      （@err-topic-lio、@err-topic-gnss）
    - 走行距離が短すぎて、最適化に使える点が作られなかった
    - 前回の処理がディスク不足などで途中で止まり、ファイルが途中までしか書かれていない
      （@err-disk-full）

    #note[
      GNSS 補正モードには、この中間ファイルが空かどうかを事前に確認する処理がありません。
      そのため、空のまま最適化に渡されて異常終了します。
      IMU 補正モード（`slam_mode` が `gravity`）では、
      代わりに `Error: data/<地図名>/output.p2o is empty.` と表示されて停止します
      （@err-p2o-empty）。
    ]
  ],
  fix: [
    + 中間ファイルの大きさを確認します。

      #terminal[```bash
ls -l ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>/output.p2o
```]

      #tsuyo[サイズが 0、または数百バイト程度なら中身がありません。]
    + トピック名の指定を確認します。
      これが最も多い原因です（@subsubsec-config-checktopic）。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ros2 bag info rosbag/<rosbag名>
```]
    + 作業用フォルダを削除してから、やり直します。
      #tsuyo[このフォルダは処理の途中経過であり、削除しても rosbag は消えません。]

      #terminal[```bash
rm -rf ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data/<地図名>
```]
    + ディスクの空き容量を確認します。

      #terminal[```bash
df -h ~
```]
    + 走行距離が短い rosbag では地図になりません。
      数十 m 以上走行したデータを使ってください。
  ],
  verify: [
    端末に `data/<地図名>/output.p2o: 0.4s` のように
    最適化の所要時間が表示され、処理が続くこと。
  ],
) <err-runp2o-segv>

=== 異常終了（コアダンプ）が起きる条件の一覧 <subsubsec-mapping-coredump>

「コアダンプ」は、プログラムが#tsuyo[途中で強制終了]したことを表す表示です。
マッピングで発生しうる条件を @tab-mapping-coredump にまとめます。

#plain[
  「コアダンプ」と出ても、パソコンやセンサが壊れたわけではありません。
  #tsuyo[設定の値かデータに問題がある]というだけです。
  設定を直して、もう一度マッピングを実行すれば直ります。
]

#figure(
  stable(
    columns: (auto, auto, 1fr, auto),
    [*端末の表示*], [*止まる場所*], [*原因*], [*参照*],
    [`Aborted (core dumped)` \ `what(): stoi`],
    [最適化の開始直後],
    [`center_utm.txt` の中身が数値でない],
    [@err-centerutm-broken],

    [`Segmentation fault` \ `(core dumped)`],
    [最適化],
    [`output.p2o` が空、または壊れている],
    [@err-runp2o-segv],
  ),
  caption: [マッピングで異常終了が起きる条件],
) <tab-mapping-coredump>

#warn[
  #tsuyo[異常終了しても、多くの場合そのまま処理が続き「完了しました」と表示されます。]
  完了表示を信用せず、地図ファイルができているかを必ず確認してください
  （@subsubsec-mapping-success）。
]

#tip[
  異常終了すると、作業フォルダに `core.12345` のようなファイルが残ることがあります。
  #tsuyo[これは調査用の記録ファイルで、削除して構いません。]
  数十 MB〜数 GB になることがあるため、溜まっている場合は削除してください。

  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
ls -lh core.* 2>/dev/null
rm -f core.*
```]
]

=== 環境に起因するエラー <subsubsec-err-mapping-env>

#errorcard(
  [ディスクの空き容量が足りない],
  id: "E-335",
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
  id: "E-336",
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
  id: "E-337",
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

#errorcard(
  [「Error: 引数が不足しています \<...\>」],
  id: "E-338",
  level: "warn",
  symptom: [
    マッピングを実行すると、端末に一瞬この文言が出て終了する。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Error: 引数が不足しています <rosbagベース名>
Error: 引数が不足しています <マップ名>
Error: 引数が不足しています <MAP_DIR>
Error: 引数が不足しています <FLAG_FILE_NAME>
```]
  ],
  cause: [
    GUI からマッピング用スクリプトへ渡す値の一部が空でした。
    #tsuyo[出力マップ名を入力せずに] #btn[マッピング開始] を押した場合や、
    スクリプトを端末から手動で実行して引数を省いた場合に起こります。
  ],
  fix: [
    + GUI に戻り、#tsuyo[出力マップ名]の欄が空でないことを確認します。
    + 名前に空白や日本語を使わないでください。
      空白があると、そこで引数が区切られてしまいます。
      半角英数字、`_`、`-` のみを使います。
    + rosbag を選び直してから、もう一度 #btn[マッピング開始] を押します。
  ],
  verify: [
    端末に `All args are checked.` と表示され、処理が続くこと。
  ],
) <err-missing-arg>

#errorcard(
  [「ERROR: 変換スクリプトが見つかりません: ...」],
  id: "E-339",
  level: "danger",
  symptom: [
    2D 地図への変換を実行すると、すぐにこの文言が出て終了する。
  ],
  shown: [
    #console(title: "変換の端末")[```
ERROR: 変換スクリプトが見つかりません: \
/home/<ユーザ名>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/src/pcd2pgm_converter.py
```]
  ],
  cause: [
    変換処理の本体である Python スクリプトが、あるべき場所にありません。
    ソースコードの取得が途中で終わっている場合や、
    誤って削除した場合に起こります。
  ],
  fix: [
    + ファイルの有無を確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/src/*.py
```]
    + 無い場合は、ソースコードを取得し直します。
      #tsuyo[作成済みの地図・経路・rosbag は消えません]が、
      念のため事前に控えを取ってください。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
git checkout -- hokuyo_navigation2/src
git submodule update --init --recursive
```]
    + それでも復旧しない場合は @subsec-trouble-report を参照して問い合わせてください。
  ],
  verify: [
    変換の端末に `--> [1] PCDファイルからPGMマップへのPython変換を開始します。` と表示されること。
  ],
) <err-script-missing>

#errorcard(
  [「ERROR: colcon build がエラーコード ... で失敗しました。」],
  id: "E-340",
  level: "warn",
  symptom: [
    地図の作成そのものは終わったように見えるが、
    最後にこの文言が出て、GUI の一覧に地図が現れない。
  ],
  shown: [
    #console(title: "マッピングの端末")[```
Building package hokuyo_navigation2 to include new map files...
ERROR: colcon build がエラーコード 1 で失敗しました。マップが正しく読み込めない可能性があります。
```]
  ],
  cause: [
    地図ファイルを作ったあと、それをシステムへ反映するための再ビルドが失敗しました。
    #tsuyo[地図ファイル自体は作られています]が、
    自律走行から参照できない状態です。
    別の端末で `colcon build` を同時に実行している場合にも起こります。
  ],
  fix: [
    + 地図ファイルができているかを確認します。

      #terminal[```bash
ls -la ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/
```]
    + 他の端末で実行中のビルドがあれば、終わるまで待ちます。
    + 手動でビルドをやり直します。

      #terminal[```bash
cd ~/colcon_ws
colcon build --symlink-install --packages-select hokuyo_navigation2
```]
    + ビルドが失敗する場合は、表示されたエラーに応じて
      @err-build-fail を参照してください。
  ],
  verify: [
    `Summary: 1 package finished` と表示され、
    GUI の地図一覧に新しい地図が現れること。
  ],
) <err-build-after-map>

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
    + #tsuyo[サンプル以外のモータドライバを使っている場合]は、
      そのドライバが `odom` → `base_link` の TF を配信していないか確認してください。
      同じ TF を 2 つのノードが配信していると、
      木はつながって見えるのに#tsuyo[位置が小刻みに飛び跳ねます]。
      端末に次の警告が繰り返し出ていれば、これが原因です（@subsubsec-setup-userdriver-tf）。

      #console(title: "TF が二重に配信されているときの警告")[```
TF_REPEATED_DATA ignoring data with redundant timestamp for frame base_link
TF_OLD_DATA ignoring data from the past for frame base_link
```]
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
) <err-nav-loop>

#errorcard(
  [「エラー: map_server の起動確認がタイムアウトしました。」],
  id: "E-510",
  level: "warn",
  symptom: [
    自律走行を開始すると、端末に状態の表示が繰り返し出たあと、
    30 秒ほどでこの文言が出て、最初からやり直しになる。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
map_server の起動を待っています...
現在の状態: unknown
現在の状態: unknown
エラー: map_server の起動確認がタイムアウトしました。
エラー: map_server の起動に失敗しました。再試行します...
```]
  ],
  cause: [
    2D 地図を配信する `map_server` が起動しませんでした。
    ほとんどの場合、#tsuyo[指定した地図の `.yaml` か `.pgm` が無い]ことが原因です。
  ],
  fix: [
    + 地図の 3 点セットが揃っているか確認します。
      #tsuyo[拡張子を除いた名前がすべて同じ]である必要があります。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map
ls -1 <地図名>.*
```]

      #console(title: "正常な場合の表示")[```
akashi_kosen.pcd
akashi_kosen.pgm
akashi_kosen.yaml
```]
    + `.pgm` と `.yaml` が無い場合は、@sec-2d-map の 2D 地図変換を行ってください。
    + `.yaml` の中の `image:` が、実在する `.pgm` の名前と一致しているか確認します。

      #terminal[```bash
cat <地図名>.yaml
```]
    + 名前を変更した場合は、@err-map-name の手順ですべて揃え直してください。
  ],
  verify: [
    端末に `map_server はすでに Active です。` と表示されること。
  ],
) <err-mapserver-timeout>

#errorcard(
  [「エラー: Nav2の起動確認がタイムアウトしました。現在の状態: ...」],
  id: "E-511",
  level: "danger",
  symptom: [
    地図の読み込みまでは進むが、その後 60 秒ほど待たされてこの文言が出る。
    そのまま自動で最初からやり直し、#tsuyo[何度も同じことを繰り返す]。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
Nav2のライフサイクル状態とアクションサーバーの準備を監視しています...
Debug: bt_navigator state is 'unconfigured', action server ready: 0...
エラー: Nav2の起動確認がタイムアウトしました。現在の状態: unconfigured
エラー: Nav2の起動に失敗しました。再試行します...
```]
  ],
  cause: [
    経路計画を行う Nav2 の一部が起動に失敗しています。
    Nav2 は複数のプログラムが連携して動くため、
    #tsuyo[どれか 1 つでも落ちると全体が「準備完了」になりません]。
    #tsuyo[設定ファイルの記述ミス]が最も多い原因です。
  ],
  fix: [
    + #tsuyo[まず、どのプログラムが落ちているかを特定します。]
      自律走行の端末をさかのぼり、
      `process has died` または `terminate called` を含む行を探してください。

      #console(title: "落ちているプログラムを示す行の例")[```
[ERROR] [controller_server-5]: process has died [pid 177247, exit code -6, ...]
```]
    + 見つかったプログラム名に応じて対処します。

      #figure(
        stable(
          columns: (auto, 1fr),
          [*落ちたプログラム*], [*参照先*],
          [`map_server`], [@err-mapserver-timeout],
          [`controller_server` / \ `planner_server` など],
          [Nav2 の設定ファイル #path[config/nav2/] の記述ミスが原因です。
           下の「設定値の誤りを見つける」を参照してください],
          [上記以外], [@subsec-trouble-report（端末の内容を添えて問い合わせ）],
        ),
        caption: [落ちたプログラムごとの参照先],
      ) <tab-nav2-died>
    + #tsuyo[設定値の誤りを見つける。]
      `terminate called` の直後の行に、問題のある項目名が示されます。

      #console(title: "設定値の誤りを示す行の例")[```
terminate called after throwing an instance of 'rclcpp::exceptions::InvalidParameterTypeException'
  what():  parameter 'height' has invalid type: Wrong parameter type, \
parameter {height} is of type {integer}, setting it to {double} is not allowed.
```]

      この例では、#path[config/nav2/nav2_params.yaml] の `height` が
      #tsuyo[整数で書くべきところを小数（`6.0`）で書いている]ことを表しています。
      該当箇所を `6` のように直してください。
      #tsuyo[Nav2 の設定ファイルは、値の書き方（整数か小数か）が違うだけでも起動しません。]
    + 繰り返しを止めるには、GUI の #btn[ロボット停止] を押します。
      GUI が反応しない場合は @subsec-nav-stop の手順で停止してください。
  ],
  verify: [
    端末に `Nav2システムおよびアクションサーバーの準備が完全に完了しました。` と表示されること。
  ],
) <err-nav2-timeout>

#errorcard(
  [「エラー: オプションファイルが見つかりません: ...」],
  id: "E-512",
  level: "danger",
  symptom: [
    自律走行を開始すると、ほぼ何も表示されないまま端末が終了する。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
エラー: オプションファイルが見つかりません: \
/home/<ユーザ名>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/wizurg_opts/nav_opt_lio.csv
```]
  ],
  cause: [
    走行時の起動オプションをまとめた設定ファイルがありません。
    #path[config/wizurg_opts/] のファイルを削除・改名した場合に起こります。
  ],
  fix: [
    + フォルダの中身を確認します。
      `nav_opt_lio.csv`、`plural_opt_lio.csv`、`sensor_rosbag_lio.csv` の
      3 つが必要です。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/wizurg_opts/
```]
    + 不足している場合は、ソースから復元します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
git checkout -- hokuyo_navigation2/config/wizurg_opts
```]
    + 各ファイルの意味は @tab-ref-wizurg-opts を参照してください。
  ],
  verify: [
    端末に `--- 実行パラメータ ---` が表示されること。
  ],
) <err-opt-missing>

#errorcard(
  [「エラー: マップリストファイルが見つかりません: ...」],
  id: "E-513",
  level: "warn",
  symptom: [
    マルチマップ走行を開始すると、すぐに端末が終了する。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
エラー: マップリストファイルが見つかりません: \
/home/<ユーザ名>/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/maps_and_waypoints.csv
```]
  ],
  cause: [
    走行順序を書いたシナリオファイル（CSV）が見つかりません。
    GUI で選んだあとに削除・改名した場合に起こります。
  ],
  fix: [
    + #path[config/] にシナリオファイルがあるか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/config/*.csv
```]
    + 無い場合は、#btn[ファイル管理] → #btn[設定ファイル管理] から新規作成します。
      #tsuyo[1 行目は次のとおりでなければなりません]（@err-nav-no-csv）。

      #terminal[```csv
map_file,waypoint_file,nav_type,interval
```]
    + 作成後に自律走行の画面を開き直し、一覧から選び直してください。
  ],
  verify: [
    シナリオファイルが `CSVファイル` の一覧に表示され、走行が始まること。
  ],
) <err-scenario-missing>

#errorcard(
  [「警告: 不明なナビゲーションタイプです: '...'」],
  id: "E-514",
  level: "warn",
  symptom: [
    走行は始まるが、意図した自己位置推定の方式で動いていないように見える。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
警告: 不明なナビゲーションタイプです: 'LOC'。デフォルト設定を使用します。
警告: 不明なナビゲーションタイプです: 'gnss '。デフォルト(loc)を使用します。
```]
  ],
  cause: [
    シナリオファイルの `nav_type` 列が `loc` または `gnss` になっていません。
    #tsuyo[大文字（`LOC`）や、前後の空白（`gnss␣`）でも一致しません。]
  ],
  fix: [
    + #btn[ファイル管理] → #btn[設定ファイル管理] からシナリオファイルの
      #btn[編集] を押し、表形式の画面で `Nav Type` を選び直します。
      #tsuyo[表形式の画面を使えば、この誤りは起こりません。]
    + テキスト編集を使う場合は、`loc` か `gnss` を#tsuyo[小文字で、空白を入れずに]
      書いてください。
    + カンマの前後に空白を入れないでください。
  ],
  verify: [
    端末に `ナビゲーションタイプ: LIO (Localization)` または
    `ナビゲーションタイプ: GNSS` と表示されること。
  ],
) <err-navtype>

#errorcard(
  [「Timeout waiting for TF from map to base\_link after ... seconds. Shutting down.」],
  id: "E-515",
  level: "warn",
  symptom: [
    Nav2 の準備完了までは進むのに、経路の追従が始まらず、
    #tsuyo[待機時間（既定 50 秒）]が過ぎたところで終了する。
    そのあと 15 秒待って自動的にやり直される。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[INFO] [nav2_waypoint_manager_executor]: Waiting for transform from map to base_link...
[ERROR] [nav2_waypoint_manager_executor]: Timeout waiting for TF from map to base_link \
after 50.0 seconds. Shutting down.
エラー: waypoint_managerが異常終了しました。15秒後に再試行します...
```]
  ],
  cause: [
    地図上での自分の位置が求まっていません。
    `loc` モードでは `simple_fastlio_localization` が
    #tsuyo[現在の点群と 3D 点群地図を照合]して位置を出しますが、
    これが成立していない状態です。
  ],
  fix: [
    + ロボットが#tsuyo[地図を作ったときの出発地点付近]にいるか確認します。
      大きく離れていると照合できません。
    + センサのデータが流れているか確認します。
      数値が表示され続ければ正常です。

      #terminal[```bash
ros2 topic hz /hokuyo3d/hokuyo_cloud2
ros2 topic hz /rsf/lio_imu_rate_odom
```]
    + 座標系のつながりを図で確認します。
      `map` が切り離されていれば自己位置推定が動いていません（@err-tf-broken）。

      #terminal[```bash
ros2 run rqt_tf_tree rqt_tf_tree
```]
    + 3D 点群地図（`.pcd`）が読み込めているか確認します。
      端末に `parameter map_file not specified` が出ている場合は
      @err-locmap-param を参照してください。
    + それでも直らない場合は、いったん停止し、
      #tsuyo[ロボットを出発地点へ戻してから]開始し直してください。
  ],
  verify: [
    端末に `TF from map to base_link is available. Nav2 should be ready.` と表示されること。
  ],
) <err-tf-timeout>

#errorcard(
  [「parameter map\_file not specified」],
  id: "E-516",
  level: "warn",
  symptom: [
    `loc` モードで走行を開始すると、自己位置推定のプログラムがすぐに終了する。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[ERROR] [localization_node]: parameter map_file not specified
```]
  ],
  cause: [
    自己位置推定に使う 3D 点群地図（`.pcd`）の場所が渡っていません。
    選んだ地図名に対応する `.pcd` が #path[map/] に無い場合に起こります。
  ],
  fix: [
    + 選んだ地図名の `.pcd` があるか確認します。

      #terminal[```bash
ls ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/map/<地図名>.pcd
```]
    + 無い場合は、@sec-mapping のマッピングをやり直して 3D 点群地図を作成します。
    + `.pgm` だけがあって `.pcd` が無い場合、
      #tsuyo[`gnss` モードでは走れますが `loc` モードでは走れません]。
      走行モードの選び方は @subsec-nav-mode を参照してください。
  ],
  verify: [
    RViz2 に 3D 点群地図（白い点の集まり）が表示されること。
  ],
) <err-locmap-param>

#errorcard(
  [「Nav2 action server not available after waiting!」「Goal was rejected by action server」],
  id: "E-517",
  level: "warn",
  symptom: [
    経路の追従を始めようとした瞬間に終了し、やり直しが繰り返される。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[INFO] [nav2_waypoint_manager_executor]: Waiting for Nav2 action server...
[ERROR] [nav2_waypoint_manager_executor]: Nav2 action server not available after waiting!
[ERROR] [nav2_waypoint_manager_executor]: Goal was rejected by action server
```]
  ],
  cause: [
    Nav2 が「準備完了」と判定された直後に落ちたか、
    目標地点が#tsuyo[地図の外]あるいは#tsuyo[障害物の中]を指しています。
  ],
  fix: [
    + 端末をさかのぼり、`process has died` が無いか確認します。
      あれば @err-nav2-timeout の手順で対処します。
    + 経路が 2D 地図の範囲内に収まっているか、
      Map Viewer で 2D 地図と経路を重ねて確認します（@sec-waypoint）。
    + 経路が壁の中や、真っ黒に潰れた領域を通っていないか確認します。
      通っている場合は 2D 地図の作り直し（@subsec-2dmap-tips）か、
      経路の引き直しが必要です。
    + 1 点目の目標がロボットの現在地から遠すぎないか確認します。
  ],
  verify: [
    端末に `Goal accepted. Starting custom arrival check...` と表示されること。
  ],
) <err-goal-rejected>

#errorcard(
  [「Timeout: Odometry switch type did not become stable within ... seconds.」],
  id: "E-518",
  level: "warn",
  symptom: [
    `gnss` モードで開始したときだけ、
    `gnss-lio-switch initializing...` の表示が続いたあとに終了する。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[INFO] [nav2_waypoint_manager_executor]: gnss-lio-switch initializing... Timeout in 12.3 seconds.
[ERROR] [nav2_waypoint_manager_executor]: Timeout: Odometry switch type did not become stable \
within 30 seconds. Shutting down.
```]
  ],
  cause: [
    RSF が「いま GNSS と LIO のどちらを使っているか」を知らせる
    `/rsf/rsf_odom_type` が届いていないか、値が安定していません。
    センサとの通信ができていない場合や、
    GNSS の受信状況が悪く切り替えが頻繁に起きている場合に発生します。
  ],
  fix: [
    + トピックが流れているか確認します。

      #terminal[```bash
ros2 topic echo /rsf/rsf_odom_type --once
```]
    + 何も表示されない場合は、センサとの通信が切れています（@err-no-sensor）。
    + 表示されるが値が頻繁に変わる場合は、GNSS の受信環境が悪い状態です。
      空が広く見える場所へ移動してから開始してください（@err-no-gnss）。
    + 屋内など GNSS が使えない場所では、
      #tsuyo[`loc` モードに切り替えて]走行してください（@subsec-nav-mode）。
  ],
  verify: [
    端末に `gnss-lio-switch is stable now.` と表示されること。
  ],
) <err-switch-timeout>

#errorcard(
  [「Failed to decode JSON in ...」「Invalid JSON format in ...」],
  id: "E-519",
  level: "warn",
  symptom: [
    走行を開始した直後に、経路の読み込みで失敗して終了する。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[ERROR] [nav2_waypoint_manager_executor]: Failed to decode JSON in myroute.json. \
Please check the file format.
[ERROR] [nav2_waypoint_manager_executor]: Invalid JSON format in myroute.json. \
Expected [[x, y, 0.0], [0.0, 0.0, z, w], {'type': '...', 'value': ...}].
```]
  ],
  cause: [
    経路ファイルが壊れています。
    テキスト編集で直接書き換えた場合や、
    保存の途中で GUI サーバが止まった場合に起こります。
  ],
  fix: [
    + 形式が壊れていないか確認します。
      何も表示されなければ正常です。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/waypoints
python3 -m json.tool <経路名>.json > /dev/null
```]
    + 壊れている場合は、Map Viewer で経路を開き直し、
      #btn[ウェイポイントを保存] で保存し直してください（@sec-waypoint）。
    + 開くこともできない場合は、マッピングをやり直して経路を作り直します。
    + #tsuyo[経路ファイルはテキスト編集で直接書き換えないでください。]
      必ず Map Viewer から編集してください。
  ],
  verify: [
    端末に `Loaded N waypoints from <経路名>.json` と表示されること。
  ],
) <err-wp-json>

#errorcard(
  [「Waypoint timeout (...s) exceeded. Skipping waypoint ...」],
  id: "E-520",
  level: "info",
  symptom: [
    ある地点にたどり着けないまま、次の地点へ進んでしまう。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[WARN] [nav2_waypoint_manager_executor]: Waypoint timeout (60.0s) exceeded. \
Skipping waypoint 7.
```]
  ],
  cause: [
    決められた時間内にその地点へ到達できなかったため、
    #tsuyo[意図的に飛ばして先へ進んでいます]。
    障害物で進めない、経路が通れない場所を通っている、
    あるいは自己位置がずれているときに起こります。
  ],
  fix: [
    + まず#tsuyo[現場を目視]し、その地点の前に障害物が無いか確認します。
    + 障害物が無いのに止まる場合は、
      2D 地図でその地点が黒く潰れていないか確認します（@err-pgm-dark）。
    + 自己位置がずれている場合は @err-tf-timeout を参照してください。
    + 飛ばされた地点が重要な場合は、
      経路を引き直すか、その手前に地点を追加して緩やかに進入させてください
      （@subsec-waypoint-tips）。
  ],
  verify: [
    すべての地点で `Reached waypoint N.` と表示されること。
  ],
) <err-wp-timeout>

#errorcard(
  [「Could not transform "base\_link" to "map": ... Shutting down node for retry.」],
  id: "E-521",
  level: "warn",
  symptom: [
    走行の途中で急に停止し、やり直しが始まる。
  ],
  shown: [
    #console(title: "自律走行の端末")[```
[ERROR] [nav2_waypoint_manager_executor]: Could not transform "base_link" to "map": \
Lookup would require extrapolation into the future. Shutting down node for retry.
```]
  ],
  cause: [
    走行中に自己位置推定が一時的に途切れました。
    特徴の少ない場所（広い駐車場、長い廊下、白い壁の前）を走ったときや、
    パソコンの処理が追いつかず更新が遅れたときに起こります。
  ],
  fix: [
    + `Lidar Odom Rate` の表示を確認します。
      赤や `N/A` になっていれば処理が追いついていません（@err-lio-slow）。
    + 走行速度を下げてください。
      経路の該当区間に `slow` 属性を設定すると自動で減速します（@subsec-nav-attr）。
    + 特徴の少ない区間が長い場合は、
      `gnss` モードでの走行（@subsec-nav-mode）を検討してください。
    + パソコンの負荷を下げます。
      不要なアプリケーション、特にブラウザの余分なタブを閉じてください。
  ],
  verify: [
    走行が最後まで中断せずに進むこと。
  ],
) <err-tf-lost>

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
source /opt/ros/$ROS_DISTRO/setup.bash
source ~/colcon_ws/install/setup.bash
```]
    + #dist-jazzy では `pip3 install` に
      `--user --break-system-packages` が必要です（@err-pep668）。
    + 表示されたモジュール名が上記に無い場合は、
      そのモジュール名を `pip3 install` に指定して導入してください。
  ],
  verify: [
    `Flask Server starting at http://0.0.0.0:5050` と表示されること。
  ],
) <err-server-py>

#errorcard(
  [「ros2: command not found」],
  id: "E-605",
  level: "warn",
  symptom: [
    端末で `ros2` から始まるコマンドを実行すると、見つからないと言われる。
  ],
  shown: [
    #console(title: "端末")[```
ros2: command not found
```]
  ],
  cause: [
    ROS 2 の環境が読み込まれていません。
    `source` は#tsuyo[端末ごと]に必要で、新しい端末を開くたびに実行されます。
    通常は `~/.bashrc` に書いておくことで自動化します。
  ],
  fix: [
    + その場で読み込みます。`humble` の部分は構成に合わせてください。

      #humble[
        #terminal[```bash
source /opt/ros/humble/setup.bash
source ~/colcon_ws/install/setup.bash
```]
      ]
      #jazzy[
        #terminal[```bash
source /opt/ros/jazzy/setup.bash
source ~/colcon_ws/install/setup.bash
```]
      ]
    + 毎回自動で読み込まれるようにします。

      #terminal[```bash
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
echo "source $HOME/colcon_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```]
    + そもそも ROS 2 が入っていない可能性もあります。次で確認します。
      何も表示されなければ未導入です（@subsec-setup-ros2）。

      #terminal[```bash
ls /opt/ros/
```]
  ],
  verify: [
    `ros2 --help` が使い方を表示すること。
  ],
) <err-ros-notfound>

#errorcard(
  [「error: externally-managed-environment」],
  id: "E-606",
  level: "warn",
  symptom: [
    `pip3 install` を実行すると、この英文が出て何も導入されない。
  ],
  shown: [
    #console(title: "端末")[```
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install ...
```]
  ],
  cause: [
    #dist-jazzy Ubuntu 24.04（Python 3.12）では、
    システムの Python を壊さないように
    #tsuyo[そのままの `pip3 install` が禁止されています]（PEP 668）。
  ],
  fix: [
    + `--user --break-system-packages` を付けて、
      ユーザ自身の領域（#path[~/.local]）へ導入します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2
pip3 install --user --break-system-packages -r requirements.txt
```]
    + 導入先へ PATH を通します。

      #terminal[```bash
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```]
  ],
  verify: [
    #terminal[```bash
python3 -c "import open3d, scipy, numpy, pyproj, transforms3d; print('OK')"
```]
    `OK` と表示されること。
  ],
) <err-pep668>

#errorcard(
  [シリアルポートを開けない（Permission denied）],
  id: "E-607",
  level: "warn",
  symptom: [
    モータドライバを起動すると、`/dev/ttyUSB0` を開けないと表示されて終了する。
  ],
  shown: [
    #console(title: "モータドライバの端末")[```
could not open /dev/ttyUSB0: Permission denied
```]
  ],
  cause: [
    シリアルポートを使う権限がユーザに与えられていません。
    Ubuntu では `dialout` というグループに所属している必要があります。
  ],
  fix: [
    + 自分をグループに追加します。

      #terminal[```bash
sudo usermod -aG dialout $USER
```]
    + #tsuyo[いったんログアウトして、ログインし直してください。]
      再ログインしないと反映されません。
    + 反映されたか確認します。`dialout` が含まれていれば成功です。

      #terminal[```bash
groups
```]
    + ケーブルの挿し直しでポート名が変わることがあります。
      実際の名前を確認してください。

      #terminal[```bash
ls /dev/ttyUSB* /dev/ttyACM*
```]
  ],
  verify: [
    モータドライバの端末がエラーなく開いたままになること。
  ],
) <err-serial-perm>

#errorcard(
  [Humble と Jazzy が混ざってしまった],
  id: "E-608",
  level: "danger",
  symptom: [
    ビルドは通るのに実行時に落ちる、
    ライブラリのバージョンが違うという英文が出る、
    ノードが起動直後に終了する、といった症状が同時に起こる。
  ],
  shown: [
    #console(title: "端末")[```
symbol lookup error: ... undefined symbol: ...
error while loading shared libraries: lib....so: cannot open shared object file
```]
  ],
  cause: [
    1 台のパソコンに 2 つの ROS 2 が入っており、
    #tsuyo[`~/.bashrc` で両方が読み込まれています]。
    先に読み込んだほうと後から読み込んだほうのライブラリが混ざります。
  ],
  fix: [
    + いま何が読み込まれているか確認します。

      #terminal[```bash
grep "setup.bash" ~/.bashrc
```]

      #console(title: "混在している例（誤り）")[```
source /opt/ros/humble/setup.bash
source /opt/ros/jazzy/setup.bash
source /home/hokuyo/colcon_ws/install/setup.bash
```]
    + 使わないほうの行を削除します。

      #terminal[```bash
nano ~/.bashrc
```]

      #tsuyo[残すのは 1 つの ROS 2 だけ]です。
      ワークスペースの `install/setup.bash` は最後に置きます。
    + ワークスペースを作り直します。
      #tsuyo[この操作でビルド結果は消えますが、
      地図・経路・rosbag は消えません。]

      #terminal[```bash
cd ~/colcon_ws
rm -rf build install log
source ~/.bashrc
colcon build
```]
    + `hokuyo_slam_ros2` も作り直します（@subsec-setup-slam）。
  ],
  verify: [
    #terminal[```bash
echo $ROS_DISTRO
```]
    意図した 1 つだけが表示され、`ros2 pkg list` が正常に動くこと。
  ],
) <err-distro-mix>

#errorcard(
  [GUI のボタンを押しても何も起きない（補助ツールの不足）],
  id: "E-609",
  level: "warn",
  symptom: [
    #btn[データ取得] や #btn[マッピング] を押すと画面は切り替わるのに、
    端末が 1 つも開かず、処理も始まらない。
  ],
  shown: [
    #console(title: "GUI サーバの端末")[```
Subprocess failed: Command not found or script path error: [...]
/bin/bash: line 1: gnome-terminal: command not found
xdotool: command not found
```]
  ],
  cause: [
    処理は#tsuyo[新しい端末ウィンドウを開いて]実行されます。
    その端末を開く `gnome-terminal` や、
    ウィンドウを最小化する `xdotool` / `wmctrl` が入っていません。
    最小構成の Ubuntu やサーバ版でよく起こります。
  ],
  fix: [
    + 不足しているツールを導入します。

      #terminal[```bash
sudo apt-get install -y gnome-terminal xdotool wmctrl zenity bc tree
```]
    + GUI サーバを再起動します。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/scripts
./stop_server.sh && sleep 3 && ./start_server.sh
```]
    + リモート接続（SSH）でサーバだけを動かしている場合、
      #tsuyo[画面がないため端末を開けません]。
      ロボット側のパソコンの画面で `start_server.sh` を実行してください。
  ],
  verify: [
    ボタンを押すと新しい端末ウィンドウが開くこと。
  ],
) <err-noterm>

#errorcard(
  [「Permission denied」でスクリプトが実行できない],
  id: "E-610",
  level: "warn",
  symptom: [
    `./start_server.sh` などを実行すると、許可がないと表示される。
    GUI のボタンを押しても処理が始まらない。
  ],
  shown: [
    #console(title: "端末")[```
bash: ./start_server.sh: Permission denied
```]
  ],
  cause: [
    スクリプトに実行権限が付いていません。
    ソースコードを ZIP で受け取った場合や、
    Windows 側のフォルダにコピーした場合に起こります。
  ],
  fix: [
    + まとめて実行権限を付けます。

      #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
chmod +x scripts/*.sh scripts/*/*.sh scripts/mapping/*.bash src/*.py
```]
    + 付いたか確認します。先頭が `-rwx` で始まっていれば成功です。

      #terminal[```bash
ls -l scripts/start_server.sh
```]
  ],
  verify: [
    `./start_server.sh` が実行できること。
  ],
) <err-noexec>

== 端末メッセージ逆引き表 <subsec-msg-index>

マッピングおよび 2D 地図変換の実行中に端末へ表示されるメッセージから、
該当するエラー番号を引くための一覧です。
#tsuyo[表示された文言の一部で探してください]（可変部分は `...` としています）。

#note[
  この表は上から#tsuyo[処理の順番]に並んでいます。
  複数のメッセージが出ている場合は、#tsuyo[いちばん上（最初）に出たもの]が
  本当の原因であることがほとんどです。
]

=== サーバ・Vizanti の起動時

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示*], [*参照*],
    [`ImportError: cannot import name 'get_parameter_value' from 'ros2param.api'`],
    [@err-vizanti-rosapi],
    [`[ERROR] [rosapi_node-2]: process has died ...`], [@err-vizanti-rosapi],
    [`Proxy: Error: Could not connect to ROSBridge at ws://localhost:9090.`],
    [@err-vizanti],
    [`WebSocketClosedError: Tried to write to a closed websocket`],
    [対処不要（正常な警告）],
    [`Recording started.` と出るが rosbag ができない], [@err-bag-notopic],
  ),
  caption: [サーバ・Vizanti 起動時のメッセージ],
) <tab-msg-server>

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
    [`Error: 引数が不足しています <...>`], [@err-missing-arg],
    [`ERROR: 変換スクリプトが見つかりません: ...`], [@err-script-missing],
    [`Segmentation fault (core dumped)`], [@err-runp2o-segv],
    [`terminate called ... std::invalid_argument` / `what(): stoi`], [@err-centerutm-broken],
    [`Topic '...' not found in bag file.`], [@err-topic-pc],
    [`Error (ROS 2): Topic '...' not found in '...'`], [@err-topic-gnss],
    [`cat: gnss_log/...csv: No such file or directory`], [@err-topic-gnss],
    [`can't open file: data/<地図名>/center_utm.txt`], [@err-topic-lio],
    [`FileNotFoundError: ... lio_edge_timestamps.txt`], [@err-topic-lio],
    [`エラー：p2o ファイルの行数が不足しています。`], [@err-topic-lio],
    [`エラー：入力ファイルの形式が不正です。原点の行が見つかりません。`], [@err-topic-pc],
    [`No point clouds were saved due to filtering or empty data.`], [@err-frame-mismatch],
    [`[pcl::PCDWriter::writeASCII] Input point cloud has no data!`], [@err-lioraw-silent],
    [`エラー: ... に数値として読めない値が指定されました: '...'`], [@err-savedist-nan],
    [`エラー: ... には 0 以上の数値を指定してください: '...'`], [@err-savedist-nan],
    [`エラー: 結合された点群が空です。地図は作成できません。`], [@err-concat-broken],
    [`結合した点群: 0 枚 / N 枚中`], [@err-concat-broken],
    [`ros2: command not found`], [@err-ros-notfound],
    [`bash: ./xxx.sh: Permission denied`], [@err-noexec],
    [`gnome-terminal: command not found`], [@err-noterm],
    [`error: externally-managed-environment`], [@err-pep668],
  ),
  caption: [全モード共通のメッセージ],
) <tab-msg-common>

=== 自律走行の段階

#figure(
  stable(
    columns: (1fr, auto),
    [*端末の表示・症状*], [*参照*],
    [`エラー: オプションファイルが見つかりません: ...`], [@err-opt-missing],
    [`エラー: マップリストファイルが見つかりません: ...`], [@err-scenario-missing],
    [`警告: 不明なナビゲーションタイプです: '...'`], [@err-navtype],
    [`警告: ... init_pose.txt が見つかりません。`], [@err-init-pose],
    [`エラー: map_server の起動確認がタイムアウトしました。`], [@err-mapserver-timeout],
    [`エラー: map_server の起動に失敗しました。再試行します...`], [@err-mapserver-timeout],
    [`エラー: Nav2の起動確認がタイムアウトしました。現在の状態: ...`], [@err-nav2-timeout],
    [`エラー: Nav2の起動に失敗しました。再試行します...`], [@err-nav2-timeout],
    [`InvalidParameterTypeException` / `parameter '...' has invalid type`], [@err-nav2-timeout],
    [`process has died [pid ..., exit code -6, ...]`], [@err-nav2-timeout],
    [`parameter map_file not specified`], [@err-locmap-param],
    [`Timeout waiting for TF from map to base_link ...`], [@err-tf-timeout],
    [`Timeout: Odometry switch type did not become stable ...`], [@err-switch-timeout],
    [`Nav2 action server not available after waiting!`], [@err-goal-rejected],
    [`Goal was rejected by action server`], [@err-goal-rejected],
    [`Failed to decode JSON in ...`], [@err-wp-json],
    [`Invalid JSON format in ...`], [@err-wp-json],
    [`Waypoint timeout (...s) exceeded. Skipping waypoint ...`], [@err-wp-timeout],
    [`Could not transform "base_link" to "map": ...`], [@err-tf-lost],
    [`エラー: waypoint_managerが異常終了しました。15秒後に再試行します...`], [@err-wp-manager],
    [`=== CSVファイルの最後まで処理しました。ループを再開します。 ===`], [@err-nav-loop],
  ),
  caption: [自律走行で表示されるメッセージ],
) <tab-msg-nav>

=== GUI（ブラウザ）の帯

#figure(
  stable(
    columns: (1fr, auto),
    [*ブラウザ上部の表示*], [*参照*],
    [`セキュリティ上の理由により、このディレクトリにはアクセスできません。`], [@err-path-denied],
    [`ディレクトリが見つかりません: ...`], [@err-dir-notfound],
    [`ファイルまたはディレクトリが選択されていません。`], [@err-noselect],
    [`削除するアイテムが選択されていません。`], [@err-noselect],
    [`PCDファイルが選択されていません。`], [@err-noselect],
    [`ファイル "..." は既に存在します。`], [@err-file-exists],
    [`拡張子の変更はできません。ファイル名のみ変更してください。`], [@err-ext-change],
    [`不正なファイルパスです。`], [@err-path-invalid],
    [`許可されていないパスへのアクセスが試行されました。`], [@err-path-invalid],
    [`無効なディレクトリタイプです。`], [@err-dirtype],
    [`警告: YAMLファイル "..." の読み込みに失敗しました。`], [@err-yaml-load],
    [`警告: Waypointファイル "..." の読み込みに失敗しました。`], [@err-wp-load],
    [`ダウンロード用のファイルが見つかりません。`], [@err-download],
    [`ファイルのZIP化中にエラーが発生しました: ...`], [@err-download],
    [`ROS Bagフィルタのコア機能がインポートされていません。`], [@err-bagfilter-import],
    [`選択されたファイル形式はROS Bagとしてサポートされていません。`], [@err-bag-format],
    [`トピックフィルタリングにはトピックを一つ以上選択してください。`], [@err-bag-input],
    [`出力ファイル名を入力してください。` / `出力マップ名を入力してください。`], [@err-bag-input],
    [`入力ファイルが見つかりません。パスを確認してください。`], [@err-bag-inputmissing],
    [`リクエストJSONのパースエラー: ...`], [@err-json-parse],
    [`処理中にエラーが発生しました: ...`], [@err-json-parse],
    [`Internal Server Error`（白い画面）], [@err-pcd2pgm-500],
  ),
  caption: [ブラウザに表示されるメッセージ],
) <tab-msg-gui>

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
