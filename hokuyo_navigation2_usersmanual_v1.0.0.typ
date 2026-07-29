#import "utils.typ": *

// --- ドキュメント設定 ---
#set text(
  font: (..mincho, ..gothic),
  size: 10pt,
  lang: "ja",
)

#set page(
  paper: "a4",
  margin: (x: 25mm, y: 28.5mm), // LaTeXの余白設定を近似
  header: context {
    let page_num = counter(page).at(here()).first()
    if page_num > 2 {
      let chapter = query(heading.where(level: 1).before(here())).at(-1, default: none)
      let section = query(heading.where(level: 2).before(here())).at(-1, default: none)

      if chapter != none {
        let chap_nums = counter(heading).at(chapter.location())
        let chap_idx = chap_nums.at(0)
        
        // 章番号が1以上（第1章以降）の場合のみヘッダーを表示
        if chap_idx > 0 {
          let left_header = if section != none {
            let sect_nums = counter(heading).at(section.location())
            // 現在の章に属するセクションのみ表示
            if sect_nums.at(0) == chap_idx {
              [#numbering("1.1", ..sect_nums.slice(0, 2)) #section.body]
            }
          }

          set text(font: gothic, weight: "bold", size: 9pt)
          stack(
            spacing: 4pt,
            grid(
              columns: (1fr, 1fr),
              align(left, left_header),
              align(right, [#chap_idx #chapter.body])
            ),
            line(length: 100%, stroke: 0.5pt)
          )
        }
      }
    }
  },
  footer: context {
    // ページ番号付けが設定されているページ（タイトルページ以外）で表示
    let numbering_pattern = here().page-numbering()
    if numbering_pattern != none {
      if numbering_pattern == "i" {
        // ローマ数字の場合は分母なしで表示
        align(center, counter(page).display())
      } else {
        // 本文（アラビア数字）の場合は分母付きで表示
        align(center, counter(page).display("1 / 1", both: true))
      }
    }
  }
)

// 段落設定
#set par(
  leading: 0.65em,
  first-line-indent: 1em,
  justify: true,
)
#show par: set block(spacing: 0.65em)

// リンクと相互参照の色を青色に設定し、クリック可能であることを明示します (LaTeXのhyperref相当)
#show link: set text(fill: blue.darken(20%))
#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading {
    let loc = el.location()
    let num = numbering(el.numbering, ..counter(heading).at(loc))
    link(loc, text(fill: blue.darken(20%))[#num#el.body])
  } else {
    text(fill: blue.darken(20%), it)
  }
}

// 見出しの設定
#set heading(numbering: "1.1.1  ", supplement: none)
#show heading: it => {
  set text(font: gothic, weight: "bold")
  block(it, above: 1.5em, below: 1em)
}

// 図表の設定 (番号のみ表示、章-通し番号形式)
#set figure(numbering: n => context {
  let chap = counter(heading).at(here()).at(0)
  numbering("1", n)
})

// サブ図 (subfigure) の管理ロジック
// 通常の図の中で呼び出された figure を subfigure として扱い、(a), (b) と番号を振る
#show figure: it => {
  if it.kind == "subfigure" {
    // サブ図の表示スタイル設定
    set align(center)
    it.body
    if it.has("caption") {
      v(4pt, weak: true)
      text(size: 9pt, weight: "regular")[
        // キャプションには枝番号 (a) のみを表示
        #context numbering("(a)", it.counter.at(it.location()).at(0)) #it.caption.body
      ]
    }
  } else {
    // 親となる通常の図：現在の章番号と通し番号を取得して子に引き継ぐ
    context {
      let chap = counter(heading).at(it.location()).at(0)
      let count = it.counter.at(it.location()).at(0)
      let prefix = numbering("1", count)
      let suppl = if it.kind == image { [図] } else if it.kind == table { [表] } else { it.supplement }

      counter(figure.where(kind: "subfigure")).update(0)
      // サブ図の numbering に親の番号を埋め込む（これで引用時に "1-1 (a)" となる）
      show figure: set figure(kind: "subfigure", supplement: suppl, numbering: n => [#prefix (#numbering("a", n))]);
      it
    }
  }
}


// 用語解説 (terms) のラベル部分を Harano Aji Gothic の太字にする設定
#show terms.item: it => {
  text(font: gothic, weight: "bold", it.term)
  [: ]
  it.description
}

// インラインコード (raw text) のフォントサイズを周囲のテキスト（親要素）と同じにする設定
#show raw.where(block: false): set text(size: 1em)

// ソースコード (listings) の設定
#show raw.where(block: true): it => block(
  fill: luma(245),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  stroke: 0.5pt + luma(200),
  it
)


// --- タイトルページ ---
#align(center)[
  #v(2cm)
  
  #text(size: 24pt, font: "Harano Aji Gothic", weight: "bold")[
    hokuyo_navigation2 \
    ユーザーマニュアル
  ]
  
  #v(0.5cm)
  #text(size: 14pt)[3D SLAM and Navigation System Application for RSF-X001] \
  #text(size: 14pt)[Document Version 0.1.0]
  
  #v(6cm)
  #datetime.today().display("[year]年[month]月[day]日")
]

#pagebreak()

// --- 目次・図目次・表目次 ---
#set page(numbering: "i")
#counter(page).update(1)

#outline(indent: auto)
#pagebreak()

#outline(title: [図目次], target: figure.where(kind: image))
#pagebreak()

#outline(title: [表目次], target: figure.where(kind: table))
#pagebreak()

// --- 本文 ---
#set page(numbering: "1")
#counter(page).update(1)

// 各章のインクルード (LaTeX の \input に相当)
// 注: ファイル名は .typ に変更する必要があります
#include "1_start.typ"
#include "2_setup.typ"
#include "3_launch_gui.typ"
#include "4_config.typ"
#include "5_get_data.typ"
#include "6_mapping.typ"
#include "7_waypoint.typ"
#include "8_2D_map.typ"
// #include "9_navigation.typ"

#pagebreak()

// --- 付録 ---
#set heading(numbering: "A.1.1  ")
#counter(heading).update(0)
#include "appendix.typ"
