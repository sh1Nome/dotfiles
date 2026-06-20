---
name: manage-skill
description: スキルを作成・更新・リファクタします。「スキルを作って」「スキルを更新して」「スキルをリファクタして」などの依頼に使用します。
---

# manage-skill

## 起動時に読み込む

`https://agentskills.io/llms.txt` を fetch してドキュメント構成を把握し、ベストプラクティスのページを読む。必要に応じて他のページも参照する。

## ワークフロー

1. 更新・リファクタの場合は対象スキルの現在の内容を読み込む
2. sync-stepwise スキルを使ってヒアリングする
3. ヒアリング結果とベストプラクティスに従い、ファイル構成に従ってスキルファイルを作成・更新する

## ファイル構成

git remote が `sh1nome/dotfiles` かどうかで構成が異なる。

### sh1nome/dotfiles（chezmoi 管理）

1スキルにつき以下の3ファイルを作成する：

| パス | 役割 |
|------|------|
| `.chezmoitemplates/skills/<name>/SKILL.md` | スキル本体（フロントマター付き） |
| `dot_claude/skills/<name>/SKILL.md.tmpl` | `~/.claude/skills/` 向けテンプレート参照 |
| `dot_agents/skills/<name>/SKILL.md.tmpl` | `~/.agents/skills/` 向けテンプレート参照 |

tmpl ファイルは以下の1行のみ：

```
{{ "{{" }}- template "skills/<name>/SKILL.md" . -{{ "}}" }}
```

### その他のリポジトリ

`.claude/skills/<name>/SKILL.md` または `.agents/skills/<name>/SKILL.md` に直接配置する。プロジェクト構造を確認して適切な場所を選ぶ。
