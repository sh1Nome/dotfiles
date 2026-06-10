---
name: gh-glab-search-inspect
description: gh/glab で GitHub/GitLab の Issue・PR/MR・CI を検索・確認します。Issue を探す/確認する、PR/MR のレビュー状況を確認する、CI/CD の結果を確認/失敗原因を調査する時に使用します。
---

# gh/glab Search & Inspect

## 概要

`gh`（GitHub CLI）と `glab`（GitLab CLI）で GitHub/GitLab のリソースを操作します。

## ヘルプの確認

わからないときはまずヘルプを確認します：

```bash
gh help                    # GitHub CLI ヘルプ
gh <command> --help        # コマンド詳細
glab help                  # GitLab CLI ヘルプ
glab <command> --help      # コマンド詳細
```

## ワークフロー

### Issue を探す/確認する

1. リモートを判別
   - GitHub → `gh`
   - GitLab → `glab`

2. Issue を検索・確認
   ```bash
   # GitHub
   gh issue list                    # 一覧表示
   gh issue view <number>           # 詳細確認

   # GitLab
   glab issue list                  # 一覧表示
   glab issue view <id>             # 詳細確認
   ```

### PR/MR のレビュー状況を確認する

```bash
# GitHub
gh pr list                         # 一覧表示
gh pr view <number>                # 詳細確認
gh pr view <number> --comments     # コメント確認

# GitLab
glab mr list                       # 一覧表示
glab mr view <id>                  # 詳細確認
glab mr note list <id>             # MR のコメント確認
```

### CI/CD の結果を確認・失敗原因を調査する

#### GitHub Actions

```bash
gh pr checks <number>              # PR の CI ステータス確認
gh run list                        # 実行一覧
gh run view <run-id>               # 実行詳細
gh run watch <run-id>              # リアルタイム監視
```

#### GitLab CI

```bash
# パイプライン情報を確認
glab ci list                       # パイプライン一覧
glab ci get                        # 現在のブランチのパイプライン詳細（JSON）
glab ci status                     # 現在のブランチのパイプライン状態

# ジョブのログを確認（失敗原因を調査）
glab ci trace <job-id>             # ジョブのログをリアルタイム表示
glab ci trace <job-name>           # ジョブ名でもトレース可能
```
