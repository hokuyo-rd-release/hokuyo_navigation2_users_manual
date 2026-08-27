#import "utils.typ": *

= 2D地図への変換 <sec-2d-map>

静的障害物の有無の情報のために2D地図を作成します。
3D地図の`z`方向に範囲を設けてその間の点群を全て集めて平面化します。
この際、2D地図におけるロボットの通行可能領域は waypoint によって決定されます。
3D地図を2D地図に変換する際、waypoint の位置と姿勢を使って、waypoint上の静的障害物を除去することができます。
waypoint 上の静的障害物を除去するためには、waypoint の位置を中心とした waypoint 上の静的障害物の除去半径をパラメータとして設定します。
waypoint に対して通行可能領域の設定範囲、`z`方向の下限と上限、通行可能領域はパラメータとしています。このパラメータは、@sec-config のコンフィグファイルでパラメータを設定可能です。注意として3D地図に対応する2D地図の、拡張子以外は同じファイル名にしてください。

== 2D地図への変換方法
+ メイン画面の「マッピング」をクリックし、@sub35 の「pcd2pgm」ボタンをクリックします。
+ @sub36 で @sec-mapping で作成した3D点群地図のPCDファイルを選択して「選択して次へ」をクリックします。
+ @sub37 で @sec-mapping で作成した waypoint の選択画面が表示されます。
  waypoint を選択して「選択して実行」をクリックすると、選択した waypoint 上の静的障害物を2D地図から除去します。
  選択せずに、「スキップ (なしで続行)」を選択すると、waypoint上の静的障害物の除去は行われません。しかし、地図作成コンフィグで使用されるパラメータの内
  `thre_z_min`, `thre_z_max`, `thres_point_count`, `thre_radius` を調整することで、3D点群の高さ方向で切り出す範囲と、ノイズを除去する半径を調整することができます。
  これらは、使用する環境の状況に応じて使い分けてご使用下さい。
+ @sub38 に示すように、waypoint 選択した場合、ウェイポイントをループとして扱うかにチェックを入れると、地図が周回している場合最初と最後のwaypointを繋げて、障害物の除去を行います。
  地図が周回しない場合は、チェックを外してください。
+ @sub39 の「3Dビューアで確認」ボタンをクリックすると、3D Viewer が表示され、
  前述の手順でPGMファイルを指定すると @sub40 に示すように2D地図が表示されます。この際、静的障害物の占有格子は赤色、通行可能領域の占有格子は緑色としています。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [#figure(image("img/25.png", width: 80%), caption: [マッピングモードクリック後の画面]) <sub35>],
    // 個別に幅を80%に縮小し、中央に寄せる例
    [#figure(image("img/42.png", width: 80%), caption: [3D点群地図の選択画面]) <sub36>],
    [#figure(image("img/43.png", width: 80%), caption: [waypoint の選択画面]) <sub37>],
    [#figure(image("img/44.png", width: 80%), caption: [2D地図への変換前の画面]) <sub38>],
    [#figure(image("img/45.png", width: 80%), caption: [2D地図への変換後の画面]) <sub39>],
    [#figure(image("img/46.png", width: 80%), caption: [2D地図の3D Viewer画面]) <sub40>],
  ),
  caption: [2D地図への変換画面],
) <im24>

== 平面化の調整
+ 天井が2D地図に投影されてしまう場合、`z`方向の上限を下げることで、天井を除去できます。
+ 地面が2D地図に投影されてしまう場合、`z`方向の下限を上げることで、地面を除去できます。

== 通行経路の再設定
+ 2D地図の通行可能領域は、平面化の再実行時にwaypointを使って上書きされます。
+ 3D点群地図と2Dの地図を重ねて表示させて通行経路を再設定し、再度2D地図への変換を行うと、再設定した経路に対して通行可能領域が設定されます。

== 調整のこつ <subsec-2dmap-tips>

#tip[
  2D 地図への変換は#tsuyo[数十秒で終わり、何度でもやり直せます]。
  一度で決めようとせず、変換 → 3D Viewer で確認 → パラメータ調整 → 再変換、
  を繰り返すのが確実です。3D 地図を作り直す必要はありません。
]

変換した 2D 地図は、3D Viewer で表示して @im-2dmap-compare のように見比べます。
中央のように壁と柱だけが写っている状態が理想です。

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 6pt,
    capture-todo("C-12", [悪い例：真っ黒 \ 地面や天井が写り込んだ状態], height: 40mm),
    capture-todo("C-11", [良い例 \ 壁と柱だけが写った状態], height: 40mm),
    capture-todo("C-13", [悪い例：真っ白 \ 障害物が消えた状態], height: 40mm),
  ),
  caption: [2D 地図の良い例と悪い例（撮影待ち）],
) <im-2dmap-compare>

#text(size: 8.5pt)[
  ※ 上記3枚は実機データでの撮影待ちです。撮影依頼の詳細は @tab-capture-p3 を参照してください。
]

@tab-2dmap-tuning に、症状ごとの調整方法をまとめます。
パラメータは「ファイル管理」→「設定ファイル管理」から編集します。

#figure(
  stable(
    columns: (1fr, auto, auto),
    [*3D Viewer で見たときの症状*], [*変える項目*], [*方向*],
    [地面が写り込んで全面が赤い], [`thre_z_min`], [上げる],
    [天井が写り込んで全面が赤い], [`thre_z_max`], [下げる],
    [細い柱やポールが消えている], [`thres_point_count`], [下げる],
    [空中に浮いたノイズが残る], [`thre_radius`], [上げる],
    [経路上に障害物が残って通れない], [`waypoint_tolerance`], [上げる],
    [地図が粗くて壁の形が分からない], [`map_resolution`], [下げる],
  ),
  caption: [2D 地図の調整表],
) <tab-2dmap-tuning>

#warn[
  変換後は、地図名が 3D 地図と一致しているか必ず確認してください。
  `<地図名>.pcd`、`<地図名>.pgm`、`<地図名>.yaml` の
  #tsuyo[拡張子を除く部分が同じ]でないと、自律走行で使えません（@err-map-name）。\
  また、2D 地図（`.yaml`）を作っていない地図は、
  自律走行の `MAPFILE` の一覧に表示されません（@err-nav-no-map）。
]

== うまくいかないときは <subsec-2dmap-trouble>

#figure(
  stable(
    columns: (1fr, auto),
    [*症状*], [*参照先*],
    [「入力PCDファイルが見つかりません」と出る], [@err-pcd-notfound],
    [「'open3d' and 'scipy' are required」と出る], [@err-pgm-module],
    [「Loaded point cloud is empty」と出る], [@err-pgm-empty-pcd],
    [経路に沿った通行可能領域（緑）ができない], [@err-wp-notfound],
    [経路ファイルの読み込みに失敗する], [@err-pgm-wp-broken],
    [「Filtered point cloud is empty」と出て地図ができない], [@err-pgm-filter-empty],
    [2D 地図が真っ黒になる], [@err-pgm-dark],
    [2D 地図が真っ白になる], [@err-pgm-light],
    [「An unexpected error occurred」と出る], [@err-pgm-unexpected],
    [変換したのに `MAPFILE` の一覧に出てこない], [@err-map-notlisted],
  ),
  caption: [2D 地図変換でよくある症状],
) <tab-2dmap-trouble>

#pagebreak()