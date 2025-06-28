# psql-inventory-allocation

PostgreSQL SQL script for assigning inventory (with serial numbers) to orders across a date range based on shipping and return dates.

---

## 概要

このスクリプトは、**レンタル在庫や日付管理が必要な業務**において、注文ごとの「出荷日〜返却日」の期間に対応する在庫（シリアル番号付き）を動的に割り当てる仕組みです。

主に以下の処理を行っています：

- `generate_series` を用いて、注文ごとの貸出期間を日単位で展開
- 同じ日付・商品コードに一致する空き在庫を検索
- `ROW_NUMBER()` を使って注文数 (`qty`) の分だけ在庫に割り当て
- `UPDATE` により、該当在庫に `orderID` を付与

---

## 使用テーブル

| テーブル名        | 役割                     |
|------------------|--------------------------|
| `order_sample`    | 注文データ（出荷日、返却日、数量など） |
| `daily_inventory` | 日ごとの在庫状況（商品・シリアル番号単位） |

---

## 技術要素

- PostgreSQL 13+
- `generate_series` による日付展開
- `ROW_NUMBER()` による数量制限付きの割当
- `UPDATE ... FROM` 句による一括更新

---

## 処理の流れ

1. `WITH date_range`  
   各注文に対して、出荷日～返却日までの日付範囲を生成

2. `WITH target_inventory`  
   空き在庫の中から、数量分だけ `ROW_NUMBER()` で絞り込み

3. `WITH assignments`  
   割り当て対象として確定したレコードを抽出

4. `UPDATE`  
   在庫テーブルに `orderID` をセット

---

## 想定ユースケース

- レンタル商品の貸出業務
- レンタル商品の稼働スケジュール管理
- 日付単位での在庫割当ロジックの実装
- 他業務での「日付範囲 × 在庫」のマッチング処理

---

## 応用可能な業務

この構造は以下のような他業務にも転用可能です：

- ホテル宿泊予約（滞在期間 × 部屋割当）
- 会議室や設備の予約スケジューリング
- 製造装置の稼働時間割当
- ソフトウェアライセンスの期間貸出管理 など

---

## 注意点

- 割当対象の在庫には `"orderID"` が未設定、または空であることが前提です
- 同一商品・日付・シリアル番号に対しては **1注文のみ** 割当が行われます
- 排他制御が必要な場面ではトランザクション管理も検討してください

---

## ライセンス

This project is licensed under the MIT License.
