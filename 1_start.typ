= はじめに <sec:start>

`hokuyo_navigation2`は、`ROS 2` の自律走行パッケージ #link("https://docs.nav2.org")[`Nav2`] を活用した
RSF-X001 (以下、RSF)専用の屋内屋外対応自律走行ソフトウェアです。

RSF の RTK-GNSS の出力と 3D LiDAR による位置を用いて地図作成と経路設計を行い、それらを用いた自律走行を可能とします。
また、非技術者でも簡単に操作を行うためのGUI を用意しているため、センサ1台で自律走行ロボットの構築が可能となります。

本稿で説明する`hokuyo_navigation2` のソフトウェアバージョンは1.0.0 に対応しております。
このドキュメントバージョンでは、地図作成、経路設計までの方法の説明を行います。

/ 要求バージョン: `Ubuntu 22.04`, `ROS 2 Humble Hawksbill`
// # / 動作環境: Core Ultra 7 258V RAM 32GB, Core Ultra 5 125H RAM 32GB, Ryzen 9 8945HS RAM 32GB

#pagebreak()