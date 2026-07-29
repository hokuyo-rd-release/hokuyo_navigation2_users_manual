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

#let tsuyo(it) = {
  set text(font: gothic, weight: "bold")
  it
}

// ターミナル風のスタイル定義
#let terminal(it) = block(
  fill: luma(240),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  text(font: "DejaVu Sans Mono", size: 9pt, it)
)