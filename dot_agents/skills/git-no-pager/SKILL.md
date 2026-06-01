---
name: git-no-pager
description: Git コマンド実行時には必ず --no-pager オプションを付加する指示。AI が出力を正確に解析できるようにするため、すべての git コマンドで使用。
---

# Git に --no-pager オプションを付加

## 理由

Git は `pager = delta` で設定されており、diff、show などの出力が delta にパイプされます。  
delta は出力をフォーマット・着色するため、AI が出力を正確に解析しにくくなります。  
`--no-pager` オプションを付加することで、delta をバイパスして標準の git 出力を得られます。

## 使い方

すべての git コマンドに --no-pager を付加します。

```bash
git --no-pager diff
git --no-pager show HEAD
```

## 出力制限

出力が巨大になる可能性のあるコマンド（例：git log）は、制限をかけます。  
git が対応していれば組み込みオプション（-n など）を使い、なければパイプで制限します。

```bash
git --no-pager log -n 20
git --no-pager log --all | head -n 20
```
