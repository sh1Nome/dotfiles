---
name: git-no-pager
description: Git コマンド実行時には必ず --no-pager オプションを付加する指示。AI が出力を正確に解析できるようにするため、すべての git コマンドで使用。
---

# Git に --no-pager オプションを付加

## 理由

Git は `pager = delta` で設定されているため、`--no-pager` を付加して標準出力を得ます。

## 使い方

すべての git コマンドに --no-pager を付加します。

```bash
git --no-pager diff
git --no-pager show HEAD
```

## 出力制限

出力が巨大になる可能性のあるコマンドは制限をかけます。組み込みオプション（`-n` など）を優先し、なければパイプで制限します。

```bash
git --no-pager log -n 20

# 組み込みオプションがない場合:
# Linux
git --no-pager log --all | head -n 20
# Windows PowerShell
git --no-pager log --all | Select-Object -First 20
```
