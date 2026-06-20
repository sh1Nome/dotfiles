---
name: gh-glab-search-inspect
description: gh/glab で GitHub/GitLab の Issue・PR/MR・CI を検索・確認します。Issue を探す/確認する、PR/MR のレビュー状況を確認する、CI/CD の結果を確認/失敗原因を調査する時に使用します。
---

# gh/glab Search & Inspect

## ワークフロー

### Issue を探す/確認する

1. リモートを判別

2. Issue を検索・確認
   ```bash
   # GitHub
   gh issue list                          # 一覧表示
   gh issue view <number>                 # 詳細確認
   gh issue view <number> --comments      # コメント確認

   # GitLab
   glab issue list                        # 一覧表示
   glab issue view <id>                   # 詳細確認
   glab issue view <id> --comments        # コメント確認
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

1. PR の CI ステータスを確認
   ```bash
   gh pr checks <number>
   ```
2. 失敗した run-id を特定
   ```bash
   gh run list
   ```
3. 失敗ログを確認
   ```bash
   gh run view <run-id> --log-failed
   ```

#### GitLab CI

1. パイプライン状態を確認
   ```bash
   glab ci status
   ```
2. ジョブ一覧を確認
   ```bash
   glab ci list
   ```
3. 失敗ジョブのログをトレース
   ```bash
   glab ci trace <job-id>
   ```
