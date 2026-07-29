#set page(paper: "a0", margin: 2cm)
#set text(font: "Harano Aji Gothic", size: 30pt)

// --- デザイン設定 ---
#let theme-color = rgb("#00A1E9")

// FontAwesome を表示するためのヘルパー関数
#let fa-marker(icon, fill: theme-color, size: 1.2em) = text(font: "Font Awesome 6 Free", weight: 900, fill: fill, size: size, icon)

#let header-color = rgb("#1f6d89")
#set list(marker: text(fill: theme-color)[▶])
#let bottom-line = rgb("#FF9933")
#let rect-line = rgb("#0086B0")
#let attention-color = red
#let answer-color = rgb("#2E7D32") // 視認性の高い緑
#let section-header(title) = {
  v(1cm)
  stack(
    spacing: 30pt,
    grid(
      columns: (auto, auto),
      column-gutter: 30pt,
      align: horizon,
      rect(fill: header-color, width: 12pt, height: 60pt, radius: 2pt),
      text(weight: "bold", size: 48pt, fill: header-color, title),
    ),
    line(length: 100%, stroke: 7pt + bottom-line)
  )
}

// 汎用的な装飾ボックス
#let design-box(..args, it) = rect(
  width: 100%,
  stroke: theme-color,
  inset: 10pt,
  radius: 4pt,
  ..args,
  it
)

// ポスター用の装飾ボックス定義
#let poster-rect(top: none, columns: none, gutter: 1cm, attention: false, answer: false, square: false, round: false, ..args, it) = {
  let main-content = if columns != none {
    grid(columns: columns, gutter: gutter, ..args.pos(), it)
  } else {
    it
  }
  
  let box-stroke = if attention { attention-color } else if answer { answer-color } else { rect-line }
  let box-radius = if square { 0pt } else if round { 2cm } else { 10pt }

  let body = if top != none {
    stack(spacing: gutter, top, main-content)
  } else {
    main-content
  }
  
  design-box(stroke: 2pt + box-stroke, inset: 1cm, radius: box-radius, ..args.named(), body)
}

// チャートの各ステップ用の装飾ボックス
#let flow-step(color: rect-line, ..args, it) = rect(
  fill: color.lighten(96%),
  stroke: 1.5pt + color,
  inset: 15pt,
  radius: 8pt,
  width: auto,
  ..args,
  it
)

// --- タイトルエリア ---
#rect(width: 100%, fill: theme-color, inset: 2cm)[
  #grid(
    columns: (auto, 1fr),
    align: horizon,
    column-gutter: 2cm,
    rect(fill: luma(250), stroke: 2pt + gray, radius: 15pt, inset: 1cm)[
      #grid(
        columns: (auto, auto),
        column-gutter: 1cm,
        image("../img/hokuyo_logo.jpg", height: 10cm),
        image("../img/RSF-X001.jpg", height: 10cm),
      )
    ],
    [
      #align(right, text(size: 55pt, weight: "bold", fill: rgb("#F9EAD3"))[
        ワンパッケージ3D自己位置推定センサ「RSF」のための \
        ブラウザGUIから実行可能なROS2ベース \
        自律走行ソフトウェア「hokuyo_navigation2」
      ])
      #align(right, text(size: 40pt, weight: "bold", fill: rgb("#F9EAD3"))[髙橋 尚太郎 (北陽電機株式会社)])
    ]
  )
]

// ✅ (完了) : 緑色
#let solve(it) = {
  set list(marker: text(fill: answer-color)[✅])
  it
}

// ❌ (未完了) : 赤色
#let problem(it) = {
  set list(marker: text(fill: attention-color)[❌])
  it
}

// --- メインレイアウト ---
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  row-gutter: 1cm,
  
  // 目的と結論を上部に配置
  [
    #section-header("目的")
    #poster-rect(square: true)[
      - 屋外環境での #text(fill: theme-color)[RSFセンサ(RSF-X001)] の検証 (RTK-GNSS, 3D LiDAR, IMU, SBC 一体型新製品)
      - #text(fill: theme-color)[RSFセンサ] のユーザの導入のハードルを下げること
      #align(center,image("../img/mokuteki.png", width: 73%))
    ]
  ],
  [
    #section-header("結論")
    #poster-rect(square: true)[
      - Web GUIによる直感的な操作を実現 (非技術者による運用が可能)
      - 大阪・関西万博や中之島チャレンジで実証実験 (ATCコース1周完走)
      - hokuyo_navigation2 OSS公開 (Docker 対応)
      #align(center,
      grid(
        columns: (auto, auto),
        align: center + horizon,
        column-gutter: 2pt,
        align(center,image("../img/expo_demo.jpg", width: 91%)),
        align(center,image("../img/expo_demo2.jpg",width: 106%))
      )
    )
    ]
  ],
)

// その他のセクションを配置
#section-header("実現方法")
#poster-rect(square: true)[

- *運用方法*
#align(center,
grid(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  align: center + horizon,
  column-gutter: 25pt,
  flow-step([ブラウザベースのGUIからプログラム実行], color: attention-color), fa-marker("", fill: answer-color),
  flow-step([Webエディタでパラメータ管理], color: attention-color), fa-marker("", fill: answer-color),
  flow-step([RSFのROSBAGを使った地図作成], color: attention-color), fa-marker("", fill: answer-color),
  flow-step([Web 3D Viewer上で経路編集], color: attention-color)
))

- *Waypoint設置と2D地図修正の自動化*
#align(center,
grid(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  align: center + horizon,
  column-gutter: 25pt,
  flow-step([データ取得], color: answer-color), fa-marker("▶", fill: answer-color),
  flow-step([3D地図・経路作成], color: answer-color), fa-marker("▶", fill: answer-color),
  flow-step([2D地図作成・地図修正], color: answer-color), fa-marker("▶", fill: answer-color),
  flow-step([自律走行], color: answer-color)
))

- *自己位置推定の切り替え:*
  3D地図ベースの自己位置推定とGNSS/LIO切り替えベース(地図なし)の自己位置推定を#text(weight: "bold",fill: attention-color)[ユーザが設定]
  #align(center,
    grid(
      columns: (auto, auto),
      align: center + horizon,
      column-gutter: 2pt,
      align(center,image("../img/31.png",width: 86%)),
      align(center,image("../img/hokuyo_navigation2_fix.pdf",width: 103%)),
    )
  )
]

#section-header("システム")

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [- *3D SLAM:* p2o を使用 RTK-GNSSが使用できない場合はIMUにより補正
   - *3D地図の2D化:* waypoint を用いて地図のゴミ取り処理を自動化
  ],
  [- *経路設計:* Web 3D Viewer 上で編集　追加・削除・他に属性付与も可能
   - *Navigation:* Nav2を使用 (local planner用に2D地図を使用)]
)

#section-header("活用例")
// グラフや表をグリッドで配置
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2cm,
  [- 実験で用いたロボットのシステム構成
  #align(center, image("../img/flask_server_fix.pdf", width: 67%))],
  
  [- Web GUIの一例 (メイン画面 自律走行実行画面)
  #align(
    center,
    grid(
        columns: (auto, auto),
        align: center + horizon,
        column-gutter: 2pt,
        align(center,image("../img/gui.png", width: 70%)),
        align(center,image("../img/navigation_execute.png", width: 60%))
      )
    )]
)
  // poster-rect(attention: true)[
  // #align(center,text(weight: "bold", fill: attention-color, "新製品開発における問い"))

  // #problem[
  // - YVT-35lxの特性を生かし、不安定さを解消できるか？
  // - 専門知識のないスタッフでも運用可能なシステムは作れるのか？
  // - 実際の屋外広域環境で通用するのか？
  // - どうすれば導入障壁を下げられるか？
  // ]],
  // poster-rect(answer: true)[
  // #align(center,text(weight: "bold", fill: answer-color, "答え" ))

  // #solve[
  // - 独自アルゴリズム内包のRSFにより、チューニングレスで安定化
  // - ブラウザGUIにより、直感的かつ「手離れの良さ」を実現
  // - EXPO/中之島で有効性を証明。長距離走行への対応も確認
  // - 課題も含めた「ベータ版」としてOSS公開により開発を加速
  // ]
  // ]

// #poster-rect(
//   top: [#align(center)[*まとめ*]], 
//   columns: 2,
//   round: true
// )[
//   #poster-rect(attention: true)[
//   #align(center,text(weight: "bold", fill: attention-color, "新製品開発における問い"))

//   #problem[
//   - YVT-35lxの特性を生かし、不安定さを解消できるか？
//   - 専門知識のないスタッフでも運用可能なシステムは作れるのか？
//   - 実際の屋外広域環境で通用するのか？
//   - どうすれば導入障壁を下げられるか？
//   ]]
// ][
//   #poster-rect(answer: true)[
//   #align(center,text(weight: "bold", fill: answer-color, "答え" ))
  
//   #solve[
//   - 独自アルゴリズム内包のRSFにより、チューニングレスで安定化
//   - ブラウザGUIにより、直感的かつ「手離れの良さ」を実現
//   - EXPO/中之島で有効性を証明。長距離走行への対応も確認
//   - 課題も含めた「ベータ版」としてOSS公開により開発を加速
//   ]]
// ]

#v(1cm)

#place(bottom + left)[
  #block(width: 10cm)[
    #set align(center)
    #text(size: 24pt, weight: "bold")[GitHub]
    #image("../img/hokuyo_nav2_github.png", width: 5cm)
  ]
]

#place(bottom + right)[
  #image("../img/hokuyo_all_logo.png", width: 10cm)
]