---
name: inspect-github-and-gitlab
description: Issue・PR/MR・CI を検索・確認するときに使用します。git remote で GitHub と GitLab のどちらを使っているかを確認し、対応する gh/glab コマンドを実行します。
---

# GitHub / GitLab Inspect

## ワークフロー

1. `git remote -v` でリモートを確認する
2. GitHub なら `gh`、GitLab なら `glab` を使って Issue・PR/MR・CI を検索・確認する

## Gotchas

* 認証は設定済みのため `gh auth status` / `glab auth status` は実行しない
* 認証エラーが発生したら依頼者に報告する。`gh auth login` / `glab auth login` 等で自ら再認証を試みない
