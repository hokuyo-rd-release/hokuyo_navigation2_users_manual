#import "utils.typ": *

= ファイル管理とデータ変換ツール <sec-files>

本章では、作成した地図・経路・設定ファイルを整理する方法と、
rosbag を扱う補助ツールの使い方を説明します。

#plain[
  この章は#tsuyo[現場作業の合間の「片づけ」]の章です。
  地図や経路が増えてくると、どれが最新か分からなくなります。
  名前の付け方と控えの取り方を決めておくと、現場で迷わずに済みます。
]

== ファイル管理画面を開く <subsec-files-open>

メイン画面の #btn[ファイル管理] を押すと、@im-files-popup の選択画面が出ます。
管理したいファイルの種類を選んでください。それぞれ別のタブで開きます。

#figure(
  image("img/g_popup_filemgmt.png", width: 62%),
  caption: [ファイル管理の種類を選ぶ画面],
) <im-files-popup>

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ボタン*], [*対象フォルダ*], [*入っているもの*],
    [#btn[マップ管理]], [#path[map/]],
    [3D 点群地図（`.pcd`）、2D 地図（`.pgm`、`.yaml`）],
    [#btn[ウェイポイント管理]], [#path[waypoints/]],
    [経路ファイル（`.json`）],
    [#btn[設定ファイル管理]], [#path[config/]],
    [地図作成コンフィグとシナリオファイル（`.csv`）],
  ),
  caption: [ファイル管理の 3 つの入口],
) <tab-files-kinds>

#warn[
  #btn[ファイル管理] は#tsuyo[停止モードのときだけ]押せます。
  灰色で押せない場合は、先に #btn[ロボット停止] を押してください（@err-btn-disabled）。
]

== 地図ファイルの管理 <subsec-files-map>

#btn[マップ管理] を開くと、@im-files-map のように #path[map/] の中身が一覧されます。

#figure(
  image("img/g_files_map.png", width: 88%),
  caption: [マップファイル管理の画面],
) <im-files-map>

=== 1 つの地図を構成する 4 つのファイル

1 つの地図は、@tab-files-set の 4 つのファイルの組で成り立っています。
#tsuyo[拡張子を除いた名前は、必ずすべて同じ]にしてください。

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ファイル*], [*場所*], [*役割*],
    [`<名前>.pcd`], [#path[map/]], [3D 点群地図。`loc` モードの自己位置推定に使う],
    [`<名前>.pgm`], [#path[map/]], [2D 地図の画像。Nav2 の経路計画に使う],
    [`<名前>.yaml`], [#path[map/]], [2D 地図の縮尺と原点の情報],
    [`<名前>.json`], [#path[waypoints/]], [経路（ウェイポイント）],
  ),
  caption: [1 つの地図を構成するファイル],
) <tab-files-set>

#danger[
  名前が 1 つでも食い違うと、自律走行の開始時に地図が読み込めず失敗します。
  症状と直し方は @err-map-name と @err-mapserver-timeout を参照してください。
]

#note[
  上記のほかに #path[data/\<名前\>/] というフォルダも自動で作られ、
  地図を作ったときの初期位置（`init_pose.txt`、`init_lat_lon_alt.txt`）が入っています。
  #tsuyo[このフォルダは GUI からは見えません。]
  別のパソコンへ地図を移すときは、忘れずに一緒にコピーしてください（@err-init-pose）。
]

=== 名前を変える

一覧の#tsuyo[ファイル名の文字をダブルクリック]すると、その場で書き換えられます。
入力後に別の場所をクリックすると確定します。

#fstep(1, [`.pcd`、`.pgm`、`.yaml` を順に同じ名前へ変更する], [
  1 つだけ変えた時点では地図として壊れた状態になります。
  #tsuyo[必ず 4 つすべてを変えきってください。]
])
#fstep(2, [ウェイポイント管理のタブで `.json` も同じ名前に変更する], [
  経路ファイルは別のフォルダにあるため、別タブでの操作になります。
])
#fstep(3, [端末で #path[data/] のフォルダ名も変更する], [
  #terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/data
mv <古い名前> <新しい名前>
```]
])

#warn[
  拡張子（ピリオドより後ろ）は変更できません（@err-ext-change）。
  また、すでに同じ名前がある場合は拒否されます（@err-file-exists）。
]

#tip[
  名前には#tsuyo[半角英数字、`_`、`-` だけ]を使ってください。
  空白や日本語を含めると、マッピングや自律走行の実行時に
  引数が途中で切れて失敗します（@err-missing-arg）。

  現場名と日付を組み合わせると管理しやすくなります。\
  例: `toyonaka_1f_20260401`
]

=== 削除する

行の左端のチェックボックスを入れて #btn[削除] を押します。

#danger[
  #tsuyo[削除したファイルは元に戻せません。]
  ごみ箱には入らず、その場で消えます。
  現場で使っている地図は、削除する前に必ず控えを取ってください（@subsec-files-backup）。
]

=== ダウンロードする

地図を選んで #btn[ダウンロード] を押すと、ZIP にまとめてブラウザへ保存されます。
別のパソコンから GUI を開いている場合、これがファイルを持ち出す手段になります。
失敗する場合は @err-download を参照してください。

== 経路ファイルの管理 <subsec-files-wp>

#figure(
  image("img/g_files_wp.png", width: 88%),
  caption: [ウェイポイントファイル管理の画面],
) <im-files-wp>

操作方法はマップ管理と同じです。名前の変更、削除、ダウンロードが行えます。

#danger[
  経路ファイル（`.json`）を#tsuyo[テキスト編集で直接書き換えないでください。]
  形式が少しでも崩れると、自律走行の開始時に読み込みに失敗します（@err-wp-json）。
  編集は必ず Map Viewer（@sec-waypoint）から行ってください。
]

== 設定ファイルの管理 <subsec-files-config>

#figure(
  image("img/g_files_config.png", width: 88%),
  caption: [設定ファイル管理の画面],
) <im-files-config>

設定ファイルには 2 種類あり、#tsuyo[ボタンの並びが違うことで見分けられます]。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*種類*], [*見分け方*], [*編集ボタン*],
    [地図作成コンフィグ],
    [1 行目が `オプション,指定値,デフォルト値`],
    [#btn[テキスト編集] のみ],
    [シナリオファイル],
    [1 行目が `map_file,waypoint_file,nav_type,interval`],
    [#btn[編集] と #btn[テキスト編集]],
  ),
  caption: [2 種類の設定ファイルの見分け方],
) <tab-files-config-kinds>

#note[
  #tsuyo[#btn[編集] ボタンが出ないファイルは、シナリオファイルとして認識されていません。]
  1 行目の見出しが 1 文字でも違うと表形式の編集画面が使えず、
  自律走行の `CSVファイル` の一覧にも現れません（@err-nav-no-csv）。
]

=== テキスト編集

#btn[テキスト編集] を押すと、@im-files-plain の画面でファイルの中身をそのまま編集できます。

#figure(
  image("img/g_edit_plain.png", width: 78%),
  caption: [テキスト編集の画面（地図作成コンフィグ）],
) <im-files-plain>

#danger[
  地図作成コンフィグは、#tsuyo[上から何行目か]で値が読み取られます。
  行の追加・削除・並べ替えを行うと、以降の設定がすべてずれます（@err-csv-order）。
  #tsuyo[書き換えてよいのは、各行の 2 列目（カンマとカンマの間）だけ]です。
]

=== 表形式の編集（シナリオファイル）

シナリオファイルは #btn[編集] を押すと、@im-files-csv の表形式の画面で編集できます。
#tsuyo[書き間違いが起こらないため、こちらの使用をおすすめします。]

#figure(
  image("img/g_edit_csv.png", width: 92%),
  caption: [シナリオファイルの表形式編集画面],
) <im-files-csv>

#figure(
  stable(
    columns: (auto, 1fr),
    [*操作*], [*方法*],
    [地図・経路を選ぶ], [一覧から選択します。実在するファイルだけが並びます],
    [走行モードを選ぶ], [`loc` または `gnss` を選択します（@subsec-nav-mode）],
    [切り替え間隔], [数値［秒］を入力します],
    [行を入れ替える], [左端の「≡」を上下にドラッグします],
    [行を追加する], [#btn[行を追加] を押します],
    [行を削除する], [その行の #btn[削除] を押します。#tsuyo[確認なしで即座に消えます]],
    [保存する], [#btn[保存] を押します。押すまで変更は反映されません],
  ),
  caption: [シナリオ編集画面の操作],
) <tab-files-csv-ops>

#warn[
  #tsuyo[#btn[保存] を押さずにタブを閉じると、編集内容は失われます。]
]

=== 新しい設定ファイルを作る

画面下部の入力欄にファイル名（`.csv`）を入力して #btn[作成] を押します。
シナリオファイルを新規に作る場合は、
#tsuyo[作成後にテキスト編集で 1 行目の見出しを入力してください。]

#terminal[```csv
map_file,waypoint_file,nav_type,interval
```]

== rosbag の補助ツール <subsec-files-bagtools>

メイン画面の #btn[マッピング] からは、地図作成のほかに
rosbag を加工する 2 つの機能が呼び出せます。

#figure(
  stable(
    columns: (auto, 1fr, auto),
    [*機能*], [*内容*], [*状態*],
    [ROS Bag フィルタ],
    [記録した rosbag から、必要なトピックだけを取り出して別の rosbag を作る],
    [使用可],
    [トピック同期（sync）],
    [複数のトピックの時刻を揃える],
    [#tsuyo[現在のバージョンでは使用不可]],
  ),
  caption: [rosbag の補助ツール],
) <tab-files-bagtools>

#warn[
  #tsuyo[トピック同期（sync）は選択しないでください。]
  この機能が呼び出すスクリプトは現在のバージョンに含まれておらず、
  端末が `No such file or directory` と表示して終了します（@err-sync-missing）。
]

=== ROS Bag フィルタを使う場面

記録した rosbag には、地図作成に使わないトピックも含まれています。
不要なトピックを取り除くと、@tab-files-filter-merit の利点があります。

#figure(
  stable(
    columns: (auto, 1fr),
    [*場面*], [*効果*],
    [ファイルが大きくて持ち出せない],
    [不要なトピックを削るとファイルが小さくなり、コピーが速くなります],
    [マッピングに時間がかかりすぎる],
    [読み込むデータが減り、処理が速くなります],
    [不要なトピックが誤って使われている],
    [必要なトピックだけを残すことで、設定の取り違えを防げます],
  ),
  caption: [ROS Bag フィルタの使いどころ],
) <tab-files-filter-merit>

=== 操作手順

#fstep(1, [rosbag を選ぶ], [
  メイン画面の #btn[マッピング] → #btn[filter] を押すと、
  @im-files-browse-filter の一覧が表示されます。
  #tsuyo[日付から始まるフォルダ名]を選び、
  左端のチェックボックスを入れてから #btn[ROS Bagとして選択] を押します。

  #figure(
    image("img/g_browse_filter.png", width: 78%),
    caption: [ROS Bag ブラウザ（フィルタ用）],
  ) <im-files-browse-filter>
])
#fstep(2, [残すトピックを選ぶ], [
  rosbag に含まれるトピックの一覧が表示されます。
  #tsuyo[残したいものにだけ]チェックを入れてください。
  地図作成に必要なトピックは @tab-bag-topics のとおりです。
])
#fstep(3, [出力名を入れて実行する], [
  #tsuyo[元の rosbag と違う名前]を入力します。
  末尾に `_filtered` を付けると分かりやすくなります。
  入力が空だと実行できません（@err-bag-input）。
])
#fstep(4, [結果を確認する], [
  #path[rosbag/] に新しいフォルダができます。
  端末で中身を確認できます。

  #terminal[```bash
ros2 bag info ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2/rosbag/<出力名>
```]

  #console(title: "確認の表示例")[```
Files:             <出力名>_0.mcap
Duration:          27.841997138s
Messages:          2554
Topic information: Topic: /fix | Type: sensor_msgs/msg/NavSatFix | Count: 28 | ...
                   Topic: /hokuyo3d/hokuyo_cloud2 | Type: sensor_msgs/msg/PointCloud2 | Count: 537 | ...
```]
])

#danger[
  #tsuyo[元の rosbag は消さずに残しておいてください。]
  トピックを削りすぎると、あとから別の方式で地図を作り直すことができなくなります。
  現場での再走行はやり直しが効きません。
]

== PCD から PGM への変換画面 <subsec-files-pcd2pgm>

2D 地図への変換（@sec-2d-map）は、この画面から実行します。
#tsuyo[必ず、変換元の PCD ファイルを選んでから]この画面を開いてください。

#fstep(1, [PCD ファイルを選ぶ], [
  #btn[マッピング] → #btn[pcd2pgm] を押すと @im-files-browse-pcd の一覧が出ます。

  #figure(
    image("img/g_browse_pcd.png", width: 78%),
    caption: [PCD ファイルの選択画面],
  ) <im-files-browse-pcd>
])
#fstep(2, [経路ファイルを選ぶ（任意）], [
  経路を指定すると、その周囲が#tsuyo[通行可能な領域]として地図に書き込まれます。
  指定しない場合は、点群だけから地図が作られます。

  #figure(
    image("img/g_browse_wp.png", width: 78%),
    caption: [ウェイポイントファイルの選択画面],
  ) <im-files-browse-wp>
])
#fstep(3, [出力名と設定ファイルを指定して実行する], [
  @im-files-pcd2pgm の画面で、出力する 2D 地図の名前を入力します。
  #tsuyo[3D 点群地図と同じ名前]にしてください。

  #figure(
    image("img/g_pcd2pgm_form.png", width: 78%),
    caption: [PCD to PGM 変換の設定画面],
  ) <im-files-pcd2pgm>
])

#warn[
  この画面を#tsuyo[直接 URL から開く]と、
  白い画面に `Internal Server Error` とだけ表示されます。
  必ずメイン画面のボタンからたどってください（@err-pcd2pgm-500）。
]

== 控え（バックアップ）の取り方 <subsec-files-backup>

#danger[
  地図と経路は#tsuyo[現場で走行しなければ作り直せません]。
  パソコンの故障や誤削除に備えて、定期的に別の場所へコピーしてください。
]

1 つの現場のデータをまとめて控える場合は、次のコマンドを実行します。
`<地図名>` と保存先は、実際のものに置き換えてください。

#terminal[```bash
cd ~/colcon_ws/src/hokuyo_navigation2/hokuyo_navigation2
NAME=<地図名>
DEST=/media/$USER/<USBメモリ名>/hokuyo_backup
mkdir -p "$DEST"
cp map/$NAME.pcd map/$NAME.pgm map/$NAME.yaml "$DEST"/
cp waypoints/$NAME.json "$DEST"/
cp -r data/$NAME "$DEST"/
```]

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*対象*], [*優先度*], [*理由*],
    [#path[map/]], [必須], [地図そのもの],
    [#path[waypoints/]], [必須], [経路そのもの],
    [#path[data/\<地図名\>/]], [必須], [初期位置。無いと走行開始位置がずれます],
    [#path[config/]], [推奨], [調整したパラメータ。作り直しの手間が省けます],
    [#path[rosbag/]], [推奨], [地図を作り直せる元データ。容量が大きい],
    [#path[gnss_log/]], [任意], [GNSS 品質の記録。原因調査に使います],
  ),
  caption: [控えを取る対象と優先度],
) <tab-files-backup>

#tip[
  控えを戻すときは、上記の逆にコピーしたあと、
  #tsuyo[必ずパッケージを作り直してください。]
  作り直さないと、GUI の一覧に地図が現れないことがあります（@err-map-notlisted）。

  #terminal[```bash
cd ~/colcon_ws
colcon build --symlink-install --packages-select hokuyo_navigation2
```]
]

== うまくいかないときは <subsec-files-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [ファイル一覧が空で「ディレクトリが見つかりません」と出る], [@err-dir-notfound],
    [ボタンを押しても「選択されていません」と出る], [@err-noselect],
    [「既に存在します」と出て作成・改名できない], [@err-file-exists],
    [「拡張子の変更はできません」と出る], [@err-ext-change],
    [「不正なファイルパスです」と出る], [@err-path-invalid],
    [2D 地図（`.yaml`）が読めないと警告が出る], [@err-yaml-load],
    [経路が Map Viewer に表示されない], [@err-wp-load],
    [ダウンロードできない], [@err-download],
    [変換画面で `Internal Server Error` が出る], [@err-pcd2pgm-500],
    [フィルタで「コア機能がインポートされていません」と出る], [@err-bagfilter-import],
    [rosbag が「サポートされていません」と出る], [@err-bag-format],
    [トピック同期が実行できない], [@err-sync-missing],
  ),
  caption: [ファイル管理でよくある症状],
) <tab-files-trouble>

#pagebreak()
