// =============================================================
// utils.typ : hokuyo_navigation2 ユーザーマニュアル 共通スタイル定義
// =============================================================

// ---------- フォント ----------
#let mincho = (
  "Times New Roman",
  "Harano Aji Mincho",
  "Noto Serif JP"
)

#let gothic = (
  "Times New Roman",
  "Harano Aji Gothic",
  "Noto Sans JP"
)

#let mono = ("DejaVu Sans Mono", "Consolas", "Courier New")

// ---------- 配色 ----------
#let c-brand   = rgb("#00A1E9")   // 北陽電機ブルー
#let c-ink     = rgb("#1B1F23")
#let c-note    = rgb("#0B6BCB")   // 補足 (青)
#let c-tip     = rgb("#1F8A4C")   // ヒント (緑)
#let c-warn    = rgb("#B7791F")   // 注意 (橙)
#let c-danger  = rgb("#C62828")   // 警告 (赤)
#let c-term-bg = rgb("#1E1E1E")   // 端末の背景
#let c-term-fg = rgb("#E6E6E6")   // 端末の文字

#let tsuyo(it) = {
  set text(font: gothic, weight: "bold")
  it
}

// =============================================================
// 端末表示
// =============================================================

// 入力するコマンドを示すブロック (従来互換)
// breakable: false — コマンドやディレクトリ構成が改ページで分断されると
// 読み手が誤って途中までを1つのコマンドと解釈するため、まとめて配置する。
#let terminal(it) = block(
  fill: luma(240),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  breakable: false,
  stroke: 0.5pt + luma(210),
  text(font: mono, size: 9pt, it)
)

// 実際の端末画面を模したブロック。画面に「表示される」出力を示す。
// 例: #console(title: "p2o マッピング実行時の端末")[```...```]
#let console(body, title: none) = block(
  width: 100%,
  radius: 3pt,
  clip: true,
  stroke: 0.5pt + luma(120),
  breakable: false,
  {
    // タイトルバー (端末ウィンドウ風)
    block(
      width: 100%,
      fill: rgb("#3C3C3C"),
      spacing: 0pt,
      inset: (x: 8pt, y: 5pt),
      grid(
        columns: (auto, 1fr),
        align: horizon + left,
        gutter: 6pt,
        // 信号機ボタン
        box(baseline: 1pt, {
          for cl in (rgb("#FF5F56"), rgb("#FFBD2E"), rgb("#27C93F")) {
            box(circle(radius: 2.6pt, fill: cl))
            h(3pt)
          }
        }),
        text(
          font: gothic, size: 7.5pt, fill: rgb("#D0D0D0"),
          if title == none { "端末" } else { title },
        ),
      ),
    )
    block(
      width: 100%,
      fill: c-term-bg,
      spacing: 0pt,
      inset: 8pt,
      {
        show raw: set text(font: mono, size: 8pt, fill: c-term-fg)
        set text(font: mono, size: 8pt, fill: c-term-fg)
        set par(first-line-indent: 0em, justify: false, leading: 0.55em)
        body
      },
    )
  }
)

// =============================================================
// コールアウト (注記ボックス)
// =============================================================

#let _callout(body, label: "", accent: black, icon: "") = block(
  width: 100%,
  inset: (left: 9pt, right: 9pt, top: 7pt, bottom: 7pt),
  radius: 2pt,
  fill: accent.lighten(93%),
  stroke: (left: 2.5pt + accent),
  breakable: true,
  {
    text(font: gothic, weight: "bold", size: 9pt, fill: accent.darken(10%))[#icon #label]
    v(3pt, weak: true)
    set text(size: 9.5pt)
    set par(first-line-indent: 0em)
    body
  },
)

#let note(body)   = _callout(body, label: "補足",     accent: c-note,   icon: "ℹ")
#let tip(body)    = _callout(body, label: "ヒント",   accent: c-tip,    icon: "✓")
#let warn(body)   = _callout(body, label: "注意",     accent: c-warn,   icon: "▲")
#let danger(body) = _callout(body, label: "警告",     accent: c-danger, icon: "■")

// =============================================================
// ディストリビューション別の手順
// =============================================================
// 本書は Ubuntu 22.04 + ROS 2 Humble (構成A) と
// Ubuntu 24.04 + ROS 2 Jazzy (構成B) の両方を対象とする。
// 手順が分かれる箇所は、次の囲み／バッジで区別する。

#let c-humble = rgb("#00A1E9")   // 構成A: Humble
#let c-jazzy  = rgb("#1F8A4C")   // 構成B: Jazzy

// インラインのバッジ   例: #dist-humble 側のみ実行します
#let _badge(label, accent) = box(
  inset: (x: 4pt, y: 1.5pt),
  outset: (y: 2pt),
  radius: 2pt,
  fill: accent.lighten(85%),
  stroke: 0.5pt + accent.lighten(40%),
  text(font: gothic, size: 8pt, weight: "bold", fill: accent.darken(25%), label),
)
#let dist-humble = _badge("Humble", c-humble)
#let dist-jazzy  = _badge("Jazzy", c-jazzy)
#let dist-both   = _badge("共通", luma(110))

// ブロック: そのディストリビューションでのみ行う手順をまとめる
#let _distblock(body, label: "", accent: black, note: none) = block(
  width: 100%,
  inset: (left: 9pt, right: 9pt, top: 7pt, bottom: 7pt),
  radius: 2pt,
  fill: accent.lighten(95%),
  stroke: (left: 2.5pt + accent),
  breakable: true,
  {
    text(font: gothic, weight: "bold", size: 9pt, fill: accent.darken(15%))[#label]
    if note != none {
      text(font: gothic, size: 8.5pt, fill: accent.darken(5%))[ — #note]
    }
    v(3pt, weak: true)
    set text(size: 9.5pt)
    set par(first-line-indent: 0em)
    body
  },
)

#let humble(body) = _distblock(
  body, label: "構成A: Ubuntu 22.04 / ROS 2 Humble",
  accent: c-humble, note: [`release` ブランチ],
)
#let jazzy(body) = _distblock(
  body, label: "構成B: Ubuntu 24.04 / ROS 2 Jazzy",
  accent: c-jazzy, note: [`jazzy` ブランチ],
)

// 用語や前提知識のいらない読者向けのやさしい言い換え
#let plain(body) = _callout(body, label: "かんたんに言うと", accent: luma(90), icon: "→")

// 本ソフトウェアの設計方針を言い切るための囲み。
// 「どちらでもできます」と読まれると困る箇所に使う。
#let policy(body) = block(
  width: 100%,
  inset: (left: 11pt, right: 11pt, top: 9pt, bottom: 9pt),
  radius: 3pt,
  fill: c-brand.lighten(94%),
  stroke: 1.2pt + c-brand,
  breakable: true,
  {
    text(font: gothic, weight: "bold", size: 9.5pt, fill: c-brand.darken(35%))[◆ 本ソフトウェアの方針]
    v(4pt, weak: true)
    set text(size: 9.5pt)
    set par(first-line-indent: 0em)
    body
  },
)

// =============================================================
// 操作手順・UI 部品
// =============================================================

// GUI のボタン名を示すインライン部品   例: #btn[データ取得] をクリック
#let btn(body) = box(
  inset: (x: 4pt, y: 1.5pt),
  outset: (y: 2pt),
  radius: 2pt,
  fill: luma(240),
  stroke: 0.5pt + luma(160),
  text(font: gothic, size: 8.5pt, weight: "bold", body),
)

// キーボードのキーを示すインライン部品  例: #kbd[Esc] を押す
#let kbd(body) = box(
  inset: (x: 3.5pt, y: 1pt),
  outset: (y: 2pt),
  radius: 2pt,
  fill: white,
  stroke: 0.7pt + luma(120),
  text(font: mono, size: 8pt, body),
)

// ファイルパスを示すインライン部品
#let path(body) = box(text(font: mono, size: 0.9em, fill: rgb("#5A3E85"), body))

// =============================================================
// トラブルシューティング用のカード
// =============================================================
//
// #errorcard(
//   id: "E-101",
//   title: "サーバに接続できない",
//   symptom: [...],       // 何が起きているか (利用者が目にする現象)
//   shown: [...],         // 画面・端末に出る文言 (raw ブロック等)
//   cause: [...],         // 原因
//   fix: [...],           // 対処手順 (enum 推奨)
//   verify: [...],        // 直ったことの確認方法
//   level: "warn",        // "info" / "warn" / "danger"
// )

#let errorcard(
  title,
  id: none,
  symptom: none,
  shown: none,
  cause: none,
  fix: none,
  verify: none,
  level: "warn",
) = {
  let accent = if level == "danger" { c-danger } else if level == "info" { c-note } else { c-warn }

  // figure でくるむことで <err-xxx> ラベルによる相互参照を可能にする。
  // numbering に id を返すクロージャを渡し、参照時に「エラー E-101」と表示させる。
  figure(
    kind: "errorcard",
    supplement: [エラー],
    numbering: _ => if id != none { id } else { "" },
    caption: none,
    block(
    width: 100%,
    breakable: true,
    radius: 3pt,
    stroke: 0.7pt + accent.lighten(35%),
    clip: true,
    inset: 0pt,
    {
      set align(left)
      // ヘッダ
      // sticky: true — 見出しだけが前のページの末尾に取り残されるのを防ぐ。
      block(
        width: 100%,
        fill: accent.lighten(88%),
        inset: (x: 9pt, y: 6pt),
        sticky: true,
        grid(
          columns: (auto, 1fr),
          gutter: 7pt,
          align: horizon + left,
          if id != none {
            box(
              inset: (x: 4pt, y: 1.5pt), radius: 2pt, fill: accent,
              text(font: mono, size: 7.5pt, fill: white, weight: "bold", id),
            )
          } else { [] },
          text(font: gothic, weight: "bold", size: 10pt, fill: accent.darken(25%), title),
        ),
      )
      // 本文
      block(
        width: 100%,
        inset: (x: 9pt, y: 7pt),
        {
          set text(size: 9.5pt)
          let row(lbl, body) = if body != none {
            grid(
              columns: (46pt, 1fr),
              gutter: 7pt,
              align: (right + top, left + top),
              text(font: gothic, weight: "bold", size: 8.5pt, fill: accent.darken(15%), lbl),
              body,
            )
            v(4pt, weak: true)
          }
          row("症状", symptom)
          if shown != none {
            grid(
              columns: (46pt, 1fr),
              gutter: 7pt,
              align: (right + top, left + top),
              text(font: gothic, weight: "bold", size: 8.5pt, fill: accent.darken(15%), "画面表示"),
              shown,
            )
            v(4pt, weak: true)
          }
          row("原因", cause)
          row("対処", fix)
          row("確認", verify)
        },
      )
    },
    ),
  )
}

// =============================================================
// 撮影依頼プレースホルダ
// =============================================================
// 実機での撮影が必要な図に置くための枠。撮影後は image() に差し替える。
#let capture-todo(id, desc, height: 45mm) = block(
  width: 100%,
  height: height,
  radius: 3pt,
  fill: luma(248),
  stroke: (paint: luma(160), thickness: 0.8pt, dash: "dashed"),
  inset: 8pt,
  align(center + horizon)[
    #text(font: gothic, size: 8pt, fill: luma(110))[
      #box(inset: (x: 4pt, y: 1.5pt), radius: 2pt, fill: luma(215))[
        #text(font: mono, size: 7.5pt)[#id]
      ]
      \ #v(3pt)
      #text(weight: "bold", size: 9pt)[要 画面キャプチャ] \
      #v(2pt)
      #desc
    ]
  ],
)

// =============================================================
// 表のスタイル
// =============================================================
#let stable(columns: auto, ..cells) = table(
  columns: columns,
  inset: 6pt,
  align: left + horizon,
  fill: (x, y) => if y == 0 { c-brand.lighten(90%) } else { none },
  stroke: (x, y) => if y == 0 {
    (bottom: 1.2pt + c-brand)
  } else {
    (bottom: 0.3pt + luma(200))
  },
  ..cells
)

// =============================================================
// 簡易フロー図
// =============================================================
// 横方向のステップ図   #flow("データ取得", "マッピング", "経路設計", "自律走行")
#let flow(..steps, accent: c-brand) = {
  let items = steps.pos()
  let cells = ()
  let cols = ()
  for (i, s) in items.enumerate() {
    if i > 0 {
      cols.push(auto)
      cells.push(box(inset: (x: 4pt), text(fill: accent, size: 11pt)[→]))
    }
    cols.push(auto)
    cells.push(box(
      inset: (x: 7pt, y: 6pt),
      radius: 3pt,
      fill: accent.lighten(88%),
      stroke: 0.6pt + accent.lighten(30%),
      s,
    ))
  }
  set text(font: gothic, size: 8.5pt)
  align(center, box(grid(columns: cols, align: horizon, gutter: 0pt, ..cells)))
}

// 縦方向の判断フロー用の 1 ステップ
#let fstep(n, title, body) = block(
  width: 100%,
  inset: (left: 0pt, top: 3pt, bottom: 3pt),
  grid(
    columns: (16pt, 1fr),
    gutter: 7pt,
    align: (center + top, left + top),
    box(
      width: 15pt, height: 15pt, radius: 50%,
      fill: c-brand, inset: 0pt,
      align(center + horizon, text(font: gothic, size: 8pt, weight: "bold", fill: white, str(n))),
    ),
    {
      text(font: gothic, weight: "bold", size: 9.5pt, title)
      v(2pt, weak: true)
      set text(size: 9.5pt)
      body
    },
  ),
)

// =============================================================
// コンフィグのパラメータ表
// =============================================================
// パラメータがどの処理で使われるかを示すバッジ。
// 表の中で色分けすることで、「自分に関係する行」を目で拾えるようにする。
#let c-p2o    = rgb("#0B6BCB")   // p2o (グラフSLAM)
#let c-lioraw = rgb("#1F8A4C")   // lio_raw (LIO そのまま)
#let c-2d     = rgb("#8E44AD")   // 3D→2D 変換
#let c-gnss   = rgb("#B7791F")   // GNSS 補正

#let _tag(label, accent) = box(
  inset: (x: 3.5pt, y: 1pt),
  outset: (y: 1.5pt),
  radius: 2pt,
  fill: accent.lighten(85%),
  stroke: 0.5pt + accent.lighten(35%),
  text(font: gothic, size: 7pt, weight: "bold", fill: accent.darken(20%), label),
)
#let tag-p2o    = _tag("p2o", c-p2o)
#let tag-lioraw = _tag("lio_raw", c-lioraw)
#let tag-2d     = _tag("2D化", c-2d)
#let tag-gnss   = _tag("GNSS", c-gnss)
#let tag-none   = _tag("未使用", luma(120))

// パラメータ表。行番号を左端に置き、CSV の並び順そのものを一覧にする。
// 列: 行 / パラメータ名 / 出荷時の値 / 使う処理 / 意味
#let paramtable(..cells) = table(
  columns: (16pt, auto, auto, auto, 1fr),
  inset: (x: 5pt, y: 5pt),
  align: (center + horizon, left + horizon, left + horizon, left + horizon, left + top),
  fill: (x, y) => if y == 0 { c-brand.lighten(90%) } else if calc.odd(y) { luma(248) } else { none },
  stroke: (x, y) => if y == 0 { (bottom: 1.2pt + c-brand) } else { (bottom: 0.3pt + luma(210)) },
  table.header(
    text(font: gothic, weight: "bold", size: 8pt)[*行*],
    text(font: gothic, weight: "bold", size: 8pt)[*パラメータ*],
    text(font: gothic, weight: "bold", size: 8pt)[*出荷時*],
    text(font: gothic, weight: "bold", size: 8pt)[*使う処理*],
    text(font: gothic, weight: "bold", size: 8pt)[*意味・目安*],
  ),
  ..cells
)

// 表の中に見出し行を挟む (分類の区切り)
#let paramgroup(title) = table.cell(
  colspan: 5,
  fill: luma(232),
  inset: (x: 5pt, y: 4pt),
  text(font: gothic, weight: "bold", size: 8.5pt, fill: c-ink, title),
)

// 画面の要素に振った番号を示す丸バッジ (図の凡例と本文をつなぐ)
#let num(n, accent: c-brand) = box(
  baseline: 2.5pt,
  circle(
    radius: 6pt, fill: accent, stroke: 1pt + white,
    align(center + horizon, text(font: gothic, size: 7.5pt, weight: "bold", fill: white, str(n))),
  ),
)

// 図の上に番号バッジを重ねるための補助。
// #overlay(image(...), (num, x, y), ...) の形で使う。x/y は図の幅・高さに対する割合。
#let overlay(body, ..marks) = box({
  body
  for m in marks.pos() {
    place(
      top + left,
      dx: m.at(1) * 100% - 6pt,
      dy: m.at(2) * 100% - 6pt,
      num(m.at(0)),
    )
  }
})
