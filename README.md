# dotfiles

Linux と Windows で使う設定ファイルを管理しています。

## 方針

必要になったものを追加し、使わなくなったものを削除します。  
Linux と Windows のどちらでも、Neovim と VS Code で同じように開発できることを重視しています。  
操作は主にキーボードで行い、マウスは補助的に使う方針です。  
Neovim のキーマップでは leader キーに続けて使うキーを1文字に制限しています。  
例外として、zk コマンドには `<leader>z` をプレフィックスとして使っています。

## 前提

* Git
* chezmoi
* mise
* Noto Sans Mono CJK
* Alacritty
* MSYS2（Windows の場合）
* make（Windows では MSYS2 の ucrt64/mingw-w64-ucrt-x86_64-make を使用）

## セットアップ

1. `chezmoi init git@github.com:sh1Nome/dotfiles.git`
    * https の場合は `chezmoi init https://github.com/sh1Nome/dotfiles.git`
1. `chezmoi -v apply`
1. `mise install`
1. `make install-*` で必要なツールを導入する
    * 利用可能なターゲットの一覧は `make help` で確認する
    * Windows では `make` の代わりに `mingw32-make` を使う

## sbx の kit

複数の kit を使うには、`--kit` を繰り返し指定します。

```sh
sbx run codex \
  --kit ~/.config/sbx/kits/git-personal \
  --kit ~/.config/sbx/kits/codex-personal \
  --kit ~/.config/sbx/kits/ffmpeg
```

## xfce4 設定の反映

`chezmoi apply` だけでは xfce4 の設定は反映されません。

```sh
pkill xfconfd
```

その後ログインし直すと xfconfd が再起動し、設定を読み込みます。
test
