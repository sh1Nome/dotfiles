---
name: gh-glab-search-inspect
description: Issue・PR/MR・CI を検索・確認する時に使用します。GitHub と GitLab のどちらを使っているか git remote から判別してから、対応する gh/glab コマンドを実行します。
---

# gh/glab Search & Inspect

## ワークフロー

1. `git remote -v` でリモートを確認する
2. GitHub なら `gh`、GitLab なら `glab` を使って Issue・PR/MR・CI を検索・確認する

## Gotchas

* 認証は設定済みのため `gh auth status` / `glab auth status` は実行しない
* 認証エラーが発生しても `gh auth login` / `glab auth login` 等で自分から再認証を試みず、ユーザーに報告する
