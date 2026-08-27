#import "utils.typ": *

= 画面キャプチャ撮影依頼リスト <sec-appendix-capture>

本書は、既存のマニュアルおよび各リポジトリに収録されていた実画面を使用して構成しています。
本付録は、#tsuyo[実機でしか撮影できない画面]のうち、
追加で撮影いただくと本書の分かりやすさが大きく向上する箇所の一覧です。

#note[
  この付録は#tsuyo[制作用の作業リスト]です。
  撮影と差し替えが完了したら、本付録ごと削除してください。
]

== 撮影と差し替えの手順 <subsec-capture-howto>

#fstep(1, [撮影する], [
  下表の「撮影内容」に従って画面を撮影します。
  #tsuyo[画面全体ではなく、必要な部分が読める大きさ]で撮影してください。
  端末の文字が判読できることが最優先です。
])
#fstep(2, [ファイルを置く], [
  撮影した画像を #path[img/] フォルダに、下表の「ファイル名」で保存します。
  形式は PNG を推奨します。
])
#fstep(3, [本文に差し込む], [
  該当する章の `capture-todo(...)` の行を、次の形に置き換えます。

  #terminal[```typst
#figure(
  image("img/<ファイル名>", width: 85%),
  caption: [<キャプション>],
) <ラベル>
```]
])

== 撮影依頼一覧 <subsec-capture-list>

=== 最優先（トラブルシューティングの精度に直結）

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ID*], [*ファイル名*], [*撮影内容と条件*],

    [C-01], [`rviz_status_green.png`],
    [RViz2 画面左上のオーバーレイ文字を拡大したもの。
     #tsuyo[GNSS 精度が「良好」（緑）、Lidar Odom Rate が緑]の状態。
     正常時の見本として使用します（@subsec-nav-monitor）],

    [C-02], [`rviz_status_red.png`],
    [同上で、#tsuyo[GNSS 精度が「低い」（赤）]、
     または Lidar Odom Rate が赤・N/A の状態。
     異常時の見本として使用します（@err-no-gnss、@err-lio-slow）],

    [C-03], [`tf_tree_ok.png`],
    [`rqt_tf_tree` の実行結果。#tsuyo[`loc` モードで正常走行中]のもの。
     `map` → `odom` → `base_link` がつながっていることが読める大きさで。
     #text(fill: rgb("#1F8A4C"))[※ 既存画像を掲載済み。より新しい構成のものがあれば差し替え]],

    [C-04], [`tf_tree_ng.png`],
    [同上で、#tsuyo[自己位置推定に失敗している状態]。
     `map` が切り離されていることが分かるもの（@err-tf-broken）。
     #text(fill: rgb("#1F8A4C"))[※ 既存画像を掲載済み。より新しい構成のものがあれば差し替え]],

    [C-05], [`err_flash_message.png`],
    [ブラウザ上部に赤い帯でエラーが表示されている画面。
     利用者が「これがエラー表示です」と認識できる見本として使用します],
  ),
  caption: [撮影依頼（最優先）],
) <tab-capture-p1>

=== 優先（自律走行章の理解に直結）

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ID*], [*ファイル名*], [*撮影内容と条件*],

    [C-06], [`nav_terminal_start.png`],
    [自律走行の開始直後の端末。
     `--- 実行パラメータ ---` から
     `ウェイポイント追従を開始します:` までが写っていること（@subsec-nav-single）],

    [C-07], [`nav_terminal_retry.png`],
    [`エラー: waypoint_managerが異常終了しました。15秒後に再試行します...`
     と再起動待機のカウントダウンが写っている端末（E-508）],

    [C-08], [`nav_rviz_running.png`],
    [自律走行中の RViz2 全景。
     2D 地図・経路・ロボット位置・計画経路が一度に写っていること。
     #text(fill: rgb("#1F8A4C"))[※ 既存画像を掲載済み。現場での実走行時のものがあれば差し替え]],

    [C-09], [`multi_map_terminal.png`],
    [マルチマップ走行で地図が切り替わる場面の端末。
     `次のマップまであと N 秒...` のカウントダウンが写っていること],

    [C-10], [`nav_stop_screen.png`],
    [#btn[ロボット停止] を押した直後のブラウザ画面
     （「自律走行プログラムを終了します...」の表示）],
  ),
  caption: [撮影依頼（優先）],
) <tab-capture-p2>

=== できれば（品質向上）

#figure(
  stable(
    columns: (auto, auto, 1fr),
    [*ID*], [*ファイル名*], [*撮影内容と条件*],

    [C-11], [`pgm_good.png`],
    [適切に変換できた 2D 地図。壁と柱だけが写っているもの],

    [C-12], [`pgm_too_dark.png`],
    [地面や天井まで写り込んで真っ黒になった 2D 地図（E-403）],

    [C-13], [`pgm_too_light.png`],
    [障害物が消えて真っ白になった 2D 地図（E-404）],

    [C-14], [`mapping_config_echo.png`],
    [マッピング開始時に端末へ表示される設定値の一覧
     （`gnss_topic: ...` 以下）。設定確認の見本として使用します（@err-csv-order）],

    [C-15], [`gnss_log_csv.png`],
    [`gnss_log/` に出力された CSV を開いた画面。
     fix 率の確認方法の説明に使用します（@err-fix-rate）],

    [C-16], [`file_management.png`],
    [ファイル管理画面で `map/` の中身を表示したもの。
     `.pcd` `.pgm` `.yaml` が同じ名前で並んでいる状態（@err-map-name）。
     #text(fill: rgb("#1F8A4C"))[※ 既存画像を掲載済み。差し替え任意]],
  ),
  caption: [撮影依頼（できれば）],
) <tab-capture-p3>

== 本文への配置状況 <subsec-capture-placed>

現時点で、本文中にプレースホルダを配置済みの箇所は次のとおりです。
撮影後は、この一覧の箇所を `image()` に置き換えてください。

#figure(
  stable(
    columns: (auto, 1fr),
    [*ID*], [*配置箇所*],
    [C-01, C-02], [@subsec-nav-monitor（自律走行中の状態確認）],
    [C-05], [@subsec-gui-trouble（GUI でよくある症状）],
    [C-06, C-07], [@subsubsec-nav-inside（開始後に内部で起きていること）],
    [C-09], [@subsubsec-nav-multi-flow（マルチマップ走行の進み方）],
    [C-10], [@subsec-nav-stop（停止のしかた）],
    [C-11, C-12, C-13], [@subsec-2dmap-tips（2D 地図の調整のこつ）],
    [C-14], [@subsec-config-verify（編集後の確認）],
    [C-15], [@subsec-mapping-gnsslog（GNSS の品質を確認する）],
  ),
  caption: [プレースホルダの配置箇所],
) <tab-capture-placed>

C-03、C-04、C-08、C-16 については、既存の画像を本文に掲載済みです。
より新しいもの・現場で撮影したものが用意できれば差し替えてください。

== プレースホルダの表示例 <subsec-capture-placeholder>

本文中で撮影待ちの箇所は、次のような枠で示されます。

#capture-todo(
  "C-01",
  [RViz2 のオーバーレイ文字（正常時・緑）],
)

#pagebreak()
