---
name: adr
description: 会話内容から Nygard 形式の Architecture Decision Record (ADR) を作成します。「ADR を作って」と依頼されたとき、および設計上の決定とその背景・トレードオフを記録に残したいときに使用します。
---

# adr

## ワークフロー

1. 現在の会話履歴から、タイトル・Status・Context・Decision・Consequences の材料を抽出する
2. 不足している項目は sync-stepwise スキルで1問ずつ確認する。推測で補わない
3. 出力先を決める。既定は `docs/adr`、存在しなければユーザーに確認する
4. 出力先の既存 ADR を走査し、最大番号 + 1 を4桁ゼロ埋めで採番する
5. タイトルを英語のケバブケースに変換してスラッグとし、ファイル名を `NNNN-<slug>.md` とする
6. documentation-writing スキルを使い、各セクションの文章を書く・推敲する
7. 出力形式に従って CommonMark でファイルを書き込む
8. この決定が置き換える既存 ADR があれば、その Status を `Superseded by ADR-NNNN` に書き換える

## 出力形式

```
# タイトル

## Status

Accepted

## Context

背景

## Decision

決定

## Consequences

- 結果
```

## 記述ルール

- Status は `Proposed` / `Accepted` / `Deprecated` / `Superseded by ADR-NNNN` のいずれかとし、既定は `Accepted` とする
- Context は決定を左右した事情（技術的・政治的・社会的・プロジェクト固有）を事実として並べる、事情どうしの対立も書く
- Context に結論や良し悪しの評価は書かない、Decision と Consequences に回す
- Decision は「〜する」と能動態で書く
- Consequences は利点と欠点の両方を書く、片方しか出てこない場合はユーザーに確認する
- タイトルと本文は日本語、セクションの見出しは英語で書く
