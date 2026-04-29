---
name: cli-tools-gh-glab
description: gh/glab で GitHub/GitLab の Issue・PR/MR・CI 状況を確認・管理します。GitHub/GitLab の作業状況を確認したい時に使用します。
---

# CLI ツールスキル（gh / glab）

## 概要

`gh`（GitHub CLI）と `glab`（GitLab CLI）を使って Issue、PR/MR、CI 実行状況を確認する。使い方がわからないときは help オプションを確認する。

## 基本的な使い方

* 全体的なヘルプ: `gh help` / `glab help`
* コマンドのヘルプ: `gh <command> --help` / `glab <command> --help`
* わからないときはまず help を確認する

## gh コマンド（GitHub CLI）

* Issue 確認: `gh issue` コマンド（詳細は `gh issue --help`）
* PR 確認: `gh pr` コマンド（詳細は `gh pr --help`）
* GitHub Actions 確認: `gh run` コマンド（詳細は `gh run --help`）

## glab コマンド（GitLab CLI）

* Issue 確認: `glab issue` コマンド（詳細は `glab issue --help`）
* MR 確認: `glab mr` コマンド（詳細は `glab mr --help`）
* CI 確認: `glab ci` コマンド（詳細は `glab ci --help`）
